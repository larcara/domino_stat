# == Schema Information
#
# Table name: notifications
#
#  id          :integer          not null, primary key
#  panel       :string(255)
#  label       :string(255)
#  description :string(255)
#  value       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  status      :string(255)
#  level       :integer
#

class Notification < ActiveRecord::Base
  #TODO definire un notification Type (Alert, Message, info, task)
  scope :messages, -> {where(level: 0)}
  scope :alerts, -> {where(level: 999)}
  scope :login_errors, -> {where(notification_type: "login_error")}
end
