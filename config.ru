$LOAD_PATH.unshift(File.expand_path('./lib'))
require 'courier/tweeter/app'

run Courier::Tweeter::App
