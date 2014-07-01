# == Schema Information
#
# Table name: domino_connections
#
#  id               :integer          not null, primary key
#  domino_server_id :integer
#  date             :datetime
#  connection_type  :string(255)
#  ip               :string(255)
#  user             :string(255)
#  action           :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class DominoConnection < ActiveRecord::Base
  validates_uniqueness_of :user, scope: [:domino_server_id, :date, :connection_type]
end
