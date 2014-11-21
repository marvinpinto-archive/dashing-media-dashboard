require 'net/http'
require 'logger'
require 'json'
SCHEDULER.every '1h', :first_in => 0 do |job|

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  server_status = true

  begin
    uri = URI.parse(ENV['PLEX_ANNOUNCEMENTS_URL'])
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(uri.path)
    response = http.request(request)
  rescue StandardError => e
    logger.error 'Could not connect to %s' % ENV['PLEX_ANNOUNCEMENTS_URL']
    logger.debug e
    server_status = false
  end

  if server_status and response.code == '200'
    result = JSON.parse(response.body)
    result = result.sort_by{ |e| e['timestamp'].to_i }
    result.reverse!
    result = result.slice(0,4)
    send_event('plex_announcements', { announcements_raw: result })
  else
    logger.error '%s is not reachable the moment' % ENV['PLEX_ANNOUNCEMENTS_URL']
    send_event('plex_announcements', { announcements_raw: [] })
  end

end
