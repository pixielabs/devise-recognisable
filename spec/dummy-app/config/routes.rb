Rails.application.routes.draw do
  # Had to add the controllers bit below to get my controller to work!
  devise_for :users, controllers: {sessions: "sessions"}

  authenticated :user do
    root to: 'authenticated#index', as: :authenticated_root
  end

  root to: "home#index"
end
