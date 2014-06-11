json.array!(@domino_messages) do |domino_message|
  json.extract! domino_message, :id, :date, :time, :domino_server_id, :messageid, :notes_message_id, :mail_from, :mail_to, :size, :smtp_from, :mail_relay, :forward_by_rule, :message_type, :subject, :notes
  json.url domino_message_url(domino_message, format: :json)
end
