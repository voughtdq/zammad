class AddInternalFieldToTicket < ActiveRecord::Migration[6.0]
  def change
    add_column :tickets, :internal, :boolean, default: false, null: false
    add_index :tickets, :internal
  end
end
