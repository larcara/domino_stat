require 'net/ssh'
class DominoLog


  def initialize(server_id)
    @server=DominoServer.find(server_id)

    @domino_log=Net::SSH.start(@server.ip, @server.ssh_user, password: @server.decrypt(:ssh_password))
    @filename="stop_tail"
    File.delete(@filename) if File.exists?(@filename)
    File.write(@filename, '')
  end

  def tail_remote_log
    address={}
    counter=0
    time_start=Time.now
    puts "open channel at #{Time.now.to_s}"
    @domino_log.open_channel do |channel|
       channel.on_data do |ch, tail_data|
        tail_data.each_line do |line|
          parse_message_line (line)
        end
        ch.close unless IO.readlines(@filename).blank?
       end
      channel.on_close do |ch|
        #ch.send_data(3.chr)
        puts "channel closed successfully at #{Time.now.to_s}"
      end
      channel.exec "tail -f c*.out"
    end
    @domino_log.loop()
  end


  def stop_tail
    File.write(@filename, 'stop')
  end


  def parse_message_line(line, options={})

    #TODO - sostituire con un metodo che rilasci un array

    #A.	data{0} ora{1} Message {2} MessageID:{3} … received from {4} size {5} …
    smtp_received=      /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}) \(MessageID: (?<messageid>.*)\) received from (?<smtp_from>.*) size (?<size>\d*) bytes/
    msg_delivered=      /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}|.{8}, .{8}) delivered to (?<mail_to>.*) from (?<mail_from>.*) .* .* Size: (?<size>.*) Time/
    msg_forwarded=      /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}).* forwarded to (?<mail_to>.*) from (?<mail_from>.*) .* .*/
    msg_auto_forwarded= /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}).* auto forwarded by (?<mail_from>.*) to (?<mail_to>.*)/
    msg_transferred=    /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}).* transferred to (?<mail_relay>.*) for (?<mail_to>.*) from (?<mail_from>.*) .{10}:.{8} .{10}:.{8} Size: (?<size>.*) via SMTP/


    begin
      line=line.force_encoding('ISO-8859-1').encode('UTF-8')
      case line
        when smtp_received
          puts $LAST_MATCH_INFO
          @message=@server.domino_messages.build(date: $~[:date], time: $~[:time], msgid: $~[:msgid], messageid: $~[:messageid], smtp_from: $~[:smtp_from], size: $~[:size])
        when msg_delivered
          @message=@server.domino_messages.find_or_create_by(date: $~[:date],msgid: $~[:msgid] )
          @message.update_attributes!( time: $~[:time], mail_to: $~[:mail_to], mail_from: $~[:mail_from], size: $~[:size])
          puts $LAST_MATCH_INFO
        when msg_forwarded
          @message=@server.domino_messages.find_or_create_by(date: $~[:date],msgid: $~[:msgid] )
          @message.update_attributes!( time: $~[:time], mail_to: $~[:mail_to], mail_from: $~[:mail_from])
          puts $LAST_MATCH_INFO
        when msg_auto_forwarded
          @message=@server.domino_messages.find_or_create_by(date: $~[:date],msgid: $~[:msgid] )
          @message.update_attributes!( time: $~[:time], mail_to: $~[:mail_to], mail_from: $~[:mail_from])
          puts $LAST_MATCH_INFO
        when msg_transferred
          @message=@server.domino_messages.find_or_create_by(date: $~[:date],msgid: $~[:msgid] )
          @message.update_attributes!( time: $~[:time], mail_to: $~[:mail_to], mail_from: $~[:mail_from], mail_relay: $~[:mail_relay], size: $~[:size])
          puts $LAST_MATCH_INFO
        else
          puts "No Match"
      end

    #   if !(m=line.scan(smtp_received)[0]).blank?
    #     #A.	data{0} ora{1} Message {2} … received from {3} size {4} …
    #     x={data: m[0], time: m[1], msgid: m[2] , messageid: m[3] , smtp_from: m[4], message_type: "tipoA"}
    #   elsif !(m=line.scan(msg_tipo_b1)[0]).blank?
    #     #B.	data{0} ora{1} Message {2} delivered to {3} from {4}/cameradep/it  Size: {5} Time …..
    #     #TODO occorre modificare la regex per gestire m[4] cameradep/IT o camera/IT
    #     x={data: m[0], time: m[1], msgid: m[2], mail_to: m[3], mail_from:"#{m[4]}/cameradep/IT", size:m[5], message_type:"INTERNO via web" }
    #   elsif !(m=line.scan(msg_tipo_b2)[0]).blank?
    #     #B.	data{0} ora{1} Message {2} delivered to {3} from {4}/cameradep/it  Size: {5} Time …..
    #     #TODO occorre modificare la regex per gestire m[4] cameradep/IT o camera/IT
    #     x={data: m[0], time: m[1], msgid: m[2], mail_to: m[3], mail_from:"#{m[4]}/camera/IT", size:m[5], message_type:"INTERNO via web" }
    #   elsif !(m=line.scan(msg_tipo_c)[0]).blank?
    #     #C.	data{0} ora{1} Message {2} delivered to {3} from {4}@camera.it Size: {5} Time …..
    #     #TODO occorre controllare se m[4] è un utente del server corrente per capire se è un messaggio interno o arriva dall'altro server domino
    #     x={data: m[0], time: m[1], msgid: m[2], mail_to: m[3], mail_from:"#{m[4]}@camera.it", size:m[5], message_type:"IN - DA DOMINIO CAMERA"}
    #     if x[:mail_to].downcase.include?("camera") && ACCOUNTS[x[:mail_to].downcase]==ACCOUNTS[x[:mail_from].to_s.downcase]#Account.where(:email => [x[:mail_to],x[:mail_from]]).count(:server) == 1
    #       x[:message_type]="INTERNO via smtp"
    #     end
    #   elsif !(m=line.scan(msg_tipo_c_s)[0]).blank?
    #     #C.	data{0} ora{1} Message {2} delivered to {3} from {4}@camera.it Size: {5} Time …..
    #     x={data: m[0], time: m[1], msgid: m[2], mail_to: m[3], mail_from:"#{m[4]}@senato.it", size:m[5], message_type:"IN - DA DOMINIO SENATO"}
    #   elsif !(m=line.scan(msg_tipo_d)[0]).blank?
    #     #D.	data{0} ora{1} Message {2} delivered to {3} from {4}  Size: {5} Time …..
    #     x={data: m[0], time: m[1], msgid: m[2], mail_to: m[3], mail_from:m[4], size:m[5], message_type:"IN - DA INTERNET" }
    #     unless x[:mail_from].include?("@")
    #       #x[:mail_from]="#{x[:mail_from]}"
    #       x[:message_type]="INTERNO via smtp"
    #     end
    #
    #
    #   elsif !(m=line.scan(msg_tipo_e)[0]).blank?
    #     #E.	data{0} ora{1} Message {2} forwarded to {3} from {4}
    #     x={data: m[0], time: m[1], msgid: m[2], mail_to: m[3], mail_from:m[4], message_type:"FORWARDED" }
    #   elsif !(m=line.scan(msg_tipo_f)[0]).blank?
    #     #F.	data{0} ora{1} Message {2} auto forwarded by {3} to {4}
    #     x={data: m[0], time: m[1], msgid: m[2], mail_to: m[4], mail_from:"#{m[3]}@camera.it", forward_by_rule: "1", message_type:"FORWARDED by Rule" }
    #   elsif !(m=line.scan(msg_tipo_g)[0]).blank?
    #     #G.	data{0} ora{1} Message {2} transferred to {3} for {4}@camera.it from {5} Size {6} via SMTP
    #     x={data: m[0], time: m[1], msgid: m[2], mail_relay:m[3], mail_to: "#{m[4]}@camera.it", mail_from:m[5], size:m[6], message_type:"OUT - VERSO DOMINIO CAMERA" }
    #   elsif !(m=line.scan(msg_tipo_g_s)[0]).blank?
    #     #G.	data{0} ora{1} Message {2} transferred to {3} for {4}@camera.it from {5} Size {6} via SMTP
    #     x={data: m[0], time: m[1], msgid: m[2], mail_relay:m[3], mail_to: "#{m[4]}@senato.it", mail_from:m[5], size:m[6], message_type:"OUT - VERSO DOMINIO SENATO" }
    #   elsif !(m=line.scan(msg_tipo_h)[0]).blank?
    #     #H.	data{0} ora{1} Message {2} transferred to {3} for {4} from {5} Size {6} via SMTP
    #     x={data: m[0], time: m[1], msgid: m[2], mail_relay:m[3], mail_to: m[4], mail_from:m[5], size:m[6], message_type:"OUT - VERSO INTERNET" }
    #   else
    #     x=nil
    #   end
    #   if x
    #     x[:data]=Date.strptime(x[:data].strip, '%d/%m/%Y')
    #     x[:time]=DateTime.strptime(x[:time].strip, '%H:%M:%S')
    #
    #     x[:to_type]=ACCOUNTS[x[:mail_to].to_s.downcase][:level0] if ACCOUNTS[x[:mail_to].to_s.downcase]
    #     x[:from_type]=ACCOUNTS[x[:mail_from].to_s.downcase][:level0] if ACCOUNTS[x[:mail_from].to_s.downcase]
    #
    #     if x[:size].to_s.include?("K")
    #       x[:size]=x[:size].to_i * 1024
    #     end
    #   end
    #   return x
     rescue Exception => e
       puts "Errore su #{line}"
       puts e
     end
  end
end


