class SessionsController < ApplicationController
  def omniauth
    user = User.from_omniauth(request.env['omniauth.auth'])
    if user.valid?
      session[:user_id] = user.id #uid?
      #redirect_to user_path(user)
      redirect_to contributions_path
    else
      #redirect_to contributions_path
      redirect_to users_path
    end
  end
end