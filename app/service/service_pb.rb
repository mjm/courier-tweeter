# Generated by the protocol buffer compiler.  DO NOT EDIT!
# source: app/service/service.proto

require 'google/protobuf'

Google::Protobuf::DescriptorPool.generated_pool.build do
  add_message "courier.RegisterUserRequest" do
    optional :username, :string, 1
    optional :name, :string, 2
    optional :access_token, :string, 3
    optional :access_token_secret, :string, 4
  end
  add_message "courier.PostTweetRequest" do
    optional :username, :string, 1
    optional :user_id, :int32, 4
    optional :body, :string, 2
    repeated :media_urls, :string, 3
  end
  add_message "courier.User" do
    optional :id, :int32, 1
    optional :username, :string, 2
    optional :name, :string, 3
    optional :access_token, :string, 4
    optional :access_token_secret, :string, 5
  end
  add_message "courier.Tweet" do
    optional :id, :string, 1
    optional :text, :string, 2
  end
end

module Courier
  RegisterUserRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("courier.RegisterUserRequest").msgclass
  PostTweetRequest = Google::Protobuf::DescriptorPool.generated_pool.lookup("courier.PostTweetRequest").msgclass
  User = Google::Protobuf::DescriptorPool.generated_pool.lookup("courier.User").msgclass
  Tweet = Google::Protobuf::DescriptorPool.generated_pool.lookup("courier.Tweet").msgclass
end
