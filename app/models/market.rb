class Market < ApplicationRecord
  validates :code, presence: true, uniqueness: { case_sensitive: false }, length: { is: 2 }

  before_validation :upcase_code

  private

  def upcase_code
    self.code = code.upcase if code.present?
  end
end
