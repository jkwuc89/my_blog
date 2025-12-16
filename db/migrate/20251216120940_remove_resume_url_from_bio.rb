class RemoveResumeUrlFromBio < ActiveRecord::Migration[8.1]
  def change
    remove_column :bio, :resume_url, :string
  end
end
