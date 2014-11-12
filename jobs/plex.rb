require 'net/http'
require 'logger'

SCHEDULER.every '1s', :first_in => 0 do |job|

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  server_status = true

  begin
    uri = URI.parse('%s/' % ENV['PLEX_API_URL'])
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.path)
    response = http.request(request)
  rescue StandardError => e
    logger.error 'Could not connect to %s' % ENV['PLEX_API_URL']
    logger.debug e
    server_status = false
  end

  if server_status and response.code == '200'
    send_event('media_overview', { plex_status: true })
  else
    send_event('media_overview', { plex_status: false })
  end

end
