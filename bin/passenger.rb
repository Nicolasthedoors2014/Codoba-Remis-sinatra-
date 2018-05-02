require './bin/user'

# Class to represent passenger.

class Passenger < User
  attr_accessor :miles, :discount

  class << self
    def new_from_hash(user)
      new(user['name'], user['email'],
          user['phone'], user['balance'], user['miles'], user['discount'])
    end
  end

  def initialize(name, email, phone, balance, miles, discount)
    super(name, email, phone, balance)
    @miles = miles.round(2)
    @type = 'passenger'
    @discount = discount
    # if discount is nil (new user),
    # initialize discount as [number_of_trip, discount_rate]
    @discount ||= [[0,10], [0, 30], [0, 100]]
  end

  def add_discount(number_of_trips, discount_rate)
    if @discount[0][1] == discount_rate
      @discount[0][0] += number_of_trips
      @miles -= 15
    elsif @discount[1][1] == discount_rate
      @discount[1][0] += number_of_trips
      @miles -= 30
    elsif @discount[2][1] == discount_rate
      @discount[2][0] += number_of_trips
      @miles -= 50
    end
  end

  def remove_discount(discount_rate)
    if @discount[0][1] == discount_rate
      @discount[0][0] -= 1
    elsif @discount[1][1] == discount_rate
      @discount[1][0] -= 1
    elsif @discount[2][1] == discount_rate
      @discount[2][0] -= 1
    end
  end

  def to_hash
    { 'name' => @name, 'email' => @email, 'phone' => @phone,
      'balance' => @balance, 'type' => @type, 'miles' => @miles,'discount' => @discount }
  end
end
