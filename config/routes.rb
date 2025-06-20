Rails.application.routes.draw do
  devise_for :users, controllers: {
  sessions: "users/sessions",
  registrations: "users/registrations"
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  resources :gift_lists, only: %i[ index new create show edit update ] do
    resources :gift_items, only: %i[ new create show edit update ], shallow: true
  end

  resources :shared_gift_lists, only: %i[ show ] do
    member do
      post :select
    end
  end

  # トップページ
  root "static_pages#top"
end
