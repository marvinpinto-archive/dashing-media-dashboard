require 'dashing'
require 'dotenv'

Dotenv.load 'settings.ini'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :default_dashboard, ENV['WEB_BASE'] + '/media'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

set :assets_prefix, ENV['WEB_BASE'] + '/assets'
map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Rack::URLMap.new(ENV['WEB_BASE'] => Sinatra::Application)
