class CreateTests < ActiveRecord::Migration[8.0]
  def change
    create_table :tests, if_not_exists: true do |t|
      t.string :name
      t.timestamps
    end
  end
end
