class Check < Sinatra::Base

 # login (go to login page)
  get "/login" do
    @current_user = User.get(session[:current_user])
    erb :login, :locals => { :current_user => @current_user}
  end

  # authenticate (authorize user session)
  post "/authenticate" do
    attempt = params["password"]
    andrewid = params["andrewid"]
    u = User.first(andrewid:andrewid)
    unless u.nil?
      if u.authenticate(attempt)
        session[:current_user] = u.id
        flash[:success] = 'You are logged in!'
        unless session[:return_to].nil?
          redirect to(session.delete(:return_to))
        else
          redirect to('/')
        end
      else
        flash[:error] = 'Incorrect password attempt'
        logger.info "fails"
        redirect to('/login')
      end
    else
      flash[:error] = 'Not a valid Andrew ID'
      redirect to('/login')
    end
  end

  # logout (end user session)
  get "/logout" do
    session[:current_user] = nil
    flash[:success]
    redirect to('/')
  end

  # user signup (sign up for check service)
  post '/signup.json' do
    # send as: "{\"andrewid\":\"value\",\"password\":\"value\",\"nfctag\":\"value\"}"
    payload = JSON.parse(request.body.read)
    andrewid = payload["andrewid"]
    user = User.new(andrewid:andrewid, password:payload["password"], nfctag:payload["nfctag"])
    user.set_params
    if user.save
      Pony.mail(:to => "#{user.andrewid}@andrew.cmu.edu", 
                :subject => 'Welcome to Check', 
                :html_body => "hello there")
      return [200, [user.to_json]]
    else
      error = user.errors.first
      return [400, ['error occured']]
    end
  end

  # authenticate a user (for mobile app)
  post '/authenticate.json' do
    # send as: "{\"andrewid\":\"value\",\"attempt\":\"value\"}"
    payload = JSON.parse(request.body.read)
    user = User.first(andrewid:payload["andrewid"])
    unless user.nil?
      if user.authenticate(payload["attempt"])
        return [200, [user.to_json]]
      else
        return [400, ['bad password']]
      end
    else
      return [200, ['bad andrewid']]
    end
  end

end