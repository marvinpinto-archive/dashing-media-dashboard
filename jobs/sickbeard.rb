require 'net/http'
require 'logger'
require 'json'
SCHEDULER.every '1s', :first_in => 0 do |job|

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  server_status = true

  url_string = ENV['SICKBEARD_API_URL'] + '/' + ENV['SICKBEARD_API_KEY'] + '/'

  begin
    uri = URI.parse(url_string)
    params = {'cmd' => 'sb.ping'}
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  rescue StandardError => e
    logger.error 'Could not connect to %s' % ENV['SICKBEARD_API_URL']
    logger.debug e
    server_status = false
  end

  if server_status and response.code == '200'
    result = JSON.parse(response.body)
    send_event('media_overview', { sickbeard_status: result['result'] == 'success' })
  else
    logger.error 'sickbeard is not up at the moment'
    send_event('media_overview', { sickbeard_status: false })
  end

end
