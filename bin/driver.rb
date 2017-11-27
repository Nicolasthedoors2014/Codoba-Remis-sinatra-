require './bin/user'

# Class to represent driver.

class Driver < User
  attr_reader :fare, :rating, :licence
    def initialize(name, email, phone, balance, licence, fare, rating)
      super(name, email, phone, balance)
      @licence = licence
      @fare = fare
      @type = 'driver'
      if !rating.nil?
        @rating = rating
      else
        # [rating_count, rating]
        @rating = [[0,1],[0,2],[0,3],[0,4],[0,5]]
      end
    end

    # Methods.

    def update_rating(value)
      @rating[value -1][0] += 1
    end


    def to_hash
        return { 'name' => @name, 'email' => @email, 'phone' => @phone, 'balance' => @balance,
                'type' => @type, 'licence' => @licence, 'fare' => @fare, 'rating' => @rating}
    end

end
