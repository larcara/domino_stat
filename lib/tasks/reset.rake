desc "reset dayly data"
task :reset_today_data => :environment do
  DominoLock.where(["updated_at < ?", Date.today]).delete_all
  DominoConnection.where(["updated_at < ?", Date.today]).delete_all
  Notification.where(["updated_at < ?", Date.today]).delete_all
end

