# Rakefile
APP_FILE  = './app/app.rb'
APP_CLASS = 'Check'

# For Padrino users, do not forget to add your application namspace
# APP_CLASS = '<Project>::App'



require 'sinatra/assetpack/rake'


namespace :assets do
  task :precompile => "assetpack:build"
end