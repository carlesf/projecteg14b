class Contribution < ApplicationRecord
  validates :title, length: {minimum: 1}
  validates :url, :allow_blank => true, :uniqueness => true, :if => :url? 
end
