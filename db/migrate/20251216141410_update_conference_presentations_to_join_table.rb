class UpdateConferencePresentationsToJoinTable < ActiveRecord::Migration[8.1]
  def change
    remove_column :conference_presentations, :conference_name, :string
    remove_column :conference_presentations, :conference_url, :string
    remove_column :conference_presentations, :presented_at, :date

    add_reference :conference_presentations, :conference, null: false, foreign_key: true
  end
end
