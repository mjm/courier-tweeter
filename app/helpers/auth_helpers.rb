module AuthHelpers
  def current_user
    return request.env['user'] if request.env['user']

    jwt = request.env['jwt.payload']
    return nil unless jwt

    user = User.lookup(jwt['sub'])
    return nil unless user

    request.env['user'] = user
    user
  end

  def service_client?
    request.env.fetch('jwt.payload', {}).fetch('roles', []).include? 'service'
  end

  def check_user(user = nil)
    return if service_client?

    if user
      return if current_user.id == user.id
      error 403
    else
      return if current_user
      error 401
    end
  end
end
