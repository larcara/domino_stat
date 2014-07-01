class CreateDominoLocks < ActiveRecord::Migration
  def change
    create_table :domino_locks do |t|
      t.integer :domino_server_id
      t.datetime :date
      t.string :database_name
      t.string :lock_type

      t.timestamps
    end
  end
end
