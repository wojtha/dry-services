module Greeting
  class Validation
    include Dry::Monads[:result]

    def call(params)
      if params[:greeting]
        Success(params)
      else
        Failure(:invalid_greeting)
      end
    end
  end
end
