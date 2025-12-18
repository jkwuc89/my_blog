class RemoveStackoverflowUrlFromContactInfo < ActiveRecord::Migration[8.1]
  def change
    remove_column :contact_info, :stackoverflow_url, :string
  end
end
