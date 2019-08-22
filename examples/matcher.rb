require "dry/monads/result"
require "dry/matcher/result_matcher"

#value = Dry::Monads::Success("success!")
#value = Dry::Monads::Failure[:not_found, "This or that was not found"]
value = Dry::Monads::Failure[:kaboom]
#value = Dry::Monads::Failure[:kaboom, "KABOOM!"]

result = Dry::Matcher::ResultMatcher.(value) do |m|
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

pp result # => "Yay: success!"
