module Operations::Init
  class GreetClassic
    extend Dry::Initializer
    include Dry::Monads[:result]
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    option :greeting_authorization, reader: :private, default: proc { Greeting::Authorization.new }
    option :greeting_validation, reader: :private, default: proc { Greeting::Validation.new }
    option :greet_user, reader: :private, default: proc { Greeting::GreetUser.new }

    def call(params)
      finder_result = find_user(params[:user_id])
      return finder_result if finder_result.failure?

      user = finder_result.value!
      authorization_result = greeting_authorization.(user)
      return authorization_result if authorization_result.failure?

      validation_result = greeting_validation.call(params)
      return validation_result if validation_result.failure?
      valid_params = validation_result.value!

      return greet_user.(user, valid_params[:greeting])
    end

  private

    def find_user(id)
      if id == 1
        user = User.new(name: 'Vojta', greeting_enabled: true)
        Success(user)
      else
        Failure(:not_found, "User ID=#{user_id} cannot be found")
      end
    end
  end
end
