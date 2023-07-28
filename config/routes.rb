Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  resources :podcasts, only: %i[index show new edit create update] do
    member do
      patch :fetch
    end
  end

  # Defines the root path route ("/")
  root "podcasts#index"
end
