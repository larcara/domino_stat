class CreateDominoServers < ActiveRecord::Migration
  def change
    create_table :domino_servers do |t|
      t.string :name
      t.string :ip
      t.string :ldap_port
      t.boolean :ldap_ssl

      t.timestamps
    end
  end
end
