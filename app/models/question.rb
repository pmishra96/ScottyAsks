class Question
  include DataMapper::Resource


  has_tags_on :hashtags
  has n, :users, :through => Resource
  has n, :responses
  belongs_to :survey

  property :id, Serial, :key => true
  property :text, String

  validates_presence_of :text

  def self.random
    all.length > 0 ? (first(rand(all.length)) || random) : nil
  end

end
