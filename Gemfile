source 'https://rubygems.org'

ruby '2.2.2'

gem "bundler"
gem 'sinatra', ">=1.4.7"
gem 'sinatra-assetpack'
# gem 'tilt', "1.3.0"
gem 'serve'
gem "rake"
gem 'rack-flash3'
gem 'sinatra-websocket'
gem 'eventmachine'
gem 'pony'


# for directory scrape
gem 'mechanize'

# for data mapper
gem 'data_mapper'
gem 'bcrypt'


# for tests tests
gem 'httparty'

# environment dependent
group :development, :test do
	gem 'dm-sqlite-adapter'
end

group :production do
	gem 'dm-postgres-adapter'
end


