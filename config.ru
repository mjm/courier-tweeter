#\ -p 5001
$LOAD_PATH.unshift(File.expand_path('.'))
require 'app'

use DocHandler
use Courier::Middleware::JWT
run App
