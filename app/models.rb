require 'data_mapper'
require 'dm-tags'
require 'bcrypt'
require 'eventmachine'
# require models
require_relative "models/user"
require_relative "models/survey"
require_relative "models/response"
require_relative "models/question"




# set logger
DataMapper::Logger.new($stdout, :debug)
# point to db
if ENV["HOSTNAME"] == "kerouac"
  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")
else
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

DataMapper.finalize
DataMapper.auto_upgrade!
