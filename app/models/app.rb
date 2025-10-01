class App < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
