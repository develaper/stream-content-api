class CreateSeasons < ActiveRecord::Migration[8.0]
  def change
    create_table :seasons, id: :uuid do |t|
      t.string :title, null: false
      t.integer :number, null: false
      t.integer :year, null: false
      t.integer :duration_in_seconds

      t.references :tv_show, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    add_index :seasons, :title
  end
end
