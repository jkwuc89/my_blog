class CreateConferences < ActiveRecord::Migration[8.1]
  def change
    create_table :conferences do |t|
      t.string :title, null: false
      t.integer :year, null: false
      t.string :link

      t.timestamps
    end

    add_index :conferences, [:title, :year], unique: true
  end
end
