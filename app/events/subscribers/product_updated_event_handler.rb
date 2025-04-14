module Events
    module Subscribers
      class ProductUpdatedEventHandler
        def handle(event)
          # If a product is deactivated, we might need to handle pending orders
          if event["active"] == false
            LineItem.where(product_id: event["id"]).includes(:order).each do |line_item|
              if line_item.order.created_status?
                # Flag orders that have inactive products
                line_item.order.update(notes: "Contains deactivated product: #{event['name']}")
              end
            end
          end
          
          # If price changed, we might want to log this for analytics
          if event["price"].present? && event["old_price"].present?
            Rails.logger.info("Product #{event['id']} price changed from #{event['old_price']} to #{event['price']}")
          end
        end
      end
    end
  end