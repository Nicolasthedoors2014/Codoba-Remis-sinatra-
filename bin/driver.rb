require './bin/user'

# Class to represent driver.

class Driver < User
  attr_reader :fare, :rating, :licence

  class << self
    def new_from_hash(user)
      new(user['name'], user['email'], user['phone'], user['balance'],
          user['licence'], user['fare'], user['rating'])
    end
  end

  def initialize(name, email, phone, balance, licence, fare, rating)
    super(name, email, phone, balance)
    @licence = licence
    @fare = fare
    @type = 'driver'
    @rating = rating
    # if rating is nil (new user), initialize rating as [rating_count, rating]
    @rating ||= [[0, 1], [0, 2], [0, 3], [0, 4], [0, 5]]
  end

  # Methods.

  def update_rating(value)
    @rating[value - 1][0] += 1
  end

  def avarage_rating
    avarage = 0
    count = 0
    rating.each do |rating_count, rating|
      if rating_count != 0
        avarage += rating_count * rating
        count += rating_count
      end
    end
    count != 0 ? (avarage / count).round(0) : 0
  end

  def to_hash
    { 'name' => @name, 'email' => @email, 'phone' => @phone,
      'balance' => @balance, 'type' => @type, 'licence' => @licence,
      'fare' => @fare, 'rating' => @rating }
  end
end
