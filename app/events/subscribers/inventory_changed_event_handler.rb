module Events
    module Subscribers
      class InventoryChangedEventHandler
        def handle(event)
          # If inventory drops to zero, we might need to handle pending orders
          if event["new_quantity"] == 0
            LineItem.where(product_id: event["product_id"]).includes(:order).each do |line_item|
              if line_item.order.created_status?
                # Flag orders that have out-of-stock products
                line_item.order.update(notes: "Product #{event['product_id']} is out of stock")
              end
            end
          end
        end
      end
    end
  end