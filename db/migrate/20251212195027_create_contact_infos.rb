class CreateContactInfos < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_infos do |t|
      t.string :email
      t.string :github_url
      t.string :linkedin_url
      t.string :twitter_url
      t.string :stackoverflow_url
      t.string :untapped_username

      t.timestamps
    end
  end
end
