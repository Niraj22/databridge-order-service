module Api
  module V1
    class PaymentsController < ApplicationController
      before_action :set_order
      
      def index
        payments = @order.payments
        render json: payments
      end
      
      def create
        payment = @order.payments.new(payment_params)
        
        if payment.save
          render json: payment, status: :created
        else
          render json: { errors: payment.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_order
        @order = Order.find(params[:order_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end
      
      def payment_params
        params.permit(:amount, :payment_method, :status, :transaction_id)
      end
    end
  end
end