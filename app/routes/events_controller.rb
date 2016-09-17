class Check < Sinatra::Base

  # landing
  get '/' do
    @events = Event.all
    @current_user = User.get(session[:current_user])
    erb :landing, :locals => {:events  => @events, 
                              :current_user => @current_user}
  end

  # events#show
  get "/events/:id" do
    @event = Event.get(params["id"])
    @current_user = User.get(session[:current_user])
    erb :event, :locals => { :event => @event,
                             :current_user => @current_user}
  end

  # events#index
  get "/events" do
    @events = Event.all(:order => [ :start.desc ])
    @current_user = User.get(session[:current_user])
    erb :event_index, :locals => { :events => @events, 
                                   :current_user => @current_user} 
  end

  # events#edit
  get "/events/:id/edit" do
    @event = Event.get(params["id"])
    @current_user = User.get(session[:current_user])
    if !@current_user.nil? and can?(@current_user, [:manage, :modify], @event)
      erb :event_edit, :locals => { :event => @event,
                             :current_user => @current_user}
    else
      flash[:error] = "You are not authorized to manage #{@event.name}"
      redirect to("/events/#{@event.id}")
    end
  end

  # events#update
  post "/events/:id/update" do
    @event = Event.get(params[:id])
    sd = Date.parse(params[:event][:start_date])
    if params[:event].include? :end_date
      ed = Date.parse(params[:event][:end_date])
    else
      ed = sd
    end
    st = Time.parse(params[:event][:start])
    et = Time.parse(params[:event][:end])
    start_t = DateTime.new(sd.year, sd.month, sd.day, st.hour, st.min, st.sec, st.zone)
    end_t = DateTime.new(ed.year, ed.month, ed.day, et.hour, et.min, et.sec, et.zone)
    public_checked = params[:event][:public] == 'on' ? true : false
    if @event.update(start:start_t, end:end_t, 
                     public:public_checked,
                     name:params[:event][:name], 
                     description:params[:event][:description],
                     location:params[:event][:location])
      flash[:success] = "Successfully updated #{@event.name}"
      redirect to("/events/#{@event.id}")
    else
      @event.errors.each {|error| puts error}
      flash[:error] = error_messages_for(@event)
      redirect to("/events/#{@event.id}/edit")
    end
  end

  # events#new
  get "/event_new" do
    @event = Event.new
    @current_user = User.get(session[:current_user])
    unless @current_user.nil?
      erb :event_new
    else
      flash[:notice] = "You must sign-in or sign-up to schedule an event."
      # add referer to come back
      # to this page after sign-in
      session[:return_to] = "/event_new"
      redirect to("/login")
    end
  end

  # events#create
  post "/event_create" do
    public_checked = params[:event][:public] == 'on' ? true : false
    @event = Event.new( name:params[:event][:name], 
                        public:public_checked,
                        description:params[:event][:description],
                        location:params[:event][:location] )
    if params[:event][:start_date].blank? or params[:event][:start].blank? or params[:event][:end].blank?
      flash[:error] = "need to set date and start/end time"
      return erb :event_new, :locals => {:event => @event}
    end
    # if the end_date does not exist, use start date
    sd = Date.parse(params[:event][:start_date])
    if params[:event].include? :end_date
      ed = Date.parse(params[:event][:end_date])
    else
      ed = sd
    end
    st = Time.parse(params[:event][:start])
    et = Time.parse(params[:event][:end])
    start_t = DateTime.new(sd.year, sd.month, sd.day, st.hour, st.min, st.sec, st.zone)
    end_t = DateTime.new(ed.year, ed.month, ed.day, et.hour, et.min, et.sec, et.zone)
    @event.start = start_t
    @event.end = end_t
    @current_user = User.get(session[:current_user])
    @event.set_creator(@current_user)
    if @event.save
      flash[:success] = "successfully created event #{@event.name}"
      redirect to("/events/#{@event.id}")
    else
      puts "got here"
      flash[:error] = error_messages_for(@event)
      erb :event_new, :locals => {:event => @event}
    end
  end

  # register a user for an event
  post '/events/:id/register' do
    @current_user = User.get(session[:current_user])
    @event = Event.get(params[:id])
    unless @current_user.nil?
      if @event.register(@current_user)
        flash[:success] = "You are successfully registered for #{@event.name}"
        redirect to("/events/#{@event.id}")
      else
        flash[:error] = error_messages_for(@event)
        redirect to("/events/#{@event.id}")
      end
    else
      flash[:notice] = "You must sign-in or sign-up to register for #{@event.name}"

      # add referer to come back
      # to this page after sign-in
      session[:return_to] = "/events/#{@event.id}"
      redirect to("/login")
    end
  end

  get "/events/:id/designate_organizers" do
    @event = Event.get(params[:id])
    @users = User.all
    @current_user = User.get(session[:current_user])
    unless @current_user.nil? and !can?(@current_user, [:manage, :modify], @event)
      erb :designate_organizers
    else
      flash[:error] = "You are not authorized to view this page"
      redirect to("/events/#{@event.id}")
    end
  end

  post "/make_organizer" do
    @event = Event.get(params[:event_id])
    @user = User.get(params[:user_id])
    unless @user.nil? or @event.nil?
      if @event.make_organizer(@user)
        flash[:success] = "#{@user.fullname} is now an organizer for #{@event.name}"
        redirect to("/events/#{@event.id}/designate_organizers")
      else
        flash[:error] = "whoops, something went wrong"
        redirect to("/events/#{@event.id}/designate_organizers")
      end
    else
      flash[:error] = "whoops, something went wrong"
      redirect to("/events/#{@event.id}/designate_organizers")
    end
  end

  post "/revoke_organizer" do
    @event = Event.get(params[:event_id])
    @user = User.get(params[:user_id])
    unless @user.nil? or @event.nil?
      if @event.revoke_organizer(@user)
        flash[:success] = "#{@user.fullname} is now an organizer for #{@event.name}"
        redirect to("/events/#{@event.id}/designate_organizers")
      else
        flash[:error] = "whoops, something went wrong"
        redirect to("/events/#{@event.id}/designate_organizers")
      end
    else
      flash[:error] = "whoops, something went wrong"
      redirect to("/events/#{@event.id}/designate_organizers")
    end
  end


  # search query event locations
  post "/location_pick.json" do
    query = params[:search]
    events = Event.all(:location.like => "%#{query}%")
    locations = []
    events.each do |event|
      locations << {"value":event.location}
    end
    return locations.to_json
  end

  # search query event names
  post "/event_pick.json" do
    query = params[:search]
    # search by name OR location
    events = Event.all(:name.like => "%#{query}%") | 
            Event.all(:location.like => "%#{query}%")
    event_list = []
    events.each do |event|
      event_list << {"value":event.name,
                    "id":event.id,  
                    "location":event.location }
    end
    return event_list.to_json
  end


  #####

  # register a user for an event
  post '/events/:id/register.json' do
    # send as: "{\"nfctag\":\"value\"}"
    payload = JSON.parse(request.body.read)
    u = User.first(nfctag:payload["nfctag"].strip)
    e = Event.get(params["id"].to_i)
    registered = (!u.nil? and !e.nil?) ? e.register(u) : false 
    if registered
      return [200, [u.to_json]]
    else
      return [400, [""]]
    end
  end

  # check a user into an event
  post '/events/:id/checkin.json' do
    # send as: "{\"nfctag\":\"value\"}"
    payload = JSON.parse(request.body.read)
    u = User.first(nfctag:payload["nfctag"].strip)
    e = Event.get(params["id"].to_i)
    checked_in = (!u.nil? and !e.nil?) ? e.checkin(u) : false
    if checked_in
      return [200, [u.to_json]]
    else
      return [400, [""]]
    end
  end

  # make a user an organizer for the event
  # add role to link object
  post '/events/:id/make-organizer.json' do
    # send as: "{\"event_id\":\"value\",\"nfctag\":\"value\"}"
    payload = JSON.parse(request.body.read)
    u = User.first(nfctag:payload["nfctag"].strip)
    e = Event.get(params["id"].to_i)
  end

  # get a list of all attendees registered for an event
  get "/events/:id/get-registered.json" do
    e = Event.get(params["id"])
    attendees = e.get_registered
    if !attendees.empty?
      return [200, [attendees.to_json]]
    else
      return [400, [""]]
    end
  end


  get "/events/:id/uncheckall.json" do
    e = Event.get(params["id"])
    if !e.nil?
      e.links.each do |link|
        link.status = false
        link.save
      end
      return [200, ["uncheck that shit yo"]]
    end    
  end

  get "/events/:id/get-checked-in.json" do
    e = Event.get(params["id"])
    attendees = e.get_checked_in
    return [200, [attendees.to_json]]
  end

  get "/events/:id/data_drop.json" do
    e = Event.get(params["id"])
    bundle = e.bundled_event
    return [200, [bundle.to_json]]
  end



  post "/event/getid" do
    # send as: "{\"event_name\":\"value\}"
    payload = JSON.parse(request.body.read)
    e = Event.first(name:payload["event_name"])
    if !e.nil?
      return [200, [e.id.to_s]]
    else
      return [400, [""]]
    end
  end


  get "/events/:id/datapipe" do |id|
    if request.websocket?
      request.websocket do |ws|

          ws.onopen do
            logger.info "datapipe socket connected event id:#{id}"
            ws.send("ready")
            settings.sockets << [id, ws]
          end

          ws.onmessage do |msg|
            if msg == "ok"
              ws.send("cool")
            elsif msg == "gimme"
              ws.send(Event.get(id).bundled_event.to_json)
            end
          end

        ws.onclose do
          logger.info "controller socket closed id:#{id}"
          # only delete this socket
            ws.send "goodbye"
            settings.sockets.delete_if { |element| element[1] == ws }
          end
        end
    end
  end

end

