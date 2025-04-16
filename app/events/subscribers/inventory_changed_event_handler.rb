# app/events/subscribers/inventory_changed_event_handler.rb
module Events
  module Subscribers
    class InventoryChangedEventHandler
      def handle(event)
        Rails.logger.info("Received InventoryChanged event: #{event.inspect}")
        
        # Only process if inventory has dropped to zero
        return unless event["new_quantity"] == 0
        
        # Find all line items for the affected product
        line_items = LineItem.where(product_id: event["product_id"]).includes(:order)
        
        # Skip if no line items are affected
        return if line_items.empty?
        
        # Update orders that are still in created status
        count = 0
        line_items.each do |line_item|
          if line_item.order.created_status?
            line_item.order.update(notes: "Product #{event['product_id']} is out of stock")
            count += 1
          end
        end
        
        Rails.logger.info("Updated #{count} orders affected by out-of-stock product #{event['product_id']}")
      end
    end
  end
end