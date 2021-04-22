class Comment < ApplicationRecord
  #belongs_to :contr
  #has_many :replies, as: :commentreply
  
  validates :content, length: {minimum: 1}
end
