# == Schema Information
#
# Table name: domino_servers
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  ip         :string(255)
#  ldap_port  :string(255)
#  ldap_ssl   :boolean
#  created_at :datetime
#  updated_at :datetime
#

class DominoServer #< ActiveRecord::Base
  include Mongoid::Document
  field :name, type: String
  field :ip, type: String
  field :ldap_port, type: String
  field :ldap_ssl, type: String
  field :ldap_username, type: String
  field :ldap_password, type: BSON::Binary
  field :ldap_treebase, type: String
  field :ldap_hostname, type: String
  field :ldap_auth_method, type: String
  field :ldap_filter, type: String


  has_many :names_entries


  #todo transform to has_password :password_name_field, :key
  def ldap_password
    puts "password is encripted !!"
    self[:ldap_password]
  end
  def decrypted_ldap_password
    decrypted_value = Encryptor.decrypt(:value => self.ldap_password.data, :key => secret_key)
    puts "password is decrypted !!"
    decrypted_value
  end

  def ldap_password=(value)
    encrypted_value = Encryptor.encrypt(:value => value, :key => secret_key) unless value.blank?
    self[:ldap_password]=BSON::Binary.new(encrypted_value)
  end
  private
  def secret_key
    "dasd asdas asfdfa fa wereaw fsdaf sdf wedsff weraf"
  end

  def ldap_new_password

  end
  def ldap_new_password=(value)
    self.settings(:ldap).password=value unless value.blank?
  end

  def import_contact_from_ldap(options={})#hostname, port, username, password, treebase="O=cameradep,C=IT")
    username=options[:username] || self.ldap_username
    password=options[:password] || self.decrypted_ldap_password
    ldap=Net::LDAP.new(host: self.ldap_hostname,
                       port: self.ldap_port,
                       auth: {:method=> self.ldap_auth_method.to_sym,
                       username: username, password: password})
    ldap.encryption(:simple_tls) if self.ldap_port!="389"

    filter = Net::LDAP::Filter.construct(self.ldap_filter)
    found_ids=[]
    ldap.search(:base => self.ldap_treebase, :filter => filter) do |entry|
      attrib={}
      attrib[:cn]=entry[:cn].last
      attrib[:firstname]=entry[:sn].last
      attrib[:lastname]=entry[:givenname].last
      attrib[:email]=entry[:mail].last
      attrib[:mailserver]=entry[:mailserver].last.to_s.downcase
      #if deleted[attrib[:server]].blank?
      # Account.update_all(server: attrib[:server], level0: 'cancellato')
      #  deleted[attrib[:server]]=true
      #end
      attrib[:level0]=entry[:level0].last
      attrib[:level1]=entry[:level1].last
      attrib[:level2]=entry[:level2].last
      attrib[:level3]=entry[:level3].last.gsub(/[!\W]/,"") if entry[:level3].last
      attrib[:uid]=entry[:uid].last
      attrib[:displayname]=entry[:displayname].last

      #unless entry[:email].blank?

      a=self.names_entries.where(email: attrib[:email]).first
      a||=self.names_entries.build(email: attrib[:email])
      a.attributes= attrib
      a.status="active"
      a.save
      found_ids << a.id
    end
    self.names_entries.where(["id not in (?)", found_ids]).update_all("status='cancelled'")
  end
end
