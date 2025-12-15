class RenameContactInfosToContactInfo < ActiveRecord::Migration[8.1]
  def change
    rename_table :contact_infos, :contact_info
  end
end
