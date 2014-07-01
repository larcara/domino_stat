class AddField2ToDominoMessage < ActiveRecord::Migration
  def change
    add_column :domino_messages, :domain_from, :string
    add_column :domino_messages, :domain_to, :string
  end
end
