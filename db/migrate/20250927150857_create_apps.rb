class CreateApps < ActiveRecord::Migration[8.0]
  def change
    create_table :apps, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :apps, :name, unique: true
  end
end
