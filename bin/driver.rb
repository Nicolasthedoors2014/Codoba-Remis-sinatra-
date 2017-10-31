require './bin/user'

# Class to represent driver.

class Driver < User
  attr_reader :fare, :raiting, :licence
    def initialize(name, email, phone, balance, licence, fare, raiting)
        @licence = licence
        @fare = fare
        @raiting = raiting
        super(name, email, phone, balance)
        @type = 'driver'
    end

    # Methods.

    def update_raiting(value)
      @raiting.push(value)
    end


    def to_hash
        return { 'name' => @name, 'email' => @email, 'phone' => @phone, 'balance' => @balance,
                'type' => @type, 'licence' => @licence, 'fare' => @fare, 'raiting' => @raiting}
    end

end
