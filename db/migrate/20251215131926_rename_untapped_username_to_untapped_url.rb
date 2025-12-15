class RenameUntappedUsernameToUntappedUrl < ActiveRecord::Migration[8.1]
  def change
    rename_column :contact_info, :untapped_username, :untapped_url
  end
end
