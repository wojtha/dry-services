module Operations::Auto
  class GreetWithBind
    include Dry::Monads[:result]
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    include Import[
      greeting_authorization: 'greeting.authorization',
      greeting_validation: 'greeting.validation',
      greet_user: 'greeting.greet_user',
    ]

    def call(params)
      find_user(params[:user_id]).bind do |user|
        greeting_authorization.(user).bind do
          greeting_validation.call(params).bind do |valid_params|
            greet_user.(user, valid_params[:greeting])
          end
        end
      end
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
