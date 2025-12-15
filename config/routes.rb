Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  # Public routes
  root "blog_posts#index"
  get "about", to: "pages#about"
  get "presentations", to: "presentations#index"
  get "blog", to: "blog_posts#index"
  get "blog_posts/:filename", to: "blog_posts#show", as: :blog_post

  # Admin routes
  namespace :admin do
    root "dashboard#index"
    resource :bio, only: [:show, :edit, :update]
    resource :contact_info, only: [:show, :edit, :update], controller: :contact_info
    resources :presentations do
      resources :conference_presentations, except: [:show, :index]
    end
    resources :blog_posts
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
