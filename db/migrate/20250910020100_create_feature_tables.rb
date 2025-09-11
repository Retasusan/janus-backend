class CreateFeatureTables < ActiveRecord::Migration[8.0]
  def change
    create_table :whiteboards, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.jsonb :operations, null: false, default: {}
      t.string :updated_by, null: false
      t.timestamps
    end

    create_table :surveys, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :question, null: false
      t.boolean :multiple, null: false, default: false
      t.datetime :expires_at
      t.string :created_by, null: false
      t.timestamps
    end

    create_table :survey_options, if_not_exists: true do |t|
      t.references :survey, null: false, foreign_key: true
      t.string :text, null: false
      t.timestamps
    end

    create_table :survey_votes, if_not_exists: true do |t|
      t.references :survey, null: false, foreign_key: true
      t.references :survey_option, null: false, foreign_key: true
      t.string :voter, null: false
      t.timestamps
    end
    add_index :survey_votes, [:survey_id, :voter], unique: true, if_not_exists: true

    create_table :tasks, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.date :due_date
      t.string :assignee
      t.string :created_by, null: false
      t.timestamps
    end

    create_table :wiki_pages, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.string :updated_by, null: false
      t.timestamps
    end

    create_table :budget_entries, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.integer :kind, null: false, default: 0
      t.string :title, null: false
      t.integer :amount, null: false, default: 0
      t.date :occurred_on
      t.string :created_by, null: false
      t.timestamps
    end

    create_table :inventory_items, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :quantity, null: false, default: 0
      t.string :location
      t.string :updated_by, null: false
      t.timestamps
    end

    create_table :photos, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :caption
      t.string :uploaded_by, null: false
      t.timestamps
    end

    create_table :diary_entries, if_not_exists: true do |t|
      t.references :channel, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.string :created_by, null: false
      t.date :entry_date
      t.timestamps
    end
  end
end
