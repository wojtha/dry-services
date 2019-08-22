module Greeting
  class GreetUser
    include Dry::Monads[:result]

    def call(user, greeting)
      greet = "#{greeting} from #{user.name}!"
      Success(greet)
    end
  end
end
