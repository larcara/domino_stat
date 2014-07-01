class AddMessageSubTypeToDominoMessage < ActiveRecord::Migration
  def change
    add_column :domino_messages, :message_subtype, :string
  end
end
