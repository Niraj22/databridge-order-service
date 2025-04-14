class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments do |t|
      t.references :order, null: false, foreign_key: true
      t.decimal :amount
      t.integer :payment_method
      t.integer :status
      t.string :transaction_id

      t.timestamps
    end
  end
end
