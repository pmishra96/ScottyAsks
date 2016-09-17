class Question
  include DataMapper::Resource

  has n, :responses

  property :id, Serial, :key => true
  property :question_txt, String

 validates_presence_of :question_txt, :user

end
