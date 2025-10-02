class CatalogEntry < ApplicationRecord
  belongs_to :content, polymorphic: true

  validates :id, presence: true, uniqueness: true
  validates :content_type, :content_id, presence: true
end
