require 'dashing'

configure do
  set :auth_token, 'YOUR_AUTH_TOKEN'
  set :default_dashboard, 'dashboard/sample'

  helpers do
    def protected!
     # Put any authentication code you want in here.
     # This method is run before accessing any resource.
    end
  end
end

set :assets_prefix, '/dashboard/assets'
map Sinatra::Application.assets_prefix do
  run Sinatra::Application.sprockets
end

run Rack::URLMap.new('/dashboard' => Sinatra::Application)
