class CreateUserFavoriteApps < ActiveRecord::Migration[8.0]
  def change
    create_table :user_favorite_apps, id: :uuid do |t|
      t.string :user_identifier, null: false
      t.references :app, type: :uuid, null: false, foreign_key: true
      t.integer :position, null: false

      t.timestamps
    end

    add_index :user_favorite_apps, [ :user_identifier, :app_id ], unique: true
    add_index :user_favorite_apps, [ :user_identifier, :position ]
  end
end
