# frozen_string_literal: true

# Remove name and bio as Profile already tracks name and bio
class RemoveNameAndBioFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :name, :string
    remove_column :users, :bio, :string
  end
end
