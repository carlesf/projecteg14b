class Contribution < ApplicationRecord
  validates :url, uniqueness: true
end
