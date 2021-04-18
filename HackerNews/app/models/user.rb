class User < ApplicationRecord
  

  def self.from_omniauth(response)
    User.find_or_create_by(uid: response[:uid]) do |u|
      #u.username = response[:info][:name]
      u.email = response[:info][:email]
      u.about = "testing"
    end
  end
  
  
  #def self.create_from_omniauth(auth)
   # create! do |user|
    #  user.uid = auth['uid']
     # user.email = auth['info']['email']
    #end
  #end
  
end
