require 'net/ssh'
class DominoLog


  def initialize(server_id)
    @server=DominoServer.find(server_id)

    @domino_log=Net::SSH.start(@server.ip, @server.ssh_user, password: @server.ssh_pwd)
    @filename="stop_tail"

    File.delete(@filename) if File.exists?(@filename)
    File.write(@filename, '')
    @domino_log
  end

  def do_tail
    #TODO - recuperare gli id dei processi da filtrare e/o da escludere
    address={}
    counter=0
    time_start=Time.now
    @pid=""
    @server.update_attribute(:tail_status, "#{time_start}")
    @domino_log.exec!("tail -f c*.out") do |channel|

       channel.on_data do |ch, tail_data|
        tail_data.each_line do |line|
          parse_message_line (line)
        end
        @server.reload
        if @server.tail_status != "#{time_start}"
           pid=@domino_log.exec!("ps -ae | grep tail").to_s.to_i
           puts pid
           puts "close!!!"
           #@domino_log.exec!("kill -9 #{pid}") if pid==@pid
          ch.close
        end
       end
      channel.on_close do |ch|
        #ch.send_data(3.chr)
        puts "channel closed successfully at #{Time.now.to_s}"
      end
    end
    @pid=@domino_log.exec!("ps -ae | grep tail").to_s.to_i
    puts @pid
    @domino_log.loop()
    return  "tail on #{@server.ip} started at at #{time_start}"
  end

  def parse_local_log_file( filepath)
    #TODO - recuperare gli id dei processi da filtrare e/o da escludere
    address={}
    counter=0
    time_start=Time.now
    datetime=nil
    puts "START ANALYSYS ON #{filepath}"
    logfile = File.open(filepath  ).each do |line|
        matchdata = line.match(/^.{20}(?<datetime>\d\d\/\d\d\/\d\d\d\d \d\d:\d\d:\d\d).*/)
        datetime = DateTime.parse(matchdata[:datetime]) if matchdata
        parse_message_line(line, {datetime: datetime})
      end




  end

  def parse_log_file(filepath)
    #TODO - recuperare gli id dei processi da filtrare e/o da escludere
    address={}
    counter=0
    time_start=Time.now
    datetime=nil
    puts "START ANALYSYS ON #{filepath}"
    tot_lines=@domino_log.exec!("wc -l #{filepath}").to_i
    puts "il file ha #{tot_lines} linee"
    block_lines=10000
    1.step(tot_lines,block_lines) do |x|
      puts "in estrazione dalla linea #{x}"
      data= @domino_log.exec!("sed -n '#{x},#{x+block_lines}p' #{filepath}")
        data.each_line do |line|
          matchdata = line.match(/^.{20}(?<datetime>\d\d\/\d\d\/\d\d\d\d \d\d:\d\d:\d\d).*/)
          datetime = DateTime.parse(matchdata[:datetime]) if matchdata
          parse_message_line(line, {datetime: datetime})
        end

    end


  end

  def stop_tail
    @domino_log.exec("")
    @server.update_attribute(:tail_status, "")
  end


  def parse_message_line(line, options={})

    if line.end_with?("\n")
      #se è una linea che termina con /r prendo il buffer precedente e svuoto il buffer
      line="#{@line}#{line}"
      unless @line.blank?
        puts "##################### "
        puts "##################### linea ricostruita: #{line}"
        puts "##################### "
      end
      @line=""

    else
      @line=line
      line=""
      puts "linea tronca: #{@line}"
    end
    return if line==""
    # #A.	data{0} ora{1} Message {2} MessageID:{3} … received from {4} size {5} …
    # smtp_received=      /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}) \(MessageID: (?<messageid>.*)\) received from (?<smtp_from>.*) size (?<size>\d*) bytes/
    # msg_delivered=      /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}|.{8}, .{8}) delivered to (?<mail_to>.*) from (?<mail_from>.*) .* .* Size: (?<size>.*) Time/
    # msg_forwarded=      /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}).* forwarded to (?<mail_to>.*) from (?<mail_from>.*) .* .*/
    # msg_auto_forwarded= /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}).* auto forwarded by (?<mail_from>.*) to (?<mail_to>.*)/
    # msg_transferred=    /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d).*:.* Message (?<msgid>.{8}).* transferred to (?<mail_relay>.*) for (?<mail_to>.*) from (?<mail_from>.*) .{10}:.{8} .{10}:.{8} Size: (?<size>.*) via SMTP/
    #
    # imap_connection=    /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d)   IMAP Server: (?<ip_address>.*) (?<action>connected|disconnected)/
    # imap_login=         /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d)   IMAP Server: (?<user>.*) logged in from (?<ip_address>.*)/
    # imap_logout=        /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d)   IMAP Server: (?<user>.*) logged out/
    #
    scartate=[]
    scartate << /(?<service>AMgr:|Updating|SMTP Server: Recipient:|SMTP Server: Originator:|Full text|Opened|Closed|SchedMgr|RnRMgr|Agent Printing:).*/
    scartate << /\d* documents .* indexed in .*/
    scartate << /^.{20}(?<date>\d\d\/\d\d\/\d\d\d\d) (?<time>\d\d:\d\d:\d\d.\d\d) (?<service>SMTP).*/
    scartate << /Recipient in local Internet Domain not found, forwarding to Smart Host/
    scartate << /Router: Delivery thread .* searching for work/
    scartate << /Router: Transfer thread .* searching for work/
    scartate << /Router: Delivery to local recipient .* is ready with .* messages/
    scartate << /Router: Transferring mail to domain .* via SMTP/
    scartate << /Router: Transferred .* messages to .* via SMTP/
    scartate << /Router: Transfer to server .* is ready with .* messages/
    #
    # NON GESTITA: [12209:00021-00015] 27/06/2014 09:45:09    [00000015]
    # lockid= /^.{20}Lock.*Mode=(?<mode>.*).*LockID.*DB.(?<dbname>.*)\)\).*/
#"SMTP Server" | "Router" "POP3
# Error:
    #[21239:00025-00082] 13/06/2014 11:36:38   Note NT00078052 was not updated in the IMAP btree for folder (Sent) IMAPSent (NT00063532) in database /p101/dommsw01/notesdata/mail/pers_int/mail_r/romano_g.nsf.  Database should be re-enabled for IMAP support.
    #LkMgr BEGIN Long Held Lock Dump
   test = Regexp.union(scartate)
   # begin
      #line=line.force_encoding('ISO-8859-1').encode('UTF-8')
      case line
        when test

        else
         @server.parse_line line, options
      end
  end
end


