class CreateNamesEntries < ActiveRecord::Migration
  def change
    create_table :names_entries do |t|
      t.integer :domino_server_id
      t.string :cn
      t.string :lastname
      t.string :firstname
      t.string :email
      t.string :mailserver
      t.string :level0
      t.string :level1
      t.string :level2
      t.string :level3
      t.string :level4
      t.string :uid
      t.string :displayname
      t.string :status



      t.timestamps
    end
  end
end
