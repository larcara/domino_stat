class CreateDominoMessages < ActiveRecord::Migration
  def change
    create_table :domino_messages do |t|
      t.datetime :date
      t.integer :domino_server_id
      t.string :messageid
      t.string :notes_message_id
      t.string :mail_from
      t.string :mail_to
      t.integer :size
      t.string :smtp_from
      t.string :mail_relay
      t.string :forward_by_rule
      t.string :message_type
      t.string :subject
      t.text :notes

      t.timestamps
    end
  end
end
