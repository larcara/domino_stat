class CreateDominoServers < ActiveRecord::Migration
  def change
    create_table :domino_servers do |t|
      t.string :name
      t.string :ip
      t.string :ldap_port
      t.boolean :ldap_ssl
      t.string :ldap_username
      t.string :ldap_password
      t.string :ldap_treebase
      t.string :ldap_hostname
      t.string :ldap_filter
      t.string :ssh_user
      t.string :ssh_password
      t.timestamps
    end
  end
end
