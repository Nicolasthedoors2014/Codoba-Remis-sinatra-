# Base class for users. Contains attributes and methods that everyone needs.

class User
    @@id_count = 0
    attr_accessor :balance
    attr_reader :id, :name, :email, :phone, :type

    def initialize(name, email, phone, balance)
        @name = name
        @email = email
        @phone = phone
        @balance = balance.round(2)
        @type = 'user'
        @id = @@id_count
        @@id_count += 1
    end

end
