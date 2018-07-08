require 'sequel'

RACK_ENV = (ENV['RACK_ENV'] || 'development').to_sym
DB = Sequel.connect(ENV['DB_URL'])

autoload :User, 'app/models/user'

if RACK_ENV == :production
  # load production environment settings
  require 'google/cloud/storage'
  storage = Google::Cloud::Storage.new
  bucket = storage.bucket ENV['GOOGLE_CLOUD_STORAGE_BUCKET']
  file = bucket.file '.envrc'
  downloaded = file.download
  downloaded.rewind
  downloaded.each_line do |line|
    ENV[$1] = $2 if line =~ /^export (\w+)="(.*)"$/
  end
end
