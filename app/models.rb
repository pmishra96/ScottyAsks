require 'data_mapper'
require 'bcrypt'
require 'eventmachine'
require_relative 'directory_api'
# require models
require_relative "models/user"
require_relative "models/event"
require_relative "models/link"

# set logger
DataMapper::Logger.new($stdout, :debug)
# point to db
if ENV["HOSTNAME"] == "kerouac"
  # DataMapper.setup(:default, "postgres://rbrigden@localhost/check")
  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/db.sqlite")
else
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

DataMapper.finalize
DataMapper.auto_upgrade!