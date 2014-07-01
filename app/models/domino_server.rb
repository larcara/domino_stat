# == Schema Information
#
# Table name: domino_servers
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  ip            :string(255)
#  ldap_port     :string(255)
#  ldap_ssl      :boolean
#  ldap_username :string(255)
#  ldap_password :string(255)
#  ldap_treebase :string(255)
#  ldap_hostname :string(255)
#  ldap_filter   :string(255)
#  ssh_user      :string(255)
#  ssh_password  :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  tail_status   :string(255)
#  enabled_tail  :boolean
#  enabled_auth  :boolean
#

class DominoServer < ActiveRecord::Base
  # include Mongoid::Document
  # field :name, type: String
  # field :ip, type: String
  # field :ldap_port, type: String
  # field :ldap_ssl, type: String
  # field :ldap_username, type: String
  # field :ldap_password, type: BSON::Binary
  # field :ldap_treebase, type: String
  # field :ldap_hostname, type: String
  # field :ldap_filter, type: String
  # field :ssh_user, type: String
  # field :ssh_password, type: BSON::Binary



  has_many :names_entries
  has_many :domino_messages
  has_many :domino_connections
  has_many :domino_locks

  attr_encrypted :ldap_pwd, :key => "secret_key", :attribute => 'ldap_password'
  attr_encrypted :ssh_pwd, :key => "secret_key", :attribute => 'ssh_password'

  scope :enabled_for_auth, where(:enabled_auth => true)
  scope :enabled_for_tail, where(:enabled_tail => true)


  def log_message(match_data, type)

    data={}
    match_data.names.each {|k| data[k.to_sym]=match_data[k]}
    message_date = DateTime.parse(data[:datetime])
    message_type=nil
    message_subtype=nil



    case type
      when :smtp_received
        #TODO - put in cache and update message_id usind notes msgid
        #@message=@server.log_message($LAST_MATCH_INFO, :smtp_received)
        #domino_messages.build(date: $~[:date], time: $~[:time], notes_message_id: $~[:msgid], messageid: $~[:messageid], smtp_from: $~[:smtp_from], size: $~[:size])
      when :msg_delivered
          message_type="IN"
          message=DominoMessage.new(domino_server_id: self.id, date: message_date ,notes_message_id: data[:msgid] ,mail_to: data[:mail_to], mail_from: data[:mail_from], size: data[:size])
      when :msg_forwarded
        message=DominoMessage.new(domino_server_id: self.id,date: message_date,notes_message_id: data[:msgid] , mail_to: data[:mail_to], mail_from: data[:mail_from])
          message_type="OUT"
          message_subtype="forwarded"
      when :msg_auto_forwarded
        message=DominoMessage.new(domino_server_id: self.id,date: message_date,notes_message_id: data[:msgid] , mail_to: data[:mail_to], mail_from: data[:mail_from])
          message_type="OUT"
          message_subtype="auto-forwarded"
      when :msg_transferred
          message_type="OUT"
          message=DominoMessage.new(domino_server_id: self.id,date: message_date,notes_message_id: data[:msgid] , mail_to: data[:mail_to], mail_from: data[:mail_from], mail_relay: data[:mail_relay], size: data[:size])
    end

    if message
    # monitored= [data[:mail_from],data[:mail_to]].map do |x|
    #   x=x.downcase
    #   DOMINO_STAT_CONFIG[:monitored_domains].map{|t|  x.end_with?(t) ? 1 : 0 }.sum
    # end.sum  if data[:mail_from]
    message.message_type=message_type
    message.domain_from=message.domain(message.mail_from)
    message.domain_to=message.domain(message.mail_to)

    message_subtype||="forwarded" if message.forwarded?
    message_subtype||="internal"  if message.internal?
    message_subtype||="generic"


    message.message_subtype=message_subtype
    message.save
    end
    message
  end



  def log_lock(match_data, type, date)
    data={}
    match_data.names.each {|k| data[k.to_sym]=match_data[k]}
    message_date = date
    dbname=data[:dbname].split("/").last
    @message=self.domino_locks.build(date: message_date, database_name: dbname , lock_type: data[:mode])
    @message.save
    counter=self.domino_locks.where(["domino_locks.date >= :date1 and domino_locks.date < :date2 and domino_locks.database_name=:database", date1: Date.today, date2: Date.tomorrow, database: dbname]).count

    log_notification(dbname, "#{counter} locks", counter, counter) if counter > 100 #TODO gestire il limite

  end

  def log_connection(match_data, type)
    data={}
    match_data.names.each {|k| data[k.to_sym]=match_data[k]}
    data[:user] ||= data[:ip_address]
    data[:action] ||= type.to_s
    message_date = DateTime.parse(data[:datetime])

    self.domino_connections.create(date: message_date,action: data[:action] , ip: data[:ip_address], user: data[:user])

    counter=self.domino_connections.where(["domino_connections.date >= :date1 and domino_connections.date < :date2 and domino_connections.ip=:ip", date1: Date.today, date2: Date.tomorrow, ip: data[:ip_address]]).count

    log_notification(data[:ip], "#{counter} Connection", counter, 100) if counter > 100 #TODO gestire il limite

    #@message=self.domino_connections.build()
    #@message.save
  end

  def log_notification(label, description, value, level)
    Notification.create(label: label, description: description, value: value, level: level, notification_type: "generic")

  end

  #todo transform to has_password :password_name_field, :key

  # def decrypt(field_name)
  #   #decrypted_value = Encryptor.decrypt(:value => self[field_name].data, :key => secret_key)
  #   decrypted_value = Encryptor.decrypt(:value => self.attribute(field_name), :key => secret_key)
  #   decrypted_value
  # end
  #
  # def ldap_password=(value)
  #   encrypted_value = Encryptor.encrypt(:value => value, :key => secret_key) unless value.blank?
  #   #self[:ldap_password]=BSON::Binary.new(encrypted_value)
  #   super(encrypted_value.encode('UTF-8'))
  # end
  #
  # def ssh_password=(value)
  #   encrypted_value = Encryptor.encrypt(:value => value, :key => secret_key) unless value.blank?
  #   #self[:ssh_password]=BSON::Binary.new(encrypted_value)
  #   super(encrypted_value.encode('UTF-8'))
  # end


  def import_contact_from_ldap(options={})#hostname, port, username, password, treebase="O=cameradep,C=IT")
    username=options[:username] || self.ldap_username
    password=options[:password] || self.ldap_pwd
    ldap=Net::LDAP.new(host: self.ldap_hostname,
                       port: self.ldap_port,
                       auth: {:method=> :simple,
                       username: username, password: password})
    ldap.encryption(:simple_tls) if self.ldap_port!="389"

    filter = Net::LDAP::Filter.construct(self.ldap_filter)
    found_ids=[]
    #MONGO
    self.names_entries.update_all(status: "cancelled")
    #ACTIVE RECORD

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

    end



  end

  def parse_line(line, options={})
    options[:datetime] ||= DateTime.now
    #TODO compose REGEXP
    domino_pid=/.{20}/

    log_timestamp=/(?<datetime>\d\d\/\d\d\/\d\d\d\d \d\d:\d\d:\d\d)/

    smtp_received=      /^#{domino_pid}#{log_timestamp}   SMTP Server: Message (?<msgid>.{8}) \(MessageID: (?<messageid>.*)\) received from (?<smtp_from>.*) size (?<size>\d*) bytes/
    msg_delivered=      /^#{domino_pid}#{log_timestamp}   Router: Message (?<msgid>.{8}|.{8}, .{8}) delivered to (?<mail_to>.*) from (?<mail_from>.*) .* .* Size: (?<size>.*) Time/
    msg_forwarded=      /^#{domino_pid}#{log_timestamp}   Router: Message (?<msgid>.{8}).* forwarded to (?<mail_to>.*) from (?<mail_from>.*) .* .*/
    msg_auto_forwarded= /^#{domino_pid}#{log_timestamp}   Router: Message (?<msgid>.{8}).* auto forwarded by (?<mail_from>.*) to (?<mail_to>.*)/
    msg_transferred=    /^#{domino_pid}#{log_timestamp}   Router: Message (?<msgid>.{8}).* transferred to (?<mail_relay>.*) for (?<mail_to>.*) from (?<mail_from>.*) .{10}:.{8} .{10}:.{8} Size: (?<size>.*) via SMTP/

    imap_connection=    /^#{domino_pid}#{log_timestamp}   IMAP Server: (?<ip_address>.*) (?<action>connected|disconnected)/
    imap_login=         /^#{domino_pid}#{log_timestamp}   IMAP Server: (?<user>.*) logged in from (?<ip_address>.*)/
    imap_logout=        /^#{domino_pid}#{log_timestamp}   IMAP Server: (?<user>.*) logged out/

    smtp_connected=     /^#{domino_pid}#{log_timestamp}   SMTP Server: (?<ip_address>.*) connected/
    smtp_disconnected=  /^#{domino_pid}#{log_timestamp}   SMTP Server: (?<ip_address>.*) disconnected. (?<messages>.*) message\[s\] received/

    smtp_login=         /^#{domino_pid}#{log_timestamp}   SMTP Server: Authentication succeeded for user (?<user>.*); connecting host (?<ip_address>.*)/
    smtp_login_error =  /^#{domino_pid}#{log_timestamp}   smtp: (?<username>.*) \[(?<ip>.*)\] authentication failure using internet password/
    smtp_mail_from_error =   /^#{domino_pid}#{log_timestamp}   SMTP Server: Message rejected. Authenticated user (?<username>.*) from host (?<ip>.*) sending mail from (?<err_mail_from>.*) failed to match directory address (?<mail_from>.*)/
    smtp_auth_error =   /^#{domino_pid}#{log_timestamp}   SMTP Server: Authentication failed for (?<username>.*) ; connecting host (?<ip>.*)/


    pop3_connection=    /^#{domino_pid}#{log_timestamp}   POP3 Server: (?<ip_address>.*) (?<action>connected|disconnected)/
    pop3_login=         /^#{domino_pid}#{log_timestamp}   POP3 Server: (?<user>.*) logged in; connecting host (?<ip_address>.*)/
    pop3_logout=        /^#{domino_pid}#{log_timestamp}   POP3 Server: (?<user>.*) logged out; connecting host (?<ip_address>.*)/


    recovery =          /^#{domino_pid}#{log_timestamp}   Recovery Manager: Restart Recovery complete. \((?<database_need_recovery>.*) databases needed full\/partial recovery\)/
    daos_out_of_sync=   /^#{domino_pid}#{log_timestamp} .* The DAOS catalog is not synchronized .*/

    starded=            /^#{domino_pid}#{log_timestamp}   (?<service>.*)started/

    prune =             /^#{domino_pid}#{log_timestamp}   DAOS Prune - Deleted (?<object_numbers>) objects and completed with error: (<?error_code>.*)/

    lockid=             /^#{domino_pid}Lock.*Mode=(?<mode>.*).*LockID.*DB.(?<dbname>.*)\)\).*/

    login_error =       /^#{domino_pid}#{log_timestamp}   Login failed for user (?<username>.*): Password not found.*/

    archived_message =  /^#{domino_pid}#{log_timestamp}   Archived .*,(?<archived>\d*) documents where archived and (?<deleted>\d*) where deleted/


    line=line.force_encoding('ISO-8859-1').encode('UTF-8')

    case line
      when smtp_received
        log_message($LAST_MATCH_INFO, :smtp_received)
        #domino_messages.build(date: $~[:date], time: $~[:time], notes_message_id: $~[:msgid], messageid: $~[:messageid], smtp_from: $~[:smtp_from], size: $~[:size])
      when msg_delivered
        log_message($LAST_MATCH_INFO, :msg_delivered)
        #@message=@server.domino_messages.build(date: $~[:date],notes_message_id: $~[:msgid] )
        #@message.update_attributes!( time: $~[:time], mail_to: $~[:mail_to], mail_from: $~[:mail_from], size: $~[:size])
      when msg_forwarded
        log_message($LAST_MATCH_INFO,:msg_forwarded)
        #@message=@server.domino_messages.build(date: $~[:date],notes_message_id: $~[:msgid] )
        #@message.update_attributes!( time: $~[:time], mail_to: $~[:mail_to], mail_from: $~[:mail_from])
      when msg_auto_forwarded
        log_message($LAST_MATCH_INFO,:msg_auto_forwarded)
        #@message=@server.domino_messages.build(date: $~[:date],notes_message_id: $~[:msgid] )
        #@message.update_attributes!( time: $~[:time], mail_to: $~[:mail_to], mail_from: $~[:mail_from])
      when msg_transferred
        log_message($LAST_MATCH_INFO,:msg_transferred)
        #@message=@server.domino_messages.build(date: $~[:date],notes_message_id: $~[:msgid] )
        #@message.update_attributes!( time: $~[:time], mail_to: $~[:mail_to], mail_from: $~[:mail_from], mail_relay: $~[:mail_relay], size: $~[:size])
      when imap_connection
        log_connection($LAST_MATCH_INFO, :imap_connection)
      when imap_login
        log_connection($LAST_MATCH_INFO, :imap_login)
      when imap_logout
        log_connection($LAST_MATCH_INFO,:imap_logout)
      when pop3_connection
        log_connection($LAST_MATCH_INFO, :pop3_connection)
      when pop3_login
        log_connection($LAST_MATCH_INFO, :pop3_login)
      when pop3_logout
        log_connection($LAST_MATCH_INFO,:pop3_logout)
      when smtp_connected
        log_connection($LAST_MATCH_INFO, :smtp_connected)
      when smtp_disconnected
        log_connection($LAST_MATCH_INFO, :smtp_disconnected)
      when smtp_login
        log_connection($LAST_MATCH_INFO,:smtp_login)



      when lockid
        log_lock($LAST_MATCH_INFO, :lockid, options[:datetime] )
      when recovery
        log_notification("recovery", $LAST_MATCH_INFO[:database_need_recovery], $LAST_MATCH_INFO[:database_need_recovery], 0)
      when daos_out_of_sync
        log_notification("daos_out_of_sync", "daos_out_of_sync", 0, 0)
      when starded
        log_notification($LAST_MATCH_INFO[:service], $LAST_MATCH_INFO[:datetime], $LAST_MATCH_INFO[:datetime], 0)
      when prune
        log_notification("prune status", "#{$LAST_MATCH_INFO[:object_numbers]} - #{$LAST_MATCH_INFO[:error_code]}", $LAST_MATCH_INFO[:object_numbers], 0)
      when login_error
        label="#{$LAST_MATCH_INFO[:username]} (imap)"
        n=Notification.where(["updated_at >= ? and label = ?", Date.today, label]).first
        n ||= Notification.create(label: label, notification_type: "login_error", value: 0)
        n.value+= 1
        n.description = label

        n.save
      when smtp_login_error
        label="#{$LAST_MATCH_INFO[:username]} from #{$LAST_MATCH_INFO[:ip]} (smtp)"
        n=Notification.where(["updated_at >= ? and label =?", Date.today, label]).first
        n ||= Notification.create(label: label, notification_type: "login_error", value: 0)
        n.value+= 1
        n.description = label
        n.save
      when smtp_auth_error
        label="#{$LAST_MATCH_INFO[:username]} from #{$LAST_MATCH_INFO[:ip]} (smtp)"
        n=Notification.where(["updated_at >= ? and label =?", Date.today, label]).first
        n ||= Notification.create(label: label, notification_type: "login_error", value: 0)
        n.value+= 1
        n.description = label
        n.save
      when prune
        log_notification("prune status", "#{$LAST_MATCH_INFO[:object_numbers]} - #{$LAST_MATCH_INFO[:error_code]}", $LAST_MATCH_INFO[:object_numbers], 0)
      else
        puts "NON GESTITA: #{line}"
    end
    #options[:datetime] = $LAST_MATCH_INFO[:datetime] if ( $LAST_MATCH_INFO && $LAST_MATCH_INFO.names.include?('datetime'))
  end

  private
  def secret_key
    "dasd asdas asfdfa fa wereaw fsdaf sdf wedsff weraf"
  end



end
