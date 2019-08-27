require 'rubygems' unless defined?(Gem)
require 'bundler/setup'
Bundler.require(:default)

require 'dry/system/container'
require 'dry/monads/do'
require 'dry/matcher/result_matcher'

loader = Zeitwerk::Loader.new
loader.push_dir('./lib')
loader.setup

class Container < Dry::System::Container
  # use :env
  # use :logging
  # use :monitoring
  # use :dependency_graph

  configure do |config|
    config.root = Pathname(__dir__)

    # we set 'lib' relative to `root` as a path which contains class definitions
    # that can be auto-registered
    config.auto_register = %w[lib]
  end

  # this alters $LOAD_PATH hence the `!`
  load_paths!('lib')
end

Import = Container.injector

Container.finalize!

p Container.keys

operations = [
  Container.resolve('operations.auto.greet_classic'),
  Container.resolve('operations.auto.greet_with_bind'),
  Container.resolve('operations.auto.greet_with_do'),
  Container.resolve('operations.auto.greet_with_method_chain'),
  Container.resolve('operations.auto.greet_with_transaction'),
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
