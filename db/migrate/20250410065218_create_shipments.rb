class CreateShipments < ActiveRecord::Migration[7.1]
  def change
    create_table :shipments do |t|
      t.references :order, null: false, foreign_key: true
      t.string :tracking_number
      t.string :carrier
      t.integer :status

      t.timestamps
    end
  end
end
