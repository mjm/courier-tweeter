module Courier
  module Tweeter
    class User < Sequel::Model(DB[:users])
    end
  end
end
