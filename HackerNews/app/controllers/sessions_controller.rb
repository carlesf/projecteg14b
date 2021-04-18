class SessionsController < ApplicationController
  def omniauth
    user = User.from_omniauth(request.env['omniauth.auth'])
    if user.valid?
      session[:user_id] = user.id 
      
      #redirect_to user_path(user)
      redirect_to contributions_path, notice: "Logged in!"
      
    else
      #redirect_to contributions_path
      redirect_to users_path, notice: "User not valid"
    end
    
  end
  
  
  #def create
   # user = User.from_omniauth(request.env['omniauth.auth'])
    
    #session[:user_id] = user.id
    #redirect_to contributions_path, 
  #end
  
  def destroy
    session[:user_id] = nil
    redirect_to contributions_path, notice: "Logged out!"
  end
  
end