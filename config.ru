require './lib/racker'

Racks = Rack::Builder.new do
  use Rack::Static, urls: ['/stylesheets'], root: 'public'
  use Rack::Session::Cookie, :key => 'rack.session',
                             :domain => 'localhost',
                             :path => '/',
                             :expire_after => 2592000,
                             :secret => 'change_me'
  run Racker
end

run Racks
