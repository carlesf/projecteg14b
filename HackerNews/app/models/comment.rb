class Comment < ApplicationRecord
  validates :content, length: {minimum: 1}
end