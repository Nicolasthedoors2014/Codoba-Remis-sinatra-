# Base class for users. Contains attributes and methods that everyone needs.

class User
    @@idc = 0
    def initialize(name, email, phone, balance)
        @id = @@idc
        @name = name
        @email = email
        @phone = phone
        @balance = balance
        @type = 'user'
        @@idc = @@idc + 1
    end

    # Methods.

    def update_balance(value)
      @balance = @balance + value
    end

    def get_user_id()
        return @id
    end

    def get_user_name()
        return @name
    end

    def get_user_email()
        return @email
    end

    def get_user_phone()
        return @phone
    end

    def get_user_balance()
        return @balance
    end

    def get_user_type()
        return @type
    end

end
