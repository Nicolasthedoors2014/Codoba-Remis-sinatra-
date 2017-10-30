# This file contains the application controller that keeps track of the objects
# and manages the interactions inbetween themselves and with the user.

require "json"
require "singleton"
require './bin/locations'
require './bin/passenger'
require './bin/driver'

USER_DATABASE_FILENAME = "users.json"
LOCATIONS_DATABASE_FILENAME = "locations.json"

class AppController
  include Singleton

  # Attribute to save the name of the user logged in.
  attr_reader :drivers, :passengers, :locations, :users_by_id

  def initialize
    # Attributes to store the registered passengers and drivers while the
    # app is running.
    # To load/save to json, this hashes can't have symbols.
    # Attribute indexed by user_id
    @users_by_id = {}
    # Registered user counter, to assing id sequential.
    @user_id_count = 0
    # Attributes indexed by email
    @passengers = {}
    @drivers = {}

    # Attribute to store the possible locations
    @locations = {}

    load_locations
    load_users
  end

  # Registers a new passenger. Returns the id of the new user.
  def register_passenger(name, email, phone)
    # to keep track of the new user registered
    @passengers[email] = Passenger.new(name, email, phone, 0, 0)
    @users_by_id[@passengers[email].get_user_id.to_s] = @passengers[email]

    save_users
    @user_id_count = @user_id_count + 1
    # return the passenger id
    return @passengers[email].get_user_id.to_s
  end

  # Registers a new driver. Returns the id of the new user.
  def register_driver(name, email, phone, licence, fare)
    #  keep track of the new user registered
    @drivers[email] = Driver.new(name, email, phone, 0, licence, fare, [])
    @users_by_id[@drivers[email].get_user_id.to_s] = @drivers[email]
    save_users
    @user_id_count = @user_id_count + 1
    # return the driver id
    return @drivers[email].get_user_id.to_s
  end

  # Creates a fake list of trips
  def random_trips(origin, destination)
    trips = []
    distance = calculate_distance(origin, destination)
    # List of trips from the origin to the destination with all the drivers.
    @drivers.each_value { |driver| trips.push(
      [driver.get_user_name, driver.get_driver_fere * distance, driver.get_driver_raiting, driver.get_user_id]
    )}
    return trips
  end

  # Computes the distance between origin and destination
  def calculate_distance(origin, destination)
    ox = @locations[origin].xcordinate
    oy = @locations[origin].ycordinate
    dx = @locations[destination].xcordinate
    dy = @locations[destination].ycordinate
    distance = (dx - ox) + (dy - oy)

    return distance.abs.round
  end

  # Returns the names of all locations.
  def location_names
    return @locations.keys
  end

  # Saves the users in the hashes @drivers and @passengers
  # in a json file.
  # Each user instance must have a to_hash method.
  def save_users
    data_hash = []
    keys = @users_by_id.keys
    for user in keys
      data_hash.push(@users_by_id[user].to_hash)
    end
    file = File.open(USER_DATABASE_FILENAME, 'w')
    file.write(data_hash.to_json)
    file.close
  end

  # Takes a email and return the id of the passenger associated whit that email
  def look_for_passenger_id(email)
    user = @passengers.dig(email)
    if user != nil
      return user.get_user_id
    end
    return nil
  end

  # Takes a email and return the id of the driver associated whit that email
  def look_for_driver_id(email)
    user = @drivers.dig(email)
    if user != nil
      return user.get_user_id
    end
    return nil
  end

  # Takes a id of an user and the information that is wanted from this,
  # and Return associated information
  def look_for_user_info(id,info)
    user = @users_by_id.dig(id)
    if user != nil and info == 'name'
      return user.get_user_name
    elsif user != nil and info == 'email'
      return user.get_user_email
    elsif user != nil and info == 'balance'
      return user.get_user_balance
    elsif user != nil and info == 'phone'
      return user.get_user_phone
    elsif user != nil and info == 'miles' and user.get_user_type == 'passenger'
      return user.get_passenger_miles
    elsif user != nil and info == 'licence' and user.get_user_type == 'driver'
      return user.get_driver_licence
    elsif user != nil and info == 'raiting' and user.get_user_type == 'driver'
      return user.get_driver_raiting
    end
    return nil
  end

  # Update information (info) for the new value,
  # of the user associated with the id
  def update_user_info(id,info,value)

    if info == 'balance'
      @users_by_id[id].update_balance(value)
    elsif info == 'raiting' and @users_by_id[id].get_user_type == "driver"
      @users_by_id[id].update_raiting(value)
    elsif info == 'miles' and @users_by_id[id].get_user_type == "passenger"
      @users_by_id[id].update_miles(value)
    end
    save_users()
  end

  private

  # Reads the json file LOCATIONS_DATABASE_FILENAME and loads the saved  into
  # @drivers and @passengers
  def load_locations
    begin
      file_content = File.read(LOCATIONS_DATABASE_FILENAME)
      data_hash = JSON.parse(file_content)
    rescue Errno::ENOENT
      # The file does not exists
      data_hash = []
    end
    # Use the values in data_hash to fill the @locations list.
    for location in data_hash
      @locations[location['name']] = Location.new(location['name'],location['x_coordinate'],location['y_coordinate'])
    end
  end

  # Reads the json file USER_DATABASE_FILENAME and loads the saved users into
  # @drivers and @passengers
  def load_users
    begin
      file_content = File.read(USER_DATABASE_FILENAME)
      data_hash = JSON.parse(file_content)
    rescue Errno::ENOENT
      # The file does not exists
      data_hash = []
      save_users
    end
    # Use the values in data_hash to fill the @passenger or @drivers list, and users_by_id list.
    for user in data_hash
      if user['type'] == "passenger"
        @passengers[user['email']] = Passenger.new(user['name'], user['email'], user['phone'], user['balance'], user['miles'])
        @users_by_id[@passengers[user['email']].get_user_id.to_s] = @passengers[user['email']]
      elsif user['type'] == "driver"
        @drivers[user['email']] = Driver.new(user['name'], user['email'], user['phone'], user['balance'], user['licence'], user['fare'], user['raiting'])
        @users_by_id[@drivers[user['email']].get_user_id.to_s] = @drivers[user['email']]
      end
    end
    # Set user_id_count to the number of users so that the next user that registers has the corresponding id.
    @user_id_count = @users_by_id.length
  end


end
