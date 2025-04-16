# app/events/subscribers/customer_updated_event_handler.rb
module Events
  module Subscribers
    class CustomerUpdatedEventHandler
      def handle(event)
        Rails.logger.info("Received CustomerUpdated event: #{event.inspect}")
        
        # Only process if the customer status is inactive
        return unless event["status"] == "inactive"
        
        # Find affected orders
        affected_orders = Order.where(
          customer_id: event["id"], 
          status: [:created, :processing]
        )
        
        # Skip processing if no orders are affected
        return if affected_orders.empty?
        
        # Update all affected orders
        count = 0
        affected_orders.find_each do |order|
          order.update(notes: "Customer was deactivated")
          count += 1
        end
        
        Rails.logger.info("Updated #{count} orders for deactivated customer #{event['id']}")
      end
    end
  end
end