class Response
  include DataMapper::Resource

  belongs_to :question, :key => true

  property :answer, String

  validates_presence_of :answer

end
