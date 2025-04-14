module Api
  module V1
    class OrdersController < ApplicationController
      before_action :set_order, only: [:show, :update, :destroy]
      
      def index
        orders = Order.all
        orders = apply_filters(orders)
        
        render json: paginate(orders)
      end
      
      def show
        render json: @order.as_json(include: [:line_items, :payments, :shipments])
      end
      
      def create
        order = Order.new(order_params)
        
        # Add line items
        if params[:line_items].present?
          params[:line_items].each do |item|
            order.line_items.build(
              product_id: item[:product_id],
              quantity: item[:quantity],
              unit_price: item[:unit_price],
              total_price: item[:quantity] * item[:unit_price]
            )
          end
        end
        
        if order.save
          # Order was created successfully
          render json: order, status: :created
        else
          render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def update
        if @order.update(order_update_params)
          render json: @order
        else
          render json: { errors: @order.errors.full_messages }, status: :unprocessable_entity
        end
      end
      
      def destroy
        @order.update(status: :canceled)
        head :no_content
      end
      
      private
      
      def set_order
        @order = Order.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Order not found' }, status: :not_found
      end
      
      def order_params
        params.permit(:customer_id, :status, :total_amount)
      end
      
      def order_update_params
        params.permit(:status)
      end
      
      def apply_filters(orders)
        orders = orders.by_status(params[:status])
        orders = orders.by_customer(params[:customer_id])
        
        if params[:start_date].present? && params[:end_date].present?
          orders = orders.where(created_at: params[:start_date]..params[:end_date])
        end
        
        if params[:sort_by].present?
          direction = params[:sort_direction] == 'desc' ? :desc : :asc
          orders = orders.order(params[:sort_by] => direction)
        else
          orders = orders.recent
        end
        
        orders
      end
      
      def paginate(orders)
        page = (params[:page] || 1).to_i
        per_page = (params[:per_page] || 20).to_i
        
        orders.page(page).per(per_page)
      end
    end
  end
end