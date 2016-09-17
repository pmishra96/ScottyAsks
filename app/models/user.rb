require 'httparty'
class User
  include DataMapper::Resource

  has n, :questions, :through => Resource

  has_tags_on :hashtags

  property :id, Serial, :key => true
  property :andrewID, String, :length => 3..50
  property :fbid, String
  property :first_name, String
  property :last_name, String
  property :btc_value, Float, default:0
  property :btc_address, String, default:"0x00000"
  property :email, String
  property :campus, String
  property :department, String
  property :affiliation, String
  property :student_level, String
  property :student_class, String
  property :job_title, String
  property :office, String

  validates_presence_of :andrewID, :fbid
  validates_uniqueness_of :andrewID


  def set_params
    user_data = HTTParty.get("http://apis.scottylabs.org/directory/v1/andrewID/#{self.andrewID}")
    user_data.each do |key, value|
      if User.method_defined?(key.to_sym)
        self.send("#{key}=", value)
      end
    end
    self.btc_value = 0.0
    self.btc_address = 0x1efcdba
  end

  def set_default_hashtags
    tags = [self.department,
            self.student_level,
            self.student_class,
            self.campus]
    self.hashtag_list = tags
  end

  def fullname
  	return (self.first_name + " " + self.last_name)
  end






end
