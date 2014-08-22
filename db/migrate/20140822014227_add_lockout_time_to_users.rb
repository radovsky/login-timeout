class AddLockoutTimeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :lockout_time, :datetime
  end
end
