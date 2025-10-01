class CreateContentAvailabilities < ActiveRecord::Migration[8.0]
  def change
    create_table :content_availabilities, id: :uuid do |t|
      t.references :content, polymorphic: true, null: false, type: :uuid
      t.references :app, type: :uuid, null: false, foreign_key: true
      t.references :market, type: :uuid, null: false, foreign_key: true
      t.string :stream_url

      t.timestamps
    end

    add_index :content_availabilities, [ :content_type, :content_id, :app_id, :market_id ],
              unique: true, name: 'index_content_availabilities_uniqueness'
  end
end
