class CreateChannelPrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :channel_programs, id: :uuid do |t|
      t.string :title, null: false
      t.integer :year
      t.integer :duration_in_seconds
      t.references :channel, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    add_index :channel_programs, :title
  end
end
