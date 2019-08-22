module Operations::Init
  class GreetWithDo
    extend Dry::Initializer
    include Dry::Monads[:result]
    include Dry::Monads::Do.for(:call)
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    option :greeting_authorization, reader: :private, default: proc { Greeting::Authorization.new }
    option :greeting_validation, reader: :private, default: proc { Greeting::Validation.new }
    option :greet_user, reader: :private, default: proc { Greeting::GreetUser.new }

    def call(params)
      user = yield find_user(params[:user_id])
      yield greeting_authorization.(user)
      valid_params = yield greeting_validation.(params)

      greet_user.(user, valid_params[:greeting])
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
