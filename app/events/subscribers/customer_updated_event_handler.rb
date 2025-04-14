module Events
    module Subscribers
      class CustomerUpdatedEventHandler
        def handle(event)
          # Event handling logic here
          Rails.logger.info("Received CustomerUpdated event: #{event.inspect}")
          
          # If a customer is deactivated, handle pending orders
          if event["status"] == "inactive"
            Order.where(customer_id: event["id"], status: [:created, :processing]).find_each do |order|
              order.update(notes: "Customer was deactivated")
            end
          end
        end
      end
    end
  end