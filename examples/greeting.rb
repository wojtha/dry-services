require 'dry/initializer'
require 'dry/monads'
require 'dry/monads/do'
require 'dry/matcher/result_matcher'
require 'dry-struct'

module Types
  # include Dry::Types.module
  include Dry.Types()
end

class User < Dry::Struct
  attribute :name, Types::Strict::String
  attribute :greeting_enabled, Types::Strict::Bool
end

class GreetingAuthorization
  include Dry::Monads[:result]

  def call(user)
    if user.greeting_enabled
      Success(user)
    else
      Failure(:not_authorized)
    end
  end
end

class GreetingValidation
  include Dry::Monads[:result]

  def call(params)
    if params[:greeting]
      Success(params)
    else
      Failure(:invalid_greeting)
    end
  end
end

class UserFinder
  include Dry::Monads[:result]

  def call(id)
    if id == 1
      user = User.new(name: 'Vojta', greeting_enabled: true)
      Success(user)
    else
      Failure(:not_found, "User ID=#{user_id} cannot be found")
    end
  end
end

class GreetUser
  include Dry::Monads[:result]

  def call(user, greeting)
    greet = "#{greeting} from #{user.name}!"
    Success(greet)
  end
end

class GreetingOperation
  extend Dry::Initializer
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)
  include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

  option :greeting_authorization, reader: :private, default: proc { GreetingAuthorization.new }
  option :greeting_validation, reader: :private, default: proc { GreetingValidation.new }
  option :user_finder, reader: :private, default: proc { UserFinder.new }
  option :greet_user, reader: :private, default: proc { GreetUser.new }

  def call(params, &block)
    # call_classic(params)
    # call_with_bind(params)
    # call_with_method_chain(params)
    call_with_do(params, &block)
  end

  def call_classic(params)
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

  def call_with_bind(params)
    find_user(params[:user_id]).bind do |user|
      greeting_authorization.(user).bind do
        greeting_validation.call(params).bind do |valid_params|
          greet_user.(user, valid_params[:greeting])
        end
      end
    end
  end

  def call_with_do(params)
    user = yield find_user(params[:user_id])
    yield greeting_authorization.(user)
    valid_params = yield greeting_validation.call(params)

    greet_user.(user, valid_params[:greeting])
  end

  def call_with_method_chain(params)
    find_step(params)
      .bind(method(:authorize_step))
      .bind(method(:validation_step))
      .bind(method(:greeting_step))
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

operation = GreetingOperation.new
params = { user_id: 1, greeting: 'Hello' }

op_result = operation.call(params)
pp op_result

m_result = operation.call(params) do |m|
  m.success(Integer) do |i|
    "Got int: #{i}"
  end

  m.success do |v|
    "Yay: #{v}"
  end

  m.failure :not_found do |_err, reason|
    "Nope: #{reason}"
  end

  m.failure Symbol do |err, reason|
    "Nope: #{reason || err}"
  end

  m.failure do |v|
    "Boo: #{v}"
  end
end
pp m_result
