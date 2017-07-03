require './lib/racker'
require 'yaml'

app = Rack::Builder.new do
  use Rack::Reloader, 0
  use Rack::Static, urls: ['/stylesheets'], root: 'public'
  use Rack::Session::Cookie, key: 'rack.session',
                             path: '/',
                             expire_after: 2_592_000,
                             secret: 'change_me'
  run Racker
end

run app
