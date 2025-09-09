class AddFieldsToChannels < ActiveRecord::Migration[8.0]
  def change
    add_column :channels, :description, :text
    add_column :channels, :settings, :json, default: {}
  end
end