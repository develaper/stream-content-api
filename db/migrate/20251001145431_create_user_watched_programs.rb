class CreateUserWatchedPrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :user_watched_programs, id: :uuid do |t|
      t.string :user_identifier, null: false
      t.references :channel_program, type: :uuid, null: false, foreign_key: true
      t.integer :watched_duration, null: false, default: 0

      t.timestamps
    end

    add_index :user_watched_programs, [ :user_identifier, :channel_program_id ], unique: true, name: 'index_user_program_watch_uniqueness'
  end
end
