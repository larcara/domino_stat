class AddFiled1ToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :status, :string
    add_column :notifications, :level, :integer

  end
end
