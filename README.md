<!--
Creator: JP Barela
Market: Den
-->

![](https://ga-dash.s3.amazonaws.com/production/assets/logo-9f88ae6c9c3871690e33280fcf557f33.png)

# Intro to Sinatra

### Learning Objectives 

- Install the Sinatra framework in an app
- Use Sinatra to build a RESTful app 
- Create an ERB template to display dynamic HTML 

## Sinatra 

Sinatra is a framework for Ruby that is very similar to Express. It handles creating routes, parsing params, and responding back to a 
web request. We'll be using it to create RESTful single resource apps for our second project.

## Installation 
Installing Sinatra is pretty easy. We need to create three files. The first file is similar to ``package.json``, it is called the 
Gemfile. The second is called the ``config.ru``. This file helps configure the Rack server. This server is the Ruby equivalent of Node 
and provides the basics web server functionality. The final file is often called the Sinatra app and is very similar to an
Express controller file. 

Lets start with the Gemfile. The first run the command ``bundle init``. This creates the Gemfile. We'll install two Gems Sinatra 
and rerun, the Ruby version of nodemon.

Here's our final Gemfile: 

```ruby
# frozen_string_literal: true
# A sample Gemfile
source "https://rubygems.org"

gem "sinatra"

gem 'rerun'
```

Once you create the file, run the command ``bundle install`` or just ``bundle``.


The ``config.ru`` is boilerplate. Here is file that

```ruby
require 'rubygems'
require 'bundler'
Bundler.require

require './high_five_tracker'
run HighFiveTracker
```

Finally our initial app is just two lines

```ruby
class HighFiveTracker < Sinatra::Base
end
```

We already have enough to bring up our app. To bring up the app type ``rackup`` on the command line.

The default Sinatra port is 9292. Lets visit http://localhost:9292.

## Sinatra Routes

To create a route all we need to do is use the HTTP verb, the path we want to use, and a ``do ... end`` block.

```ruby
	get '/' do
		"My index route!"
	end
```

Let's add some data and create a true index route. 

```ruby
	@@team_members = [{name: "Fry", high5s: 3}, {name: "Professor", high5s: 1},{name: "Bender", high5s: -2}, {name: "Leela", high5s: 1001}]

	get '/' do
		@@team_members
	end
```

Does this code work?

<details>
Sinatra only displays strings if we have an object we want to display we need to explicitly call .to_s on the object.

```ruby
	@@team_members = [{name: "Fry", high5s: 3}, {name: "Professor", high5s: 1},{name: "Bender", high5s: -2}, {name: "Leela", high5s: 1001}]

	get '/team_members' do
		@@team_members.to_s 
	end
```
</details> 

## Templating and ERB

Since Sinatra only returns strings the templating engines become much more important. We can use Handlebars and directions to install 
Handlebars is at the bottom of the page. However, we'll spend today working on another engine, ERB. 

ERB stands for Embedded Ruby. It is the default templating engine for most Ruby frameworks so it's helpful to know it but many projects 
will use another templating engine. Just like Handlebars we need to keep our templates in the ``views`` folder.

Most of the text in an ERB file is not changed after processing the document. There are two exceptions based on the ``<%= %>`` and ``<% %>`` tags. 

### Printed Values
To print a value in an ERB, use ``<%= %>``. Whatever the code inside the ``<%= %>`` evaluates to will be included in the file. Typically 
this will be variable or a single method call on an object.

### Non-printed Values
Any Ruby code that we want to run but don't want to print on the screen, like for loops or other control structures.

Challenge: 
Given an array of ``team_members`` of that are strings, write an ERB template which wraps the ``team_list`` array in a ``ul`` tag and 
each team member in a ``li`` tag

<details>
```ruby
	<ul>
		<% team_members.each do |member| %>
			<li><%= member %></li>
		<% end %>
	</ul> 
```
</details>

We can can use this template in our index route to create a nice HTML document.

What would be the code we would add in the ``views/index.erb`` file to display all the team members:
<details>
```ruby
	<ul>
		<% @team_members.each do |member| %>
			<li><%= member[:name] %> &mdash; <%= member[:high5s] %> </li>
		<% end %>
	</ul> 
```	
</details>

In the index route we need to do two things, add data to the ``@team_list`` variable and tell Sinatra which ERB file to use:

```ruby
	get '/team_members' do
		@team_members = @@team_members
		erb :index
	end
```

### Layouts 
Just like Handlebars we can remove most of the boilerplate out to its own file called ``views/layout.erb``. Here instead of 
``{{{body}}}`` we use ``<%= yield %>``. 

```ruby
<!DOCTYPE html>
<html>
	<head>
		<title>High Five Tracker</title>
	</head>
	<body>
		<%= yield %> 
	</body>
</html>
```

In the starter code, we've added a bit fancier layout and some default CSS.

Notice that we've included a ``public`` folder just like Express. If we want to serve static assets we just need to 
add them to the public folder.

[Comment]: # (Likely break here)

## Request Body

Just like Node, Sinatra can parse data coming from the request. However unlike Express, there isn't a default tool like body-parser
to help us read the data. We'll need to work with lower level request data.

If we're trying to decode form data, we need to use the following code:
```ruby
	request.body.rewind
	request_body = URI::decode_www_form(request.body.read).to_h 
```

If we're trying to decode JSON we'll need the following code:
```ruby
	require 'json'

	request.body.rewind
	request_body = JSON.parse(request.body.read)
```

Let's try to understand how we can build out our team_member creation route. Let's first create a quick ``new`` route

In our app we add:
```ruby
	get '/team_members/new' do
		erb :new
	end
```

And a view ``views/show.erb``:

```html
<form action='/team_members' method='POST'>
	<div class="form-group">
		<input type="text" name="name" placeholder="Team Member Name" class="form-control" />
	</div>
	<div class="form-group">	
		<input type="text" name="high5s" placeholder="Starting High 5s" class="form-control"/>
	</div>
	<div class="form-group">	
		<input type="submit" value="Create new team member." class="btn btn-default" />
	</div>
</form>
```

Now we can work on our post route. Here we need to collect the form data from the user, add the data to our 
array and send the user back to our index route.

```ruby
	post '/team_members' do
		request.body.rewind
		form_data = URI::decode_www_form(request.body.read).to_h 
		@@team_members.push form_data
		
		redirect to('/team_members')
	end
```

## Params
How can we implement show? 

What does the show route look like?
<details>
``/team_members/:id``

For this lab let's assume that ``:id`` can be 0.
</details>

How do we get the details of the ``id``? Lets log the ``params`` variable. Lets create a basic show route just to log 
the ``params`` value.

``params`` looks like it's going to work so what additional things do I need to complete the show example?

<details>
Find the team member in the array and render that team member in HTML.
</details>

What would the code look like?

<details>
```ruby
	get '/team_members/:id' do
		@team_member = @@team_members[params['id'].to_i
		erb :show
	end
```

In ``view/show.erb``.

```ruby
<h2> <%= @team_member['name']%> </h2>

<h3> High Fives <%= @team_member['high5s'] %> </h3>
```
</details>

Now our product manager has asked us about a new feature. We're thinking about adding a picture of each team member.
However, we don't want the picture to appear all of the time we request individual team_member data, we only want to 
get the picture if the user wants it. How can we do this? 

<details>
How about a query parameter?
</details>

Before she green lights the feature, she wants us to test how easy to implement it first. Let's try to update the
show route to see if we can tell when someone wants to include the picture. We won't show a picture just show that 
the query param was included in the request.

```ruby
	get '/team_members/:id' do
		@team_member = @@team_members[params['id'].to_i]
		@team_member['picture'] = 'some_url' unless params['picture'].nil?
		erb :show
	end
```

## More Routes
Let's now finish up the rest of the lecture by finishing up adding the rest of our routes

* Create an ``edit`` route that includes the current value of the team member
* Create an ``update`` route that replaces the current team member with the value of the ``edit`` form
* Create a ``delete`` route

## Odds and Ends

### JSON

If we want to return JSON we can do that relatively simply. First, we require the standard Ruby JSON library at the top of the file.

```ruby
require 'json'

class MyJsonApp < Sinatra::Base 

	get '/messages' do
		{message: 'My json message'}.to_json
	end
end
```

### Handlebars
If you would prefer to use the Handlebars templates, you can! 

Here is how to install and use Handelbars in a Sinatra app:

1. Include ``tilt-handlebars`` in your Gemfile
2. ``require 'sinatra/handlebars'`` at the top of your Siantra file
3. Use ``handlebars`` as a templating function 

For more information check out the [tilt-handlebars](https://github.com/jimothyGator/tilt-handlebars) repo.

## Conclusion 

The concepts we learned during Express form the basis for web programming. You can quickly move between frameworks 
by coming back to the basic request/response cycle.

* What is Sinatra?
* How do you create a post route on 'team_members' in Sinatra?
* What is ERB? 
* What is the difference between ``<%= %>`` and ``<% %>``?
