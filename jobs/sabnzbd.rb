require 'rest_client'
require 'logger'

SCHEDULER.every '1s', :first_in => 0 do |job|

  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG unless ENV['RACK_ENV'] == 'production'
  server_status = true

  begin
    http_response = RestClient.get ENV['SABNZBD_API_URL'], {:params =>{'mode' => 'queue', 'start' => 'START', 'limit' => 'LIMIT', 'output' => 'json'}}
  rescue Exception => e
    server_status = false
    logger.error 'Could not connect to %s' % ENV['SABNZBD_API_URL']
  end

  send_event('media_overview', { sabnzbd_status: (server_status ? http_response.code == 200 : false) })

end
