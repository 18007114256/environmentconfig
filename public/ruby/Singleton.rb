class Singleton
    @instance = new
    @tag
    @retCode
    @msg
  
    private_class_method :new
  
    # The static method that controls the access to the singleton instance.
    #
    # This implementation let you subclass the Singleton class while keeping just
    # one instance of each subclass around.
    def self.instance
      @instance
    end  
    # Finally, any singleton should define some business logic, which can be
    # executed on its instance.
    def some_business_logic
      # ...
    end
  end