# config/routes.rb
Rails.application.routes.draw do
  # Mounting Rswag for API documentation
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  
  namespace :api do
    namespace :v1 do
      resources :orders do
        resources :payments, only: [:index, :create]
        resources :shipments, only: [:index, :create, :update]
      end
    end
  end

  # Health check endpoint
  root to: proc { [200, {}, ['DataBridge Customer Service']] }
end