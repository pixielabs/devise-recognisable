Rails.application.routes.draw do
  devise_for :users, controllers: {sessions: 'sessions'}

  authenticated :user do
    root to: 'authenticated#index', as: :authenticated_root
  end

  root to: "home#index"
end
