Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :username, null: false, unique: true
      String :name, null: false, default: ''
      String :access_token
      String :access_token_secret
    end
  end
end
