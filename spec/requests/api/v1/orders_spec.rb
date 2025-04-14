require 'swagger_helper'

RSpec.describe 'Orders API', type: :request do
  path '/api/v1/orders' do
    get 'Lists all orders' do
      tags 'Orders'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status'
      parameter name: :customer_id, in: :query, type: :integer, required: false, description: 'Filter by customer'
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false, description: 'Filter by start date'
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false, description: 'Filter by end date'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Field to sort by'
      parameter name: :sort_direction, in: :query, type: :string, required: false, description: 'Sort direction (asc or desc)'
      security [bearer_auth: []]

      response '200', 'orders found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              customer_id: { type: :integer },
              status: { type: :string },
              total_amount: { type: :number, format: :float },
              notes: { type: :string, nullable: true },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            }
          }
        let(:page) { 1 }
        run_test!
      end
    end

    post 'Creates an order' do
      tags 'Orders'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          customer_id: { type: :integer },
          line_items: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :integer },
                quantity: { type: :integer },
                unit_price: { type: :number, format: :float }
              },
              required: ['product_id', 'quantity', 'unit_price']
            }
          }
        },
        required: ['customer_id', 'line_items']
      }

      response '201', 'order created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            status: { type: :string },
            total_amount: { type: :number, format: :float },
            notes: { type: :string, nullable: true },
            created_at: { type: :string, format: :'date-time' },
            updated_at: { type: :string, format: :'date-time' }
          }
        let(:order) { { customer_id: 1, line_items: [{ product_id: 1, quantity: 2, unit_price: 10.99 }] } }
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
        let(:order) { { customer_id: nil } }
        run_test!
      end
    end
  end

  path '/api/v1/orders/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Retrieves an order' do
      tags 'Orders'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'order found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            status: { type: :string },
            total_amount: { type: :number, format: :float },
            notes: { type: :string, nullable: true },
            created_at: { type: :string, format: :'date-time' },
            updated_at: { type: :string, format: :'date-time' },
            line_items: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  order_id: { type: :integer },
                  product_id: { type: :integer },
                  quantity: { type: :integer },
                  unit_price: { type: :number, format: :float },
                  total_price: { type: :number, format: :float }
                }
              }
            },
            payments: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  order_id: { type: :integer },
                  amount: { type: :number, format: :float },
                  payment_method: { type: :string },
                  status: { type: :string },
                  transaction_id: { type: :string, nullable: true }
                }
              }
            },
            shipments: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  order_id: { type: :integer },
                  tracking_number: { type: :string, nullable: true },
                  carrier: { type: :string, nullable: true },
                  status: { type: :string }
                }
              }
            }
          }
        let(:id) { '1' }
        run_test!
      end

      response '404', 'order not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        let(:id) { '0' }
        run_test!
      end
    end

    put 'Updates an order' do
      tags 'Orders'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          status: { type: :string, enum: ['created', 'processing', 'fulfilled', 'canceled'] }
        }
      }

      response '200', 'order updated' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            status: { type: :string },
            total_amount: { type: :number, format: :float },
            notes: { type: :string, nullable: true },
            created_at: { type: :string, format: :'date-time' },
            updated_at: { type: :string, format: :'date-time' }
          }
        let(:id) { '1' }
        let(:order) { { status: 'processing' } }
        run_test!
      end

      response '404', 'order not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        let(:id) { '0' }
        let(:order) { { status: 'processing' } }
        run_test!
      end
    end

    delete 'Cancels an order' do
      tags 'Orders'
      security [bearer_auth: []]

      response '204', 'order canceled' do
        let(:id) { '1' }
        run_test!
      end

      response '404', 'order not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        let(:id) { '0' }
        run_test!
      end
    end
  end
end