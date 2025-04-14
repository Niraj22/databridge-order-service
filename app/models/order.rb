class Order < ApplicationRecord
    # Enums
    enum status: { 
      created: 0, 
      processing: 1, 
      fulfilled: 2, 
      canceled: 3 
    }, _suffix: true
  
    # Associations
    has_many :line_items, dependent: :destroy
    has_many :payments, dependent: :destroy
    has_many :shipments, dependent: :destroy
    
    # Validations
    validates :customer_id, presence: true
    validates :status, inclusion: { in: statuses.keys }
    validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
    
    # Scopes
    scope :recent, -> { order(created_at: :desc) }
    scope :by_status, ->(status) { where(status: status) if status.present? }
    scope :by_customer, ->(customer_id) { where(customer_id: customer_id) if customer_id.present? }
    
    # Callback to publish events
    after_create :publish_created_event
    after_update :publish_updated_event, if: :saved_change_to_status?
    
    # Methods
    def calculate_total
      self.total_amount = line_items.sum(&:total_price)
      save
    end
    
    def publish_created_event
      event_data = {
        id: id,
        customer_id: customer_id,
        status: status,
        total_amount: total_amount,
        created_at: created_at.iso8601
      }
      
      publisher = DataBridgeShared::Clients::EventPublisher.new
      publisher.publish('OrderCreated', event_data)
    end
    
    def publish_updated_event
      event_data = {
        id: id,
        customer_id: customer_id,
        status: status,
        previous_status: status_before_last_save,
        updated_at: updated_at.iso8601
      }
      
      publisher = DataBridgeShared::Clients::EventPublisher.new
      publisher.publish('OrderStatusChanged', event_data)
    end
  end