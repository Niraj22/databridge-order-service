class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.integer :customer_id
      t.integer :status
      t.decimal :total_amount
      t.text :notes

      t.timestamps
    end
  end
end
