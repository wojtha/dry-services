module Greeting
  class Authorization
    include Dry::Monads[:result]

    def call(user)
      if user.greeting_enabled
        Success(user)
      else
        Failure(:not_authorized)
      end
    end
  end
end
