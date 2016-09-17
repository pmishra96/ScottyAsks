require_relative "../app/app.rb"

s = Survey.create(name:"Fab Survey", owner:"David Kosbie")
Question.create(survey:s, text:"How many hours did you sleep?")
Question.create(survey:s, text:"On a scale of 1 to Kosbae, how awesome is 15-112?")
Question.create(survey:s, text:"What kind of bagel do you like?")
Question.create(survey:s, text:"What's you favourite class? Your options are: 15-112. 15-112. 15-112")
Question.create(survey:s, text:"Favourite Cuisine?")
Question.create(survey:s, text:"How awesome is this project?")
