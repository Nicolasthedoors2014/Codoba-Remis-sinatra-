# Class to represent locations.

class Location
  attr_reader :xcordinate, :ycordinate, :name
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
