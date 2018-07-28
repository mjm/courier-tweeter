require 'courier/tweeter/version'
require 'courier/tweeter/service_twirp'

class Courier::TweeterClient
  class << self
    def connect(**options)
      new(create_connection(**options))
    end

    private

    def create_connection(url: ENV['COURIER_TWEETER_URL'],
                          token: nil,
                          logger: false)
      Faraday.new(url) do |conn|
        conn.request :authorization, 'Bearer', token if token
        conn.response :logger if logger
        conn.adapter :typhoeus
      end
    end
  end
end
