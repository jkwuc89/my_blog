class RenameBiosTableToBio < ActiveRecord::Migration[8.1]
  def change
    rename_table :bios, :bio
  end
end
