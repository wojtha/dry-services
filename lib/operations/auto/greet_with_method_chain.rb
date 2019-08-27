module Operations::Auto
  class GreetWithMethodChain
    include Dry::Monads[:result]
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    include Import[
      :user_finder,
      'greeting.greet_user',
      greeting_authorization: 'greeting.authorization',
      greeting_validation: 'greeting.validation',
    ]

    def call(params)
      find_step(params)
        .bind(method(:authorize_step))
        .bind(method(:validation_step))
        .bind(method(:greeting_step))
    end

  private

    def find_step(user_id:, **rest)
      result = user_finder.(user_id)
      result.success? ? Success(user_id: user_id, user: result.value!, **rest) : result
    end

    def authorize_step(user:, **rest)
      result = greeting_authorization.(user)
      result.success? ? Success(user: user, **rest) : result
    end

    def validation_step(**params)
      result = greeting_validation.call(params)
      result.success? ? Success(**params, valid_params: result.value!) : result
    end

    def greeting_step(user:, valid_params:, **_rest)
      greet_user.(user, valid_params[:greeting])
    end
  end
end
