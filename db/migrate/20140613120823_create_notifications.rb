class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :notification_type
      t.date :date
      t.string :label
      t.string :description
      t.integer :value

      t.timestamps
    end
  end
end
