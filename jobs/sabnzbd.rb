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
    uri.query = URI.encode_www_form(params)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.set_form_data(params)
    response = http.request(request)
  rescue StandardError => e
    logger.error 'Could not connect to %s' % ENV['SABNZBD_API_URL']
    logger.debug e
    server_status = false
  end

  if server_status and response.code == '200'
    result = JSON.parse(response.body)
    send_event('media_overview', { sabnzbd_status: true })
    send_event('sabnzbd_status', {
      sabnzbd_status_paused: result['queue']['status'],
      sabnzbd_status_kbitspersec: result['queue']['kbpersec'],
      sabnzbd_status_mbits_left: result['queue']['mbleft'],
      sabnzbd_status_time_left: result['queue']['timeleft'],
    })
  else
    logger.error 'sabnzbd is not up at the moment'
    send_event('media_overview', { sabnzbd_status: false })
    send_event('sabnzbd_status', {
      sabnzbd_status_paused: "N/A",
      sabnzbd_status_kbitspersec: 0,
      sabnzbd_status_mbits_left: 0,
      sabnzbd_status_time_left: 0,
    })
  end

end
