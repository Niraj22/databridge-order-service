# app/events/subscribers/product_updated_event_handler.rb
module Events
  module Subscribers
    class ProductUpdatedEventHandler
      def handle(event)
        Rails.logger.info("Received ProductUpdated event: #{event.inspect}")
        
        # Process deactivated products
        process_deactivated_product(event) if event["active"] == false
        
        # Log price changes for analytics
        log_price_changes(event) if event["price"].present? && event["old_price"].present?
      end
      
      private
      
      def process_deactivated_product(event)
        # Find all line items for the deactivated product
        line_items = LineItem.where(product_id: event["id"]).includes(:order)
        
        # Skip if no line items are affected
        return if line_items.empty?
        
        # Update orders that are still in created status
        count = 0
        line_items.each do |line_item|
          if line_item.order.created_status?
            line_item.order.update(notes: "Contains deactivated product: #{event['name']}")
            count += 1
          end
        end
        
        Rails.logger.info("Updated #{count} orders affected by deactivated product #{event['id']}")
      end
      
      def log_price_changes(event)
        Rails.logger.info("Product #{event['id']} price changed from #{event['old_price']} to #{event['price']}")
      end
    end
  end
end