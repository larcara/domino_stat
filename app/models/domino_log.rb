require 'net/ssh'
class DominoLog


  def initialize(server_id)
    @server=DominoServer.find(server_id)

    @domino_log=Net::SSH.start(@server, user, password: password)
    @filename="stop_tail_#{domino_ip}"
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
          puts line
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

end

