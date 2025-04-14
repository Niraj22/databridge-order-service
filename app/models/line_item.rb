class LineItem < ApplicationRecord
  # Associations
  belongs_to :order
  
  # Validations
  validates :product_id, presence: true
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  
  # Callbacks
  before_validation :calculate_total_price
  after_save :update_order_total
  after_destroy :update_order_total
  
  # Methods
  def calculate_total_price
    self.total_price = quantity * unit_price if quantity.present? && unit_price.present?
  end
  
  def update_order_total
    order.calculate_total
  end
end