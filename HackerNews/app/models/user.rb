class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable #, :validatable
  def self.from_omniauth(response)
    User.find_or_create_by(uid: response[:uid]) do |u|
      #u.username = response[:info][:name]
      u.email = response[:info][:email]
    end
  end
end
