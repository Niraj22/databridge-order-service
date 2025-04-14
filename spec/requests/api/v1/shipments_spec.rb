require 'swagger_helper'

RSpec.describe 'Shipments API', type: :request do
  path '/api/v1/orders/{order_id}/shipments' do
    parameter name: :order_id, in: :path, type: :integer, description: 'Order ID'

    get 'Lists all shipments for an order' do
      tags 'Shipments'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'shipments found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              order_id: { type: :integer },
              tracking_number: { type: :string, nullable: true },
              carrier: { type: :string, nullable: true },
              status: { type: :string },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            }
          }
        let(:order_id) { '1' }
        run_test!
      end

      response '404', 'order not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        let(:order_id) { '0' }
        run_test!
      end
    end

    post 'Creates a shipment for an order' do
      tags 'Shipments'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :shipment, in: :body, schema: {
        type: :object,
        properties: {
          tracking_number: { type: :string },
          carrier: { type: :string },
          status: { type: :string, enum: ['pending', 'shipped', 'delivered', 'returned'] }
        }
      }

      response '201', 'shipment created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            order_id: { type: :integer },
            tracking_number: { type: :string, nullable: true },
            carrier: { type: :string, nullable: true },
            status: { type: :string },
            created_at: { type: :string, format: :'date-time' },
            updated_at: { type: :string, format: :'date-time' }
          }
        let(:order_id) { '1' }
        let(:shipment) { { tracking_number: '1Z999AA10123456784', carrier: 'UPS', status: 'pending' } }
        run_test!
      end

      response '422', 'invalid request' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          }
        let(:order_id) { '1' }
        let(:shipment) { { status: 'invalid_status' } }
        run_test!
      end

      response '404', 'order not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        let(:order_id) { '0' }
        let(:shipment) { { tracking_number: '1Z999AA10123456784', carrier: 'UPS' } }
        run_test!
      end
    end
  end

  path '/api/v1/orders/{order_id}/shipments/{id}' do
    parameter name: :order_id, in: :path, type: :integer, description: 'Order ID'
    parameter name: :id, in: :path, type: :integer, description: 'Shipment ID'

    put 'Updates a shipment' do
      tags 'Shipments'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :shipment, in: :body, schema: {
        type: :object,
        properties: {
          tracking_number: { type: :string },
          carrier: { type: :string },
          status: { type: :string, enum: ['pending', 'shipped', 'delivered', 'returned'] }
        }
      }

      response '200', 'shipment updated' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            order_id: { type: :integer },
            tracking_number: { type: :string, nullable: true },
            carrier: { type: :string, nullable: true },
            status: { type: :string },
            created_at: { type: :string, format: :'date-time' },
            updated_at: { type: :string, format: :'date-time' }
          }
        let(:order_id) { '1' }
        let(:id) { '1' }
        let(:shipment) { { status: 'shipped' } }
        run_test!
      end

      response '404', 'shipment not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        let(:order_id) { '1' }
        let(:id) { '0' }
        let(:shipment) { { status: 'shipped' } }
        run_test!
      end

      response '422', 'invalid request' do
        schema type: :object,
          properties: {
            errors: {
              type: :array,
              items: { type: :string }
            }
          }
        let(:order_id) { '1' }
        let(:id) { '1' }
        let(:shipment) { { status: 'invalid_status' } }
        run_test!
      end
    end
  end
end