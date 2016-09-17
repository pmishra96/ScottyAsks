class User
  include DataMapper::Resource
  include BCrypt

  has n, :links
  has n, :events, :through => :links

  property :id, Serial, :key => true
  property :andrewid, String, :length => 3..50
  property :password, BCryptHash
  property :firstname, String
  property :lastname, String
  property :nfctag, String

  validates_presence_of :nfctag, :andrewid, :password
  validates_uniqueness_of :andrewid, :nfctag
  validates_with_method :is_valid_user


  def set_params
  	dapi = DirectoryAPI.new
  	full = dapi.get_fullname(self.andrewid).split(" ")
  	self.firstname = full.first
  	self.lastname = full.last
  end

  def authenticate(attempted_password)
  	return (self.password == attempted_password)
  end

  def fullname
  	return (self.firstname + " " + self.lastname)
  end

  # model validation, checks directory
  def is_valid_user
  	dapi = DirectoryAPI.new
  	if dapi.verify_user_exists(self.andrewid)
  		return true
  	else
  		[ false, "#{andrewid} is not a valid andrewid" ]
  	end
  end

  # does user have a given role for an event
  def is_role_for(role, event)
    return self.links(event:event).role == role
  end


end