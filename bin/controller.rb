# This file contains the application controller that keeps track of the objects
# and manages the interactions between themselves and with the user.

require 'json'
require 'singleton'
require './bin/locations'
require './bin/passenger'
require './bin/driver'
require './bin/trip'

USER_DATABASE_FILENAME = 'users.json'
LOCATIONS_DATABASE_FILENAME = 'locations.json'

class AppController
  include Singleton

  # Attribute to save the name of the user logged in.
  attr_reader :drivers, :passengers, :locations, :users_by_id, :trips

  def initialize
    # Attributes to store the registered passengers and drivers while the
    # app is running.
    # To load/save to json, this hashes can't have symbols.
    # Attribute indexed by user_id
    @users_by_id = {}

    # Attributes indexed by email
    @passengers = {}
    @drivers = {}

    # Attribute to store the possible locations
    @locations = {}

    # Attribute to keep trips in progress
    @trips = {}

    load_locations
    load_users
  end

  # Registers a new passenger. Returns the id of the new user.
  def register_passenger(name, email, phone)
    # to keep track of the new user registered
    @passengers[email] = Passenger.new(name, email, phone, 0, 0, nil)
    @users_by_id[@passengers[email].id.to_s] = @passengers[email]

    save_users
    # return the passenger id
    @passengers[email].id.to_s
  end

  # Registers a new driver. Returns the id of the new user.
  def register_driver(name, email, phone, licence, fare, ubication)
    #  keep track of the new user registered
    @drivers[email] = Driver.new(name, email, phone, 0, licence, fare, nil, ubication)
    @users_by_id[@drivers[email].id.to_s] = @drivers[email]
    save_users
    # return the driver id
    @drivers[email].id.to_s
  end

  # Creates a fake list of trips
  def random_trips(origin, destination)
    trips = []
    distance_trip = @locations[origin].distance_to(@locations[destination])
    # List of trips from the origin to the destination with all the drivers.
    @drivers.each do |index, driver|
      driver_ubication = @locations[driver.ubication]
      distance_driver_origin = @locations[origin].distance_to(driver_ubication)
      trips.push(Trip.new(origin, destination, distance_trip,
                driver, distance_driver_origin))
    end
    trips
  end

  # Saves the users in the hashes @drivers and @passengers
  # in a json file.
  # Each user instance must have a to_hash method.
  def save_users
    data_hash = []
    keys = @users_by_id.keys
    keys.each do |user|
      data_hash.push(@users_by_id[user].to_hash)
    end
    file = File.open(USER_DATABASE_FILENAME, 'w')
    file.write(data_hash.to_json)
    file.close
  end

  # Update balance and miles accumulated of the
  # passenger associated with the id
  # and update the balance and rating of
  # the driver of the trip
  def update_after_finished_trip(user_id, trip, rating, discount_rate)

    @users_by_id[user_id].miles += trip.distance.round(2)
    @users_by_id[trip.driver.id.to_s].balance += trip.cost.round(2)
    if !discount_rate.nil?
      discount = ((trip.cost.round(2) * discount_rate.to_i)/100).round(2)
      @users_by_id[user_id].balance -= (trip.cost - discount).round(2)
      @users_by_id[user_id].remove_discount(discount_rate.to_i)
    else
      @users_by_id[user_id].balance -= trip.cost.round(2)
    end
    if !rating.nil?
      @users_by_id[trip.driver.id.to_s].update_rating(rating.to_i)
    end
    save_users
  end

  def add_discount_passenger(user_id, number_of_trips, discount_rate)
    @users_by_id[user_id].add_discount(number_of_trips, discount_rate)
    save_users
  end

  def location_names
    @locations.keys
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
    data_hash.each do |location|
      @locations[location['name']] = Location.new_from_hash(location)
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
    # Use the values in data_hash to fill the @passenger or
    # @drivers list, and users_by_id list.
    data_hash.each do |user|
      if user['type'] == 'passenger'
        @passengers[user['email']] = Passenger.new_from_hash(user)
        @users_by_id[@passengers[user['email']].id.to_s] = @passengers[user['email']]
      elsif user['type'] == 'driver'
        @drivers[user['email']] = Driver.new_from_hash(user)
        @users_by_id[@drivers[user['email']].id.to_s] = @drivers[user['email']]
      end
    end
  end
end
