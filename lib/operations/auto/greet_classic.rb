module Operations::Auto
  class GreetClassic
    include Dry::Monads[:result]
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    include Import[
      greeting_authorization: 'greeting.authorization',
      greeting_validation: 'greeting.validation',
      greet_user: 'greeting.greet_user',
    ]

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
