require 'net/http'
require 'logger'
require 'json'
require 'uri'
SCHEDULER.every '1s', :first_in => 0 do |job|

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  server_status = true

  begin
    uri = URI.parse(ENV['HEADPHONES_API_URL'])
    params = {'apikey' => ENV['HEADPHONES_API_KEY'],
              'cmd' => 'getVersion'}
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
  rescue StandardError => e
    logger.error 'Could not connect to %s' % ENV['HEADPHONES_API_URL']
    logger.debug e
    server_status = false
  end

  if server_status and response.code == '200'
    result = JSON.parse(response.body)
    send_event('media_overview', { headphones_status: (result['install_type'] == 'git') })
  else
    logger.error 'headphones is not up at the moment'
    send_event('media_overview', { headphones_status: false })
  end

end
