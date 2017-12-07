# Class to represent Trips .

class Trip
  @@id_count = 0
  attr_reader :origin, :destination, :driver, :distance, :cost, :id
    def initialize(origin, destination, distance, driver)
        @origin = origin
        @destination = destination
        @driver = driver
        @distance = distance
        @cost = calculate_cost(driver, distance)
        @id = @@id_count
        @@id_count +=1
    end

    private

    def calculate_cost(driver, distance)
      (distance * driver.fare).round(2)
    end

end
