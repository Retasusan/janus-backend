class CreateForumThreadsAndPosts < ActiveRecord::Migration[8.0]
  def change
    # forum_threads table (create if missing with full schema)
    create_table :forum_threads, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true, index: true
      t.string :title, null: false
      t.string :created_by, null: false
      t.timestamps
    end

    # Ensure columns exist when table pre-existed (idempotent guards)
    add_reference :forum_threads, :channel, null: false, foreign_key: true, index: true unless column_exists?(:forum_threads, :channel_id)
    add_column :forum_threads, :title, :string, null: false, default: "" unless column_exists?(:forum_threads, :title)
    change_column_default :forum_threads, :title, nil if column_exists?(:forum_threads, :title)
    add_column :forum_threads, :created_by, :string, null: false, default: "" unless column_exists?(:forum_threads, :created_by)
    change_column_default :forum_threads, :created_by, nil if column_exists?(:forum_threads, :created_by)
    unless column_exists?(:forum_threads, :created_at)
      add_timestamps :forum_threads, null: true
    end

    # forum_posts table (create if missing with full schema)
    create_table :forum_posts, if_not_exists: true do |t|
      # Avoid adding foreign_key within block to prevent adapter from querying non-existent column in if_not_exists path
      t.bigint :forum_thread_id, null: false
      t.text :content, null: false
      t.string :created_by, null: false
      t.timestamps
    end

    # Ensure columns exist when table pre-existed (idempotent guards)
  add_column :forum_posts, :forum_thread_id, :bigint, null: false unless column_exists?(:forum_posts, :forum_thread_id)
  add_index :forum_posts, :forum_thread_id unless index_exists?(:forum_posts, :forum_thread_id)
  add_foreign_key :forum_posts, :forum_threads, column: :forum_thread_id unless foreign_key_exists?(:forum_posts, :forum_threads)
    add_column :forum_posts, :content, :text, null: false, default: "" unless column_exists?(:forum_posts, :content)
    change_column_default :forum_posts, :content, nil if column_exists?(:forum_posts, :content)
    add_column :forum_posts, :created_by, :string, null: false, default: "" unless column_exists?(:forum_posts, :created_by)
    change_column_default :forum_posts, :created_by, nil if column_exists?(:forum_posts, :created_by)
    unless column_exists?(:forum_posts, :created_at)
      add_timestamps :forum_posts, null: true
    end
  end
end
