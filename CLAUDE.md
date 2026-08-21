# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

「カタログギフトメーカー」(Catalog Gift Maker) is a Rails web app for building a personalized
gift catalog: a sender ("贈り主") registers candidate products (via URL/OGP scraping or manual
entry with an uploaded image) into a `GiftList`, shares a no-login URL with the recipient, and the
recipient picks one item from the list. Purchasing/shipping is always handled by the sender
outside the app. See [README.md](README.md) for full product background and user personas.

An active redesign is in progress on the `redesign` branch (multi-catalog dashboard, design
themes, OmniAuth-only login, LINE notifications, price-hidden public pages). Before making
architectural decisions, read **[docs/redesign_decisions.md](docs/redesign_decisions.md)** (why
things were done a certain way) and **[docs/redesign_plan.md](docs/redesign_plan.md)** (what's
done vs. still open) — keep both updated as decisions are made or work completes.

## Development environment

**Ruby is not installed on the host** — this project is developed entirely through Docker. Do not
try to run `bundle`/`rails` directly on the host; use `docker compose run --rm web ...`.

```bash
# start the Postgres container (and wait for it to become healthy before running rails commands)
docker compose up -d db

# run the full stack (web on :3000, runs bundle install + db:prepare + rails server on boot)
docker compose up

# run one-off rails/bundle commands against the db container
docker compose run --rm web bundle exec rails db:migrate
docker compose run --rm web bundle exec rails console
docker compose run --rm web bundle exec rails db:migrate:status

# tests (Minitest; the test DB needs preparing once)
docker compose run --rm web bundle exec rails db:test:prepare
docker compose run --rm web bundle exec rails test
docker compose run --rm web bundle exec rails test test/models/gift_list_test.rb
docker compose run --rm web bundle exec rails test test/models/gift_list_test.rb -n test_name

# lint (Omakase Rubocop style, config in .rubocop.yml)
docker compose run --rm web bundle exec rubocop
```

JS/CSS are built with esbuild + Tailwind v4 (via `bin/dev` / `Procfile.dev`, `yarn build`); these
run automatically as part of `docker compose up`'s web command, no separate step needed in
Docker-based development.

## Architecture

### Core data model

- `User` (Devise) `has_many :gift_lists, :gift_items, :notifications`.
- `GiftList` — one gift catalog. Uses a **UUID as its primary key** (`primary_key: "uuid"`,
  generated in `before_create`), not an integer `id`. This UUID doubles as the public share-link
  token (`/shared_gift_lists/:id` where `:id` is the uuid) — see the security caveats in
  `docs/redesign_decisions.md` about this (no revocation without changing the PK; a separate
  `public_token` column is planned).
- `GiftItem` — `belongs_to :gift_list, primary_key: :uuid, foreign_key: :gift_list_uuid` (not a
  standard `belongs_to`; the FK column is `gift_list_uuid`). Registered via URL+OGP scraping
  (Nokogiri) or manual entry; images go through CarrierWave (`app/uploaders/image_uploader.rb`,
  S3/`fog` in production, local disk in dev) — migration to ActiveStorage/S3 is planned but not
  done (ActiveStorage tables exist in the schema but aren't wired into any model yet).
- `Notification` — `belongs_to :gift_item` (concrete FK, **not polymorphic** — an earlier version
  of this model declared `belongs_to :notifiable, polymorphic: true` which didn't match the actual
  `gift_item_id` column and raised at runtime; don't reintroduce that).

### Public (no-login) vs. private controllers

There are two parallel sets of controllers/views for gift lists/items:
- `GiftListsController` / `GiftItemsController` — the **owner's** private dashboard, scoped via
  `current_user.gift_lists.find_by(uuid: ...)`.
- `SharedGiftListsController` / `SharedGiftItemsController` — the **public, unauthenticated**
  view the recipient sees at the share URL. `SharedGiftListsController` has **no
  `authenticate_user!`/ownership check at all**, including on `choose` (recipient picks an item)
  and `cancel` (meant to be an owner-only "let them choose again" reset). Neither action currently
  gates on `GiftList#status`, so nothing stops a visitor from re-selecting or cancelling
  repeatedly — this is a known gap tracked in `docs/redesign_plan.md`, not an accepted pattern to
  copy elsewhere.
- When adding exclusivity/race-condition protection for selection flows, use the atomic
  conditional-update pattern already established in `GiftList#try_mark_selected!`
  (`update_all(status: ...) == 1`) rather than adding optimistic locking (`lock_version`) — this
  was a deliberate choice recorded in `docs/redesign_decisions.md`.

### Auth

Devise handles email/password auth (`database_authenticatable`, `registerable`, etc., in custom
`Users::SessionsController` / `Users::RegistrationsController`). OmniAuth (Google/LINE) was added
**alongside** password auth, not as a replacement — `User.from_omniauth` links to an existing user
by email before creating a new one. Do not remove `database_authenticatable`/`registerable`; the
decision log explains why a full migration off passwords isn't planned.
