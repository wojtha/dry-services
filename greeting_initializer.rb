require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default)

require 'dry/monads/do'
require 'dry/matcher/result_matcher'

loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup

operations = [
  Operations::Init::GreetClassic.new,
  Operations::Init::GreetWithBind.new,
  Operations::Init::GreetWithDo.new,
  Operations::Init::GreetWithMethodChain.new,
  # Operations::Init::GreetWithTransaction will fail as it uses Dry::Transaction together with Dry::Initializer
  Operations::Init::GreetWithTransaction.new,
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
