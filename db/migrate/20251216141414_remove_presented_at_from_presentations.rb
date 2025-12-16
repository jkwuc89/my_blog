class RemovePresentedAtFromPresentations < ActiveRecord::Migration[8.1]
  def change
    remove_column :presentations, :presented_at, :date
  end
end
