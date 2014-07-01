class AddFiled1ToDominoServer < ActiveRecord::Migration
  def change
    add_column :domino_servers, :enabled_tail, :boolean
    add_column :domino_servers, :enabled_auth, :boolean
  end
end
