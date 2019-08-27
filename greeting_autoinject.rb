require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default)

require 'dry/monads/do'
require 'dry/matcher/result_matcher'

loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup

class Container
  extend Dry::Container::Mixin

  register('user_finder') { UserFinder.new }

  namespace('greeting') do
    register('authorization') { Greeting::Authorization.new }
    register('validation') { Greeting::Validation.new }
    register('greet_user') { Greeting::GreetUser.new }
  end

  register('operations.greet_classic') { Operations::Auto::GreetClassic.new }
  register('operations.greet_with_bind') { Operations::Auto::GreetWithBind.new }
  register('operations.greet_with_do') { Operations::Auto::GreetWithDo.new }
  register('operations.greet_with_method_chain') { Operations::Auto::GreetWithMethodChain.new }
  register('operations.greet_with_transaction') { Operations::Auto::GreetWithTransaction.new }
end

Import = Dry::AutoInject(Container)

operations = [
  Container.resolve('operations.greet_classic'),
  Container.resolve('operations.greet_with_bind'),
  Container.resolve('operations.greet_with_do'),
  Container.resolve('operations.greet_with_method_chain'),
  Container.resolve('operations.greet_with_transaction'),
]

params = { user_id: 1, greeting: 'Hello' }

operations.each do |operation|
  puts
  puts operation.class.name
  puts
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
  puts '_______________________________________________________________________'
end
