class User < Dry::Struct
  attribute :name, Types::Strict::String
  attribute :greeting_enabled, Types::Strict::Bool
end
