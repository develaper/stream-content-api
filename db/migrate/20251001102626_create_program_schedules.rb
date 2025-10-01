class CreateProgramSchedules < ActiveRecord::Migration[8.0]
  def change
    create_table :program_schedules, id: :uuid do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.references :channel_program, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
