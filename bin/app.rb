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
  if !AppController.instance.users_by_id[id.to_s].nil?
    AppController.instance.users_by_id[id.to_s].name
  else
    session.clear
    session['user_id'] = nil
  end
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
    :username => get_username,
    :locations => AppController.instance.location_names,
    :ubication => params[:ubication]
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
  existsDriver = AppController.instance.drivers[email]
  existsPassenger = AppController.instance.passengers[email]
  if existsDriver.nil? && existsPassenger.nil?
    phone = params[:phone]
    AppController.instance.register_passenger(name, email, phone)
    session['user_id'] = AppController.instance.passengers[email].id
    if session['user_id'].nil?
      redirect '/400'
    end
    '/'  # In case everythin is ok, we return the redirection url
  else
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
  puts "estos son los parametros #{params.inspect}"
  email = params[:email]
  existsDriver = AppController.instance.passengers[email]
  existsPassenger = AppController.instance.drivers[email]
  if existsDriver.nil? && existsPassenger.nil?
    name = params[:name]
    ubication = params[:ubication]
    phone = params[:phone]
    licence = params[:licence]
    fare = params[:fare].to_i
    AppController.instance.register_driver(name, email, phone, licence, fare, ubication)
    session['user_id'] = AppController.instance.drivers[email].id
    if session['user_id'].nil?
      redirect '/400'
    end
    '/'  # In case everythin is ok, we return the redirection url
  else
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
    session['user_id'] = AppController.instance.passengers[email].id
    if session['user_id'].nil?
      redirect '/400'
    end
    '/'
  else
    session['user_id'] = AppController.instance.drivers[email].id
    if session['user_id'].nil?
      redirect '/400'
    end
    '/'
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
  redirect_url = '/'
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
    if !session['trips'].nil?
      session['current_trip'] = session['trips'][params[:trip_number].to_i]
      AppController.instance.trips[session['current_trip'].driver.id] = session['current_trip']
      session['discounts'] = AppController.instance.users_by_id[session['user_id'].to_s].discount
    end
    session['trips'] = nil
    erb :finish_trip, :layout => :layout, :locals => {
      :app_title => APP_NAME,
      :username => get_username,
      :current_trip => session['current_trip'],
      :discounts => session['discounts']
    }
  end
end

# Saves the payment and the possible rating of the user. The param keys are:
#   :rating (int) The scoring of the driver for this trip.
post '/pay_trip' do
  AppController.instance.update_after_finished_trip(session['user_id'].inspect,
                                          session['current_trip'],
                                          params[:rating],
                                          params[:discount_rate])

  # Clean the session after the trip is over
  session['current_trip'] = nil
  session['trips'] = nil
  session['origin'] = nil
  session['destination'] = nil
  session['discounts'] = nil
  redirect '/'
end

# Shows the user's profile page. Only if the user is looking at his/hers own
# profile page the balance will be shown.
# The param keys are:
#   :user_id (str or nil) The user's identifier. In no value is passed, the
#   profile of the logged user will be shown.
get '/profile' do
  if session['user_id'].nil?
    # The user is not logged in, redirect to login page
    redirect '/login'
  else
    id_user = params[:user_id]
    view_all = false
    showID = false

    if id_user.nil?
      id_user = session['user_id']
      view_all = true
      showID = true
    end

    user = AppController.instance.users_by_id[id_user.to_s]

    erb :profile, :layout => :layout, :locals => {
      :app_title => APP_NAME,
      :username => get_username,
      :view_all => view_all,
      :user => user,
      :showID => showID
    }
  end
end

get '/miles' do
  if session['user_id'].nil?
    # The user is not logged in, redirect to login page
    redirect '/login'
  else
    user_id = session['user_id']
    user = AppController.instance.users_by_id[user_id.to_s]
    erb :miles, :layout => :layout , :locals => {
      :app_title => APP_NAME,
      :username => get_username,
      :user => user
    }
  end
end

post '/miles' do
  user_id = session['user_id'].to_s
  number_of_trips = params[:number_of_trips].to_i
  discount_rate = params[:discount_rate].to_i
  AppController.instance.add_discount_passenger(user_id, number_of_trips, discount_rate)
  redirect '/'
end

get '/allDrivers' do
  if session['user_id'].nil?
    # The user is not logged in, redirect to login page
    redirect '/login'
  else
    erb :allDrivers, :layout => :layout, :locals => {
      :app_title => APP_NAME,
      :username => get_username,
      :drivers => AppController.instance.drivers,
    }
  end
end
