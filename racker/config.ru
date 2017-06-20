require '../lib/racker'
require 'dalli'
require 'rack/cache'

use Rack::Cache,
  verbose:  true,
  metastore:    "memcached://localhost:11211/meta",
  entitystore:  "memcached://localhost:11211/body",
  urls: ['/stylesheets'],
  root: '../public'
run Racker
