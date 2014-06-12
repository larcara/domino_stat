class DominoMessage #< ActiveRecord::Base
  include Mongoid::Document

  field :date,  type: Date
  field :time,  type: Time
  field :msgid,  type: String
  field :mail_from,  type: String
  field :mail_to,  type: String
  field :size,  type: String
  field :smtp_from,  type: String
  field :mail_relay,  type: String
  field :forward_by_rule,  type: String
  field :message_type,  type: String
  field :from_type,  type: String
  field :to_type,  type: String
  field :subject,  type: String
  field :notes,  type: String
  field :messageid,  type: String

  belongs_to :domino_server

end
