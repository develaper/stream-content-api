class CreateCatalogEntries < ActiveRecord::Migration[7.0]
  def change
    create_table :catalog_entries, id: :uuid do |t|
      t.references :content, polymorphic: true, type: :uuid, null: false
      t.timestamps
    end
  end
end
