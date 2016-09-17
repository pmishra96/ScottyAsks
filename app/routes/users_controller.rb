class Check < Sinatra::Base

  ## webapp


  # users#index
  get "/users" do
    @users = User.all
    unless @users.empty
      erb :users, :locals => {:users => @users}
    end
  end

  # users#show
  get "/users/:id" do
    @user = User.get(params["id"])
    @current_user = @user
    if @user.nil? or @user.id != session[:current_user]
      flash[:error] = "whoops, you aren't authorized to see this page"
      redirect to("/")
    else
      erb :user_show, :locals => { :user => @user, 
                                   :current_user => @current_user }
    end
  end

  # users#destroy
  get "/users/:id/destroy" do
    u = User.get(params["id"])
    if !u.nil?
      if u.destroy
        return true
      end
    end
    return false
  end

 
  # post "/user/getid" do
  #   # send as: "{\"andrewid\":\"value\}"
  #   payload = JSON.parse(request.body.read)
  #   u = User.first(andrewid:payload["andrewid"])
  #   if !u.nil?
  #     return [200, [u.id.to_s]]
  #   else
  #     return [400, [""]]
  #   end
  # end

end


