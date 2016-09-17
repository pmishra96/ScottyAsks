class ScottyAsks < Sinatra::Base


  get '/' do
    erb :landing
  end

  get "/surveys/new" do
    erb 
  end
end
