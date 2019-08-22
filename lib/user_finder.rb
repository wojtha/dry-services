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
