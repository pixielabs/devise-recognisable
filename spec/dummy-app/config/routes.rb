Rails.application.routes.draw do
  devise_for :users

  authenticated :user do
    root to: 'authenticated#index', as: :authenticated_root
  end

  root to: "home#index"
end
