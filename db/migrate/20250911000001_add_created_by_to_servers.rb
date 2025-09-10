class AddCreatedByToServers < ActiveRecord::Migration[8.0]
  def change
    add_column :servers, :created_by, :string, null: false, default: '', comment: 'サーバー作成者のAuth0 ID'
    
    # インデックスを追加（パフォーマンス向上のため）
    add_index :servers, :created_by
  end
end
