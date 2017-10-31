require './bin/user'

# Class to represent passenger.

class Passenger < User
  attr_accessor :miles

    def initialize(name, email, phone, balance, miles)
        super(name, email, phone, balance)
        @miles = miles
        @type = 'passenger'
    end

    def to_hash
        return { 'name' => @name, 'email' => @email, 'phone' => @phone, 'balance' => @balance,
                'type' => @type, 'miles' => @miles }
    end
end
