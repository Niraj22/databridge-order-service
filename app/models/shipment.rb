class Shipment < ApplicationRecord
  # Enums
  enum status: { 
    pending: 0, 
    shipped: 1, 
    delivered: 2, 
    returned: 3 
  }, _suffix: true
  
  # Associations
  belongs_to :order
  
  # Validations
  validates :status, inclusion: { in: statuses.keys }
  
  # Callbacks
  after_save :publish_shipment_event, if: :saved_change_to_status?
  
  # Methods
  def publish_shipment_event
    event_data = {
      id: id,
      order_id: order_id,
      tracking_number: tracking_number,
      carrier: carrier,
      status: status,
      updated_at: updated_at.iso8601
    }
    
    publisher = DataBridgeShared::Clients::EventPublisher.new
    publisher.publish('ShipmentUpdated', event_data)
    
    # Update order status if shipment is delivered
    if delivered_status? && order.processing_status?
      order.update(status: :fulfilled)
    end
  end
end