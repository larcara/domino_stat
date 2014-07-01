# == Schema Information
#
# Table name: names_entries
#
#  id               :integer          not null, primary key
#  domino_server_id :integer
#  cn               :string(255)
#  lastname         :string(255)
#  firstname        :string(255)
#  mailserver       :string(255)
#  email            :string(255)
#  level0           :string(255)
#  level1           :string(255)
#  level2           :string(255)
#  level3           :string(255)
#  level4           :string(255)
#  uid              :string(255)
#  displayname      :string(255)
#  status           :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class NamesEntry < ActiveRecord::Base
  # include Mongoid::Document
  #
  # field :cn
  # field :firstname
  # field :lastname
  # field :email
  # field :mailserver
  # field :level0
  # field :level1
  # field :level2
  # field :level3
  # field :uid
  # field :displayname
  # field :status

  belongs_to :domino_server
end
