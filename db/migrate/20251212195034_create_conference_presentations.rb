class CreateConferencePresentations < ActiveRecord::Migration[8.1]
  def change
    create_table :conference_presentations do |t|
      t.references :presentation, null: false, foreign_key: true
      t.string :conference_name
      t.string :conference_url
      t.date :presented_at

      t.timestamps
    end
  end
end
