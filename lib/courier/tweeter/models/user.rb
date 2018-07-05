module Courier
  module Tweeter
    class User < Sequel::Model(DB[:users])
      def self.register(attrs)
        dataset.insert_conflict(
          target: :username,
          update: attrs.reject { |k, _| k == :username }
        ).insert(attrs)
      end
    end
  end
end
