class Link
  include DataMapper::Resource 

  belongs_to :event, :key => true
  belongs_to :user, :key => true

  property :role, String
  property :status, Boolean
  property :updated_at, DateTime
  property :updated_on, Date

  validates_presence_of :role, :event, :user
  validates_with_method :role_validator
  validates_with_method :no_double_link

  after :create, :push_data
  after :save, :push_data
  after :update, :push_data
  before :destroy, :push_data

  # make sure no double links
  def no_double_link
    if Link.first(event_id:self.event.id, user_id:self.user.id).nil?
      return true
    else
      return [false, "user already linked to this event"]
    end
  end

  # after a link is changed in the db, throw all event data to socket
  def push_data
    EM.next_tick do
      Check.settings.sockets.each do |s| 
        socket_id = s[0]
        socket = s[1]
        # send message through socket with same id
        if socket_id.to_s == self.event.id.to_s
          socket.send(self.event.bundled_event.to_json)
        end
      end
    end
  end

  def role_validator
    rlist = ["creator", "organizer", "attendee"]
    return rlist.include? self.role
  end

  def get_binding
    self.binding
  end


end
