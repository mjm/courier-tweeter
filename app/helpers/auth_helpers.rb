module AuthHelpers
  def require_service_client
    return if service_client?
    if current_user
      error 403
    else
      error 401
    end
  end

  def token
    request.env['jwt.token']
  end

  def current_user
    return request.env['user'] if request.env['user']

    return nil unless token

    user = User.lookup(token.subject)
    return nil unless user

    request.env['user'] = user
    user
  end

  def service_client?
    return false unless token

    token.role? :service
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
