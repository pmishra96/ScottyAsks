require_relative 'app/app'
ScottyAsks.configure(:production){  p "in production" }
ScottyAsks.configure(:development){ p "in development" }
run ScottyAsks
