class AddNameAndBriefBioToBios < ActiveRecord::Migration[8.1]
  def change
    add_column :bios, :name, :string
    add_column :bios, :brief_bio, :string
  end
end
