class Survey
  include DataMapper::Resource

  has n, :questions
  before :destroy, :questions

  property :id, Serial, :key => true
  property :name, String
  property :owner, String

  validates_presence_of :name, :owner
  validates_uniqueness_of :name
end
