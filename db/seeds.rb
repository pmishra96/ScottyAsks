u1 = User.new andrewid: "rbrigden", password:"testing1", nfctag:"1020982"
u2 = User.new andrewid: "pmishra1", password:"testing2", nfctag:"8623888"
u1.set_params
u2.set_params
u1.save
u2.save

