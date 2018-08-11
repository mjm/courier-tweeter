class User < Sequel::Model(DB[:users])
  def self.register(attrs)
    id = dataset.insert_conflict(
      target: :username,
      update: attrs.reject { |k, _| k == :username }
    ).insert(attrs)
    self[id]
  end

  dataset_module do
    def lookup(username)
      where(username: username).first
    end
  end

  def tweet(body)
    twitter.update(body)
  end

  def to_proto
    Courier::User.new(
      id: id,
      username: username,
      name: name,
      access_token: access_token,
      access_token_secret: access_token_secret
    )
  end

  private

  def twitter
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['TWITTER_CONSUMER_API_KEY']
      config.consumer_secret = ENV['TWITTER_CONSUMER_API_SECRET']
      config.access_token = access_token
      config.access_token_secret = access_token_secret
    end
  end
end
