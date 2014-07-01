# == Schema Information
#
# Table name: domino_locks
#
#  id               :integer          not null, primary key
#  domino_server_id :integer
#  date             :datetime
#  database         :string(255)
#  lock_type        :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class DominoLock < ActiveRecord::Base
  belongs_to :domino_server
  validates_uniqueness_of :database_name, scope: [:domino_server_id, :date]
end
