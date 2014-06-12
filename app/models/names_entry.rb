class NamesEntry #< ActiveRecord::Base
  include Mongoid::Document

  field :cn
  field :firstname
  field :lastname
  field :email
  field :mailserver
  field :level0
  field :level1
  field :level2
  field :level3
  field :uid
  field :displayname
  field :status

  belongs_to :domino_server
end
