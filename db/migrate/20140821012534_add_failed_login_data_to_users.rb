class AddFailedLoginDataToUsers < ActiveRecord::Migration
  def change
    add_column :users, :failed_login_attempts, :integer
    add_column :users, :failed_login_time, :datetime
  end
end