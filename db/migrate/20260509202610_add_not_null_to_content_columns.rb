class AddNotNullToContentColumns < ActiveRecord::Migration[8.0]
  def up
    execute "UPDATE posts SET content = '' WHERE content IS NULL"
    change_column_null :posts, :content, false

    execute "UPDATE comments SET content = '' WHERE content IS NULL"
    change_column_null :comments, :content, false
  end

  def down
    change_column_null :posts, :content, true
    change_column_null :comments, :content, true
  end
end
