require './bin/user'

# Class to represent passenger.

class Passenger < User
  attr_accessor :miles

  class << self
    def new_from_hash(user)
      new(user['name'], user['email'],
          user['phone'], user['balance'], user['miles'])
    end
  end

  def initialize(name, email, phone, balance, miles)
    super(name, email, phone, balance)
    @miles = miles.round(2)
    @type = 'passenger'
  end

  def to_hash
    { 'name' => @name, 'email' => @email, 'phone' => @phone,
      'balance' => @balance, 'type' => @type, 'miles' => @miles }
  end
end
