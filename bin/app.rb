require 'sinatra'
require 'sinatra/content_for'
require './bin/controller'

APP_NAME = "Cordoba remis"

# Sinatra configurations
enable :sessions

set :port, 8090
set :static, true
set :public_folder, "static"
set :views, "views"

set :session_secret, 'secret ' + APP_NAME

# Returns the name of the currently logged user
def get_username
  id = session['user_id']
  !id.nil? ? AppController.instance.users_by_id[id.to_s].name : nil
end

get '/' do
  erb :index, :layout => :layout, :locals => {
    :app_title => APP_NAME,
    :username => get_username,
    :locations => AppController.instance.location_names
  }
end

get '/register' do
  erb :register, :layout => :layout, :locals => {
    :app_title => APP_NAME,
    :username => get_username
  }
end

get '/logout' do
  session['user_id'] = nil
  session.clear
  redirect '/'
end

# Registers a passenger. If the user email already exists, it returns code 400.
# Returns a redirection url.
# This handler will be called from a javascript code that, in case a sucess
# code is returned, will redirect to the redicrection url.
# The params keys are:
#   :name (str) name selected by the user
#   :email (str) email selected by the user. Must be unique in the app.
#   :phone (str) phone number selected by the user.
post '/register_passenger' do
  name = params[:name]
  email = params[:email]
  existsDriver = AppController.instance.look_for_driver_id(email)
  existsPassenger = AppController.instance.look_for_passenger_id(email)
  if existsDriver.nil? and existsPassenger.nil?
    phone = params[:phone]
    AppController.instance.register_passenger(name, email, phone)
    '/'  # In case everythin is ok, we return the redirection url
  else
    redirect '/400'
  end
  session['user_id'] = AppController.instance.look_for_passenger_id(email)
  if session['user_id'] == nil
    redirect '/400'
  end
end

# Registers a driver. If the user email already exists, it returns code 400.
# Returns a redirection url.
# This handler will be called from a javascript code that, in case a sucess
# code is returned, will redirect to the redicrection url.
# The params keys are:
#   :name (str) name selected by the user
#   :email (str) email selected by the user. Must be unique in the app.
#   :phone (str) phone number selected by the user.
#   :licence (str) the licence number selected by the user.
#   :fare (number) the fare by km selected by the user.
post '/register_driver' do
  name = params[:name]
  email = params[:email]
  existsDriver = AppController.instance.look_for_passenger_id(email)
  existsPassenger = AppController.instance.look_for_driver_id(email)
  if (existsDriver == nil) and (existsPassenger == nil)
    phone = params[:phone]
    licence = params[:licence]
    fare = Integer(params[:fare])
    AppController.instance.register_driver(name, email, phone, licence, fare)
    '/'  # Redirection url
  else
    redirect '/400'
  end
  session['user_id'] = AppController.instance.look_for_driver_id(email)
  if session['user_id'] == nil
    redirect '/400'
  end
end

get '/login' do
  erb :login, :layout => :layout, :locals => {
    :app_title => APP_NAME,
    :username => get_username
  }
end

# Logs in a new user.
# This handler will be called from a javascript code that, in case a sucess
# code is returned, will redirect to the redicrection url.
# The params keys are:
#   :email (str) The user email
#   :user_type (str) Indicates if the user is loging in as "passenger" or
#   "driver". Those are the only two possible values.
post '/login' do
  email = params[:email]
  user_type = params[:user_type]
  if user_type == "passenger"
    session['user_id'] = AppController.instance.look_for_passenger_id(email)
    if session['user_id'] == nil
      redirect '/400'
    end
  else
    session['user_id'] = AppController.instance.look_for_driver_id(email)
    if session['user_id'] == nil
      redirect '/400'
    end
  end
  if !session['go_back'].nil?
    # Before calling login, the app stored a spepecific page to go back
    params = session['go_back'][:params]
    redirect_url = session['go_back'][:url]
    session['go_back_to'] = nil
    redirect_url = redirect_url + '?' + URI.encode_www_form(params)
  else
    redirect_url = '/'
  end
  redirect_url
end

# Returns the list_trip page. The params keys are:
#   :origin (str) the name of the origin location (optional)
#   :destination (str) the name of the origin location (optional)
get '/list_trips' do
  erb :list_trips, :layout => :layout, :locals => {
    :app_title => APP_NAME,
    :username => get_username,
    :locations => AppController.instance.location_names,
    :destination => params[:destination],
    :origin => params[:origin]
  }
end

# Renders an html with a table of available trips. For now, these trips are
# created randomly. The param keys are:
#   :origin (str) the name of the origin location
#   :destination (str) the name of the origin location
post '/available_trips' do
  origin = params[:origin]
  destination = params[:destination]
  session['trips'] = AppController.instance.random_trips(origin, destination)
  puts "EStos son los viajes de #{get_username} : #{session['trips']}"
  erb :available_trips, :layout => false, :locals => {
    :trips => session['trips'],
  }
end

# Confirms the trip selected by the user and redirects to a page that waits
# for payment. The param keys are:
#   :trip_number the position of the selected trip in the tabled rendered by
#   the handler /available_trips
get '/finish_trip' do
  if session['user_id'].nil?
    # The user is not logged in, redirect to login page and save parameters
    session['go_back'] = {:url => '/finish_trip', :params => {
      :trip_number => params[:trip_number]}}
    redirect '/login'
  else
    if params[:trip_number].nil?
      redirect '/list_trips'
    end
    session['current_trip'] = session['trips'][params[:trip_number].to_i]
    puts "HOLAAAAAAAAAAAaaaaa este es el trip q eligio #{get_username} : #{session['current_trip'].id}"
    AppController.instance.trips[session['current_trip'].driver.id] = session['current_trip']
    puts "JUAJAJAJA #{AppController.instance.trips[session['current_trip'].driver.id].inspect}"
    session['trips'] = nil
    erb :finish_trip, :layout => :layout, :locals => {
      :app_title => APP_NAME,
      :username => get_username,
      :driver_name => session['current_trip'].driver.name
    }
  end
end

# Saves the payment and the possible rating of the user. The param keys are:
#   :rating (int) The scoring of the driver for this trip.
post '/pay_trip' do
  AppController.instance.update_user_info(session['user_id'].inspect,
                                          session['current_trip'],
                                          params[:rating])

  # Clean the session after the trip is over
  session['current_trip'] = nil
  session['origin'] = nil
  session['destination'] = nil
  redirect '/'
end

# Shows the user's profile page. Only if the user is looking at his/hers own
# profile page the balance will be shown.
# The param keys are:
#   :user_id (str or nil) The user's identifier. In no value is passed, the
#   profile of the logged user will be shown.
get '/profile' do
  id_user = params[:user_id]
  view_all = false
  showID = false

  if id_user.nil?
    id_user = session['user_id'].inspect
    view_all = true
    showID = true
  end

  user = AppController.instance.get_user_by_id(id_user)

  erb :profile, :layout => :layout, :locals => {
    :app_title => APP_NAME,
    :username => get_username,
    :view_all => view_all,
    :user => user,
    :showID => showID
  }
end

get '/allDrivers' do
  erb :allDrivers, :layout => :layout, :locals => {
    :app_title => APP_NAME,
    :username => get_username,
    :drivers => AppController.instance.drivers,
  }
end
