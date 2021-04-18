class ApplicationController < ActionController::Base
  def hello
    render html: "hello, world!"
  end
  
private

    helper_method [:current_user, :logged_in?]

    def current_user
      if session[:user_id]
        @current_user ||= User.find(session[:user_id]) 
      else 
        @current_user = nil
      end
    end
 
    def logged_in?
      !current_user.nil?
    end

  
end
