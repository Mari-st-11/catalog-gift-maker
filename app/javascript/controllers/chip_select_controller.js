import { Controller } from "@hotwired/stimulus"

// プリセットのチップをクリックすると、隣のテキスト入力欄に値を反映する
export default class extends Controller {
  static targets = ["input", "chip"]

  select(event) {
    this.inputTarget.value = event.currentTarget.dataset.chipSelectValueParam
    this.chipTargets.forEach((chip) => {
      const active = chip === event.currentTarget
      chip.classList.toggle("border-gold", active)
      chip.classList.toggle("text-gold-dark", active)
      chip.classList.toggle("bg-gold-light/40", active)
      chip.classList.toggle("border-ash-border", !active)
      chip.classList.toggle("text-ash-sub", !active)
    })
  }
}
