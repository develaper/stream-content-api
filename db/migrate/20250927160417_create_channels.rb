class CreateChannels < ActiveRecord::Migration[8.0]
  def change
    create_table :channels, id: :uuid do |t|
      t.string :title, null: false
      t.integer :year
      t.integer :duration_in_seconds

      t.timestamps
    end

    add_index :channels, :title
  end
end
