module Operations::Init
  class GreetWithTransaction
    extend Dry::Initializer
    include Dry::Transaction
    include Dry::Monads[:result]
    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

    # !!! Dry::Transaction is not compatible with Dry::Initializer as both defines initialize method !!!

    option :greeting_authorization, reader: :private, default: proc { Greeting::Authorization.new }
    option :greeting_validation, reader: :private, default: proc { Greeting::Validation.new }
    option :greet_user, reader: :private, default: proc { Greeting::GreetUser.new }
    option :user_finder, reader: :private, default: proc { UserFinder.new }

    step :find_step
    step :authorize_step
    step :validation_step
    step :greeting_step

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
