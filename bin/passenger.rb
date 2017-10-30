require './bin/user'

# Class to represent passenger.

class Passenger < User
    def initialize(name, email, phone, balance, miles)
        @miles = miles
        super(name, email, phone, balance)
        @type = 'passenger'
    end

    # Methods.

    def update_miles(value)
      @miles = @miles + value
    end

    def get_passenger_miles()
        return @miles
    end

    def to_hash
        return { 'name' => @name, 'email' => @email, 'phone' => @phone, 'balance' => @balance,
                'type' => @type, 'miles' => @miles }
    end
end
