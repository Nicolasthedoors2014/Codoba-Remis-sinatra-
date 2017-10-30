# Class to represent locations.

class Location
  attr_reader :xcordinate, :ycordinate, :name
    def initialize(name, xcordinate, ycordinate)
        @name = name
        @xcordinate = xcordinate
        @ycordinate = ycordinate

    end


end
