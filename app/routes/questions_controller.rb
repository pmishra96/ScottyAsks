class ScottyAsks < Sinatra::Base
  get "/users/fb/:fbid/question" do
    q = Question.all.shuffle.first
    u = User.first(fbid:params["fbid"])
    counter = 0
    while u.questions.include? q
      q = Question.all.shuffle.first
      counter += 1
      if counter > 5
        return [].to_json
      end
    end
    u.questions.push q
    u.save
    return q.to_json
  end

  post "/users/fb/:fbid/question" do
    # q = Question.get(params["question_id"].to_i)
    answer_text = params["answer_text"]
    u = User.first(fbid:params["fbid"])
    r = Response.new question:Question.all.shuffle.first, answer:answer_text
    if r.save
      return 200
    else
      return 400
    end
  end

end
