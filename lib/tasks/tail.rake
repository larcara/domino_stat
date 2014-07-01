
desc "manual parse log file on single sever. Call with DOMINO_SERVER_ID=x DOMINO_LOG_FILE=x"
task :parse_log_file => :environment do
  domino_log = DominoLog.new(ENV["DOMINO_SERVER_ID"])
  domino_log.parse_log_file(ENV["DOMINO_LOG_FILE"]||"console*.out")
end


desc "manual start tail on single sever. Call with DOMINO_SERVER_ID=x"
task :start_tail => :environment do
  domino_log = DominoLog.new(ENV["DOMINO_SERVER_ID"])
  domino_log.do_tail
end


desc "manual stop tail on single sever. Call with DOMINO_SERVER_ID=x"
task :stop_tail => :environment do
  DominoServer.find(ENV["DOMINO_SERVER_ID"]).update_attribute(:tail_status, "")
end


desc "start tail on all server"
task :start_all_tail => :environment do
  DominoServer.enabled_for_tail.each  do |d|
    domino_log = DominoLog.new(d.id)
    domino_log.do_tail
  end
end

desc "stop all tail"
task :stop_all_tail => :environment do
  DominoServer.all.each  do |d|
    d.update_attribute(:tail_status, "")
  end
end