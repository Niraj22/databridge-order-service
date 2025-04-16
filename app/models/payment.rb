class Payment < ApplicationRecord
  # Enums
  enum status: { 
    pending: 0, 
    completed: 1, 
    failed: 2 
  }, _suffix: true
  
  enum payment_method: {
    credit_card: 0,
    paypal: 1,
    bank_transfer: 2
  }, _suffix: true
  
  # Associations
  belongs_to :order
  
  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_method, inclusion: { in: payment_methods.keys }
  validates :status, inclusion: { in: statuses.keys }
  
  # Callbacks
  after_save :publish_payment_event, if: :saved_change_to_status?
  
  # Methods
  def publish_payment_event
    event_data = {
      id: id,
      order_id: order_id,
      amount: amount,
      payment_method: payment_method,
      status: status,
      processed_at: updated_at.iso8601
    }
    
    kafka_config = Rails.application.credentials.kafka
    publisher = DataBridgeShared::Clients::EventPublisher.new(
      seed_brokers: kafka_config[:brokers],
      client_id: kafka_config[:client_id]
    )
    publisher.publish('PaymentProcessed', event_data)
    
    # Update order status if payment is completed or failed
    if completed_status?
      order.update(status: :processing)
    elsif failed_status?
      # You might want different behavior here
      order.update(status: :canceled)
    end
  end
end