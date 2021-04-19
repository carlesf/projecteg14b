class Contribution < ApplicationRecord
  validates :title, length: {minimum: 1}
  validates :url, :allow_blank => true, :uniqueness => true, :if => :url?
  validate :valid_url
  
  def valid_url
    if !(url =~ URI::regexp)
      errors.add(:invalidurl, "Invalid url")
    end
  end
  
end
