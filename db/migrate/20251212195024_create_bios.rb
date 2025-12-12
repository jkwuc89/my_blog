class CreateBios < ActiveRecord::Migration[8.1]
  def change
    create_table :bios do |t|
      t.text :content
      t.string :resume_url

      t.timestamps
    end
  end
end
