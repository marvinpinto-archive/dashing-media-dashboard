require 'net/http'
require 'logger'
require 'json'
SCHEDULER.every '1s', :first_in => 0 do |job|

  logger = Logger.new(STDOUT)
  logger.level = Logger::DEBUG
  server_status = true

  url_string = ENV['COUCHPOTATO_API_URL'] +
    '/' +
    ENV['COUCHPOTATO_API_KEY'] +
    '/app.available'

  begin
    uri = URI.parse(url_string)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.path)
    response = http.request(request)
  rescue StandardError => e
    logger.error 'Could not connect to %s' % ENV['COUCHPOTATO_API_URL']
    logger.debug e
    server_status = false
  end

  if server_status and response.code == '200'
    result = JSON.parse(response.body)
    send_event('media_overview', { couchpotato_status: result['success'] })
  else
    send_event('media_overview', { couchpotato_status: false })
  end

end
