class NamesEntry #< ActiveRecord::Base
  include Mongoid::Document
  belongs_to :domino_server
end
