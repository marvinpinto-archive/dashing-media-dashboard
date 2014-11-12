require 'net/http'
require 'logger'

SCHEDULER.every '1s', :first_in => 0 do |job|

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  server_status = true

  begin
    uri = URI.parse(ENV['SABNZBD_API_URL'])
    params = {'mode' => 'queue',
              'start' => 'START',
              'limit' => 'LIMIT',
              'output' => 'json'}
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.path)
    request.set_form_data(params)
    response = http.request(request)
  rescue StandardError => e
    logger.error 'Could not connect to %s' % ENV['SABNZBD_API_URL']
    logger.debug e
    server_status = false
  end

  if server_status and response.code == '200'
    send_event('media_overview', { sabnzbd_status: true })
  else
    send_event('media_overview', { sabnzbd_status: false })
  end

end
