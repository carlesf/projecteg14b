class Reply < ApplicationRecord
  #belongs_to :commentreply, polymorphic: true
  #has_many :replies, as: :commentreply

  validates :content, length: {minimum: 1}
end
