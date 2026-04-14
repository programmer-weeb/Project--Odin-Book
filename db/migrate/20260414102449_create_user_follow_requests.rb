class CreateUserFollowRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :user_follow_requests do |t|
      t.references :requesting_user, null: false, foreign_key: { to_table: :users }
      t.references :requested_user, null: false, foreign_key: { to_table: :users }
      t.integer :follow_request_status

      t.timestamps
    end
  end
end
