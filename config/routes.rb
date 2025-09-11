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
      resources :servers, only: [:index, :create, :update] do
        collection do
          post :join
          get 'invite/:invite_code', to: 'servers#invite_info'
        end
        member do
          post :invite
          patch :regenerate_invite_code
          get :members
          post :token, to: 'servers#generate_token'
        end
        resources :channels, only: [:index, :create] do
          resources :messages, only: [:index, :create]
          resources :events, only: [:index, :create]
          resources :files, only: [:index, :create] do
            member do
              get :download
            end
          end
          # forum_threads and forum_posts removed per request
          resources :whiteboards, only: [:index, :create]
          resources :surveys, only: [:index, :create] do
            member do
              post :vote
            end
          end
          resources :tasks, only: [:index, :create, :update]
          resources :wiki_pages, only: [:index, :create, :show, :update]
          resources :budget_entries, only: [:index, :create]
          resources :inventory_items, only: [:index, :create]
          resources :photos, only: [:index, :create] do
            member do
              get :download
            end
          end
          resources :diary_entries, only: [:index, :create]
        end
      end
    end
  end
end
