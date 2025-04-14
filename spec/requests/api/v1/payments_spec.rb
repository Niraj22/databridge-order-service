require 'swagger_helper'

RSpec.describe 'Payments API', type: :request do
  path '/api/v1/orders/{order_id}/payments' do
    parameter name: :order_id, in: :path, type: :integer, description: 'Order ID'

    get 'Lists all payments for an order' do
      tags 'Payments'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'payments found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              order_id: { type: :integer },
              amount: { type: :number, format: :float },
              payment_method: { type: :string },
              status: { type: :string },
              transaction_id: { type: :string, nullable: true },
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

    post 'Creates a payment for an order' do
      tags 'Payments'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :payment, in: :body, schema: {
        type: :object,
        properties: {
          amount: { type: :number, format: :float },
          payment_method: { type: :string, enum: ['credit_card', 'paypal', 'bank_transfer'] },
          status: { type: :string, enum: ['pending', 'completed', 'failed'] },
          transaction_id: { type: :string, nullable: true }
        },
        required: ['amount', 'payment_method']
      }

      response '201', 'payment created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            order_id: { type: :integer },
            amount: { type: :number, format: :float },
            payment_method: { type: :string },
            status: { type: :string },
            transaction_id: { type: :string, nullable: true },
            created_at: { type: :string, format: :'date-time' },
            updated_at: { type: :string, format: :'date-time' }
          }
        let(:order_id) { '1' }
        let(:payment) { { amount: 99.99, payment_method: 'credit_card', status: 'pending' } }
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
        let(:payment) { { amount: nil } }
        run_test!
      end

      response '404', 'order not found' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        let(:order_id) { '0' }
        let(:payment) { { amount: 99.99, payment_method: 'credit_card' } }
        run_test!
      end
    end
  end
end