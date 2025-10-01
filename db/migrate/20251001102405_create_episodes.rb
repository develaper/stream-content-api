class CreateEpisodes < ActiveRecord::Migration[8.0]
  def change
    create_table :episodes, id: :uuid do |t|
      t.string :title, null: false
      t.integer :number, null: false
      t.integer :season_number, null: false
      t.integer :year, null: false
      t.integer :duration_in_seconds, null: false
      t.references :season, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    add_index :episodes, :title
  end
end
