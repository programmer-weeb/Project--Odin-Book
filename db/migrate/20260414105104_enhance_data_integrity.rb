class EnhanceDataIntegrity < ActiveRecord::Migration[8.0]
  def change
    # Unique indexes to prevent race conditions
    add_index :likes, [:user_id, :post_id], unique: true
    add_index :user_follow_requests, [:requesting_user_id, :requested_user_id], unique: true, name: 'index_unique_follow_requests'

    # Null constraints and defaults
    change_column_null :profiles, :display_name, false
    change_column_default :user_follow_requests, :follow_request_status, from: nil, to: 0
    change_column_null :user_follow_requests, :follow_request_status, false
  end
end
