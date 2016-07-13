#This is a coontroller

class HighFiveTracker < Sinatra::Base

  @@team_members = [{"name" => "Fry", "high5s" => 3}, {"name" => "Professor", "high5s" => 1},{"name" => "Bender", "high5s" => -2}, {"name" => "Leela", "high5s" => 1001}]

  # index for team_members route
  get '/team_members' do
      @team_members = @@team_members
      erb :index
  end


  # New - create a new team member that will route user to new.erb to fill out form
  get '/team_members/new' do
    erb :new
  end

  # Show individual team member
  get '/team_members/:id' do
    # outputs all the hashes into the terminal
    # puts params
    #converts a string id from team_members hash into an integer
    @team_member = @@team_members[params["id"].to_i]

    # Getting a params for a query for pictures
    # @picture = true || unless params['picture'].nil?
    erb :show
    # puts params
    # 'My SHOW route'
  end

  # Get the data to edit users id
  get '/team_members/:id/edit' do
    #Find ID
    @edit_team_member = @@team_members[params["id"].to_i]
    erb :edit

  end

  # PUT  - update and send the updated information
  put '/team_members/:id' do
    @edit_team_member = @@team_members[params["id"].to_i]
    request_body = URI::decode_www_form(request.body.read).to_h
    @edit_team_member["name"] = request_body
    @edit_team_member["high5s"] = request_body


    redirect to("/team_members/:id")
  end

  #Delete a user from hash list
  delete 'team_members/:id' do

  end


  # Create - upon form form submit this will push to team memmbers hash list, redirect user to /team_members route and render new team member into list
  post '/team_members' do
    request.body.rewind
    # uses x-www-form-urlencoded in Postman
    request_body = URI::decode_www_form(request.body.read).to_h

    #this would print out the body
    # puts request_body

    #This would push to team members
    @@team_members.push request_body

    #redirect user to team members route after submit, must be an endpoint
    redirect to('/team_members')

    'My POST route'
  end

end
