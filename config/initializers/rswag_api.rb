# config/initializers/rswag_api.rb
Rswag::Api.configure do |c|
    # Specify a root folder where Swagger JSON files are located
    # This is used by the Swagger middleware to serve requests for API descriptions
    c.swagger_root = Rails.root.to_s + '/swagger'
  end