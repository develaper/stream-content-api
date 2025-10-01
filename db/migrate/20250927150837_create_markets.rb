class CreateMarkets < ActiveRecord::Migration[8.0]
  def change
    create_table :markets, id: :uuid do |t|
      t.string :code, null: false, limit: 2

      t.timestamps
    end

    add_index :markets, :code, unique: true
  end
end
