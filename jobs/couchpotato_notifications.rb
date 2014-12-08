require 'net/http'
require 'logger'
require 'json'
SCHEDULER.every '5m', :first_in => 0 do |job|

  def parse_message(message, read)
    prefix = ""
    if not read
      prefix = "*new* "
    end
    return prefix + message.gsub(/ \".*\"/, '')
  end

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  server_status = true

  url_string = ENV['COUCHPOTATO_API_URL'] +
    '/' +
    ENV['COUCHPOTATO_API_KEY'] +
    '/notification.listener/'

  begin
    uri = URI.parse(url_string)
    params = {'init' => 'true'}
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  rescue StandardError => e
    logger.error 'Could not connect to %s' % ENV['COUCHPOTATO_API_URL']
    logger.debug e
    server_status = false
  end

  if server_status and response.code == '200'
    result = JSON.parse(response.body)
    notification_array = Array.new
    result['result'].each do |child|
      notification_data = {'link' => ENV['COUCHPOTATO_WEB_URL'],
                           'title' => parse_message(child['message'], child['read']),
                           'timestamp' => child['time']}
      notification_array.push(notification_data)
    end
    send_event('couchpotato_notifications', { announcements_raw: notification_array })
  else
    logger.error '%s is not reachable the moment' % ENV['COUCHPOTATO_API_URL']
    send_event('couchpotato_notifications', { announcements_raw: [] })
  end

end
