require 'dry/monads'
require 'dry/monads/do'

Account = Struct.new(:id)
Owner = Struct.new(:id, :account)

class CreateAccount
  include Dry::Monads[:result]
  include Dry::Monads::Do.for(:call)

  def call(params)
    values = yield validate(params)
    account = yield create_account(values[:account])
    owner = yield create_owner(account, values[:owner])

    Success(account: account, owner: owner)
  end

  def validate(params)
    Success(params)
    # Failure(:invalid_data)
  end

  def create_account(account_params)
    account = Account.new(account_params)
    Success(account)
    # Failure(:account_not_created)
  end

  def create_owner(account, owner_params)
    # owner = Owner.new(owner_params, account)
    # Success(owner)
    Failure[:owner_not_created, "Owner not created!"]
  end
end

result = CreateAccount.new.call(account: 'a1', owner: 'u1')
pp result.success?
pp result.value_or("BOOM!")
pp result
# pp result.trace
pp result.success
pp result.failure
