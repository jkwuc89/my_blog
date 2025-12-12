class CreatePresentations < ActiveRecord::Migration[8.1]
  def change
    create_table :presentations do |t|
      t.string :title
      t.text :abstract
      t.string :slides_url
      t.string :github_url
      t.date :presented_at

      t.timestamps
    end
  end
end
