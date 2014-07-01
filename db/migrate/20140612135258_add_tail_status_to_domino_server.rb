class AddTailStatusToDominoServer < ActiveRecord::Migration
  def change
    add_column :domino_servers, :tail_status, :string
  end
end
