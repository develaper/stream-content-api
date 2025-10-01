class CreateMovies < ActiveRecord::Migration[8.0]
  def change
    create_table :movies, id: :uuid do |t|
      t.string :title, null: false
      t.integer :year, null: false
      t.integer :duration_in_seconds, null: false

      t.timestamps
    end

    add_index :movies, :title
    add_index :movies, :year
  end
end
