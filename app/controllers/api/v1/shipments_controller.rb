module Api
  module V1
    class ShipmentsController < ApplicationController
      before_action :set_order
      
      def index
        shipments = @order.shipments
        render json: shipments
      end
      
      def create
        shipment = @order.shipments.new(shipment_params)
        
        if shipment.save
          render json: shipment, status: :created
        else
          render json: { errors: shipment.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        shipment = @order.shipments.find(params[:id])
        
        if shipment.update(shipment_params)
          render json: shipment
        else
          render json: { errors: shipment.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Shipment not found' }, status: :not_found
      end
      
      private
      
      def set_order
        @order = Order.find(params[:order_id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end
      
      def shipment_params
        params.permit(:tracking_number, :carrier, :status)
      end
    end
  end
end