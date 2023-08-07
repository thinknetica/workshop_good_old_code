class AddLanguageToPodcasts < ActiveRecord::Migration[7.0]
  def change
    add_column :podcasts, :language, :string
  end
end
