# Class to represent Trips .

class Trip
  @@id_count = 0
  attr_reader :origin, :destination, :driver, :distance, :cost, :id, :distance_driver_origin, :current_distance
    def initialize(origin, destination, distance, driver, distance_driver_origin)
        @origin = origin
        @destination = destination
        @driver = driver
        @distance = distance
        @cost = calculate_cost(driver, distance)
        @id = @@id_count
        @@id_count +=1
        @distance_driver_origin = distance_driver_origin
        @start_time = Time.now
        @current_distance = @distance
    end


    def check_distance_origin_destination
      @current_distance -= (Time.now - @start_time)/100
    end

    private

    def calculate_cost(driver, distance)
      (distance * driver.fare).round(2)
    end

end
