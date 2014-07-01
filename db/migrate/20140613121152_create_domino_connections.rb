class CreateDominoConnections < ActiveRecord::Migration
  def change
    create_table :domino_connections do |t|
      t.integer :domino_server_id
      t.datetime :date
      t.string :connection_type
      t.string :ip
      t.string :user
      t.string :action

      t.timestamps
    end
  end
end
