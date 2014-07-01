# == Schema Information
#
# Table name: domino_messages
#
#  id               :integer          not null, primary key
#  date             :datetime
#  domino_server_id :integer
#  messageid        :string(255)
#  notes_message_id :string(255)
#  mail_from        :string(255)
#  mail_to          :string(255)
#  size             :integer
#  smtp_from        :string(255)
#  mail_relay       :string(255)
#  forward_by_rule  :string(255)
#  message_type     :string(255)
#  subject          :string(255)
#  notes            :text
#  created_at       :datetime
#  updated_at       :datetime
#  message_subtype  :string(255)
#  domain_from      :string(255)
#  domain_to        :string(255)
#

class DominoMessage < ActiveRecord::Base
  # include Mongoid::Document
  #
  # field :date,  type: Date
  # field :time,  type: Time
  # field :msgid,  type: String
  # field :mail_from,  type: String
  # field :mail_to,  type: String
  # field :size,  type: String
  # field :smtp_from,  type: String
  # field :mail_relay,  type: String
  # field :forward_by_rule,  type: String
  # field :message_type,  type: String
  # field :from_type,  type: String
  # field :to_type,  type: String
  # field :subject,  type: String
  # field :notes,  type: String
  # field :messageid,  type: String

  belongs_to :domino_server
  validates_uniqueness_of :notes_message_id, scope: [:domino_server_id, :date, :mail_from, :mail_to]

  def forwarded?
    if message_type =="OUT"
      # se e' in uscita il mail_from dovrebbe essere di un internal domains
      DOMINO_STAT_CONFIG[:internal_domains].each{|t|  return false if mail_from.downcase.end_with?(t)}
      return true # mail_from
    else #message_type=="IN"
      # se e' in ingresso il mail_to dovrebbe essere di un internal domains
      DOMINO_STAT_CONFIG[:internal_domains].each{|t|  return false if mail_to.downcase.end_with?(t)}
      return true # mail_from
    end
  end
  def internal?
    a=DOMINO_STAT_CONFIG[:internal_domains].map{|t|  mail_from.downcase.end_with?(t) }.include?(true)
    b=DOMINO_STAT_CONFIG[:internal_domains].map{|t|  mail_to.downcase.end_with?(t) }.include?(true)
    return a && b
  end
  def domain(value)
    return if value.blank?
    test=/\w+@[\w.-]+|\{(?:\w+, *)+\w+\}@[\w.-]+/
    if value.match(test)
      address=value.match(test)[0]
    else
      address=value
    end
    DOMINO_STAT_CONFIG[:internal_domains].each do |x|
      return DOMINO_STAT_CONFIG[:main_domain]  if address.downcase.end_with? x
    end

    case
      when /@/
        return address.split("@").last
      else
        return "other"
    end

  end
end
