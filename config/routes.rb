Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "/auth/verify_token", to: "auth#verify_token"
  namespace :api do
    namespace :v1 do
      resources :test
      get "/", to: "health#show"
      get "/users/me", to: "users#me"
      resources :servers, only: [:index, :create] do
        collection do
          post :join
          get 'invite/:invite_code', to: 'servers#invite_info'
        end
        member do
          post :invite
          patch :regenerate_invite_code
        end
        resources :channels, only: [:index, :create] do
          resources :messages, only: [:index, :create]
        end
      end
    end
  end
end
