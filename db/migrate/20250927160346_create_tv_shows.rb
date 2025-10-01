class CreateTvShows < ActiveRecord::Migration[8.0]
  def change
    create_table :tv_shows, id: :uuid do |t|
      t.string :title, null: false
      t.integer :year, null: false
      t.integer :duration_in_seconds

      t.timestamps
    end

    add_index :tv_shows, :title
    add_index :tv_shows, :year
  end
end
