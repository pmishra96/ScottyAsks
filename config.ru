require_relative 'app/app'
Check.configure(:production){  p "in production" }
Check.configure(:development){ p "in development" }
run Check
