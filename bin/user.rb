# Base class for users. Contains attributes and methods that everyone needs.

class User
    @@idc = 0
    attr_accessor :balance
    attr_reader :id, :name, :email, :phone, :type
    def initialize(name, email, phone, balance)
        @id = @@idc
        @name = name
        @email = email
        @phone = phone
        @balance = balance
        @type = 'user'
        @@idc = @@idc + 1
    end

end
