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

class DominoServer < ActiveRecord::Base

  has_many :names_entries

  has_settings :class_name => 'DominoServerSettingObject'  do |s|
    s.key :ldap, :defaults => { username: '', password: '', treebase: 'ou=OrganizationUnit,dc=Domain,C=IT', hostname: '127.0.0.7', port: "389", auth_method: "simple", filter: "(mail=*)"}
    s.key :calendar,  :defaults => { :scope => 'company'}
  end


  def self.settings_attr_accessor(*args)
    args.each do |arg|
      puts "||||||#{arg.class}"
      puts "||||||#{arg.inspect}"
      if arg.is_a?(Hash)
        arg.each { |k,v| v.each{ |method_name| settings_create_attr_accessor(method_name, k)}}
      end
      settings_create_attr_accessor(arg) if arg.is_a?(Symbol)
      end
  end
  def self.settings_create_attr_accessor(method_name, group=nil)
    setting_name= group ? "settings(:#{group})" : "settings"
    _method_name= group ? "#{group}_#{method_name}" : method_name

    eval "
        def #{_method_name}
          self.#{setting_name}.send(:#{method_name})
        end
        def #{_method_name}=(value)
          self.#{setting_name}.send(:#{method_name}=, value)
        end
      "
  end
  settings_attr_accessor ldap: [:treebase, :hostname, :port, :auth_method, :filter, :username, :password]

  def ldap_new_password

  end
  def ldap_new_password=(value)
    self.settings(:ldap).password=value unless value.blank?
  end

  def import_contact_from_ldap(options={})#hostname, port, username, password, treebase="O=cameradep,C=IT")
    username=options[:username] || self.settings(:ldap).username
    password=options[:password] || self.settings(:ldap).decrypted_password
    ldap=Net::LDAP.new(host: self.settings(:ldap).hostname,
                       port: self.settings(:ldap).port,
                       auth: {:method=> self.settings(:ldap).auth_method.to_sym,
                       username: username, password: password})
    ldap.encryption(:simple_tls) if self.settings(:ldap).port!="389"

    filter = Net::LDAP::Filter.construct(self.settings(:ldap).filter)
    found_ids=[]
    ldap.search(:base => self.settings(:ldap).treebase, :filter => filter) do |entry|
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
