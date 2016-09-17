class Event
  include DataMapper::Resource

  has n, :links
  has n, :users, :through => :links

  before :destroy, :destroy_links

  property :id, Serial, :key => true
  property :name, String
  property :location, String
  property :description, Text
  property :start, DateTime
  property :end, DateTime
  property :public, Boolean, :default => true

  validates_presence_of :name, :location, :start, :end
  validates_uniqueness_of :name
  validates_with_method :end_after_start
  validates_with_method :in_the_future


  # validate that start > end and start & end > now
  def end_after_start
     if self.end > self.start
      return true
    else
      [false, "End time must come after start."]
    end
  end

  # validate that start && end > now
  def in_the_future
    now = DateTime.now
    if self.start > now and self.end > now
      return true
    else
      [false, "Event must be scheduled for a date in the future"]
    end
  end



  # validate that event has a single creator
  def has_one_creator
    if self.links.all(role:"creator").count == 1
      return true
    end
    [false, "failed this"]
  end


  # set the creator of the event
  def set_creator(user)
    l = Link.new user:user, event:self, role:"creator", status:false
    if l.save 
      return true
    end  
    return false  
  end

  def creator
    return self.links.first(role:"creator").user
  end

  def organizers
    users = []
    self.links(role:"organizer").each do |link|
      users.push(link.user)
    end
    return users
  end

  def attendees
    users = []
    self.links(role:"attendee").each do |link|
      users.push(link.user)
    end
    return users
  end

  # everything about the event for consumption
  def bundled_event
    # user data
    users = []
    self.links.each do |link|
      uhash = link.user.attributes
      uhash["checkedin_at"] = link.updated_at
      uhash["checkedin_at"] = link.updated_on
      uhash["role"] = link.role
      uhash["status"] = link.status
      users.push(uhash)
    end
    return users
  end

  def get_checked_in
    users = []
    self.links(role:"attendee", status:true).each do |link|
      uhash = link.user.attributes
      uhash["checkedin_at"] = link.updated_at
      uhash["checkedin_at"] = link.updated_on
      users.push(uhash)
    end
    return users
  end

  def get_registered
    users = []
    self.links(role:"attendee", status:false).each do |link|
      uhash = link.user.attributes
      uhash["registered_at"] = link.updated_at
      uhash["registered_on"] = link.updated_on
      users.push(uhash)
    end
    return users
  end


  def register(usr)
    puts "here"
    if usr.links(event:self).empty?
      puts "gotten through"
      l = Link.new user:usr, event:self, role:"attendee", status:false
      if l.save 
        # l.push_data
        return true
      else
        return false
      end
    end
  end

  def checkin(usr)
    link = usr.links(event:self).first
    unless link.nil?
      # link.push_data
      return link.update(status:true)
    else
      return false
    end
  end

  def make_organizer(usr)
    unless usr.links(event:self).empty?
      usr.links(event:self).each {|link| link.destroy }
    end
    l = Link.new user:usr, event:self, role:"organizer"
    if l.save 
      return true
    else
      return false
    end
  end

  def revoke_organizer(usr)
    unless usr.links(event:self).empty?
      usr.links(event:self).each {|link| link.destroy }
    end
    l = Link.new user:usr, event:self, role:"attendee"
    if l.save 
      return true
    else
      return false
    end
  end

  def destroy_links
    self.links.each do |link|
      link.destroy
    end
  end

end
