# Class to represent locations.

class Location
  attr_reader :xcordinate, :ycordinate, :name

  class << self
    def new_from_hash(location)
      new(location['name'], location['x_coordinate'], location['y_coordinate'])
    end
  end

  def initialize(name, xcordinate, ycordinate)
    @name = name
    @xcordinate = xcordinate
    @ycordinate = ycordinate
  end

  def distance_to(other)
    Math.sqrt((other.xcordinate - self.xcordinate)**2 +
              (other.ycordinate - self.ycordinate)**2).abs.round(2)
  end
end
