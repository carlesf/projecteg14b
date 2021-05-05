class User < ApplicationRecord

  def self.from_omniauth(response)
    User.find_or_create_by(uid: response[:uid]) do |u|
      #u.username = response[:info][:name]
      u.email = response[:info][:email]
      u.about = ""
      u.uid = response[:uid]
    end
  end
  
end
