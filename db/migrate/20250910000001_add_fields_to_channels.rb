class AddFieldsToChannels < ActiveRecord::Migration[8.0]
  def change
  add_column :channels, :description, :text unless column_exists?(:channels, :description)
  add_column :channels, :settings, :json, default: {} unless column_exists?(:channels, :settings)
  end
end