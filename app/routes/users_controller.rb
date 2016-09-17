class ScottyAsks < Sinatra::Base

  post "/users/new" do
    u = User.new(andrewID:params["andrewID"], fbid:params["fbid"])
    puts params["fbid"]
    u.fbid = params["fbid"]
    u.andrewID = params["andrewID"]
    if u.save
      u.set_default_hashtags
      if u.save
        return u.to_json
      end
    end
    puts u.errors.first
    return "".to_json
  end

  get "/users/fb/:fbid" do
    if u = User.first(fbid:params[:fbid])
      return u.to_json
    else
      return ""
    end
  end

end
