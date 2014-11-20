require 'net/http'
require 'logger'

SCHEDULER.every '2s', :first_in => 0 do |job|

  def transmission_rpc(logger, session_id)
    begin
      uri = URI.parse(ENV['TRANSMISSION_API_URL'])
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.path)
      request.add_field('X-Transmission-Session-Id', session_id)
      request.body = '{"method":"session-stats"}'
      response = http.request(request)
      return response
    rescue StandardError => e
      logger.error 'Could not connect to %s' % ENV['TRANSMISSION_API_URL']
      logger.debug e
      return nil
    end
  end

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  server_status = true
  session_id = ''

  # This is quite inefficient as transmission returns a 409 if the 'correct'
  # x_transmission_session_id isn't sent, and I can think of no good way to
  # store and persist that session ID for reusability (between API calls)

  response = transmission_rpc(logger, session_id)
  if response
    session_id = response['X-Transmission-Session-Id']
    response = transmission_rpc(logger, session_id)
    result = JSON.parse(response.body)
    send_event('media_overview', { transmission_status: true })
    send_event('transmission_status', {
      transmission_status_activetorrents: result['arguments']['activeTorrentCount'],
      transmission_status_uploadspeed: result['arguments']['uploadSpeed'],
      transmission_status_downloadspeed: result['arguments']['downloadSpeed'],
    })
  else
    logger.error 'transmission is not up at the moment'
    send_event('media_overview', { transmission_status: false })
    send_event('transmission_status', {
      transmission_status_activetorrents: "N/A",
      transmission_status_uploadspeed: 0,
      transmission_status_downloadspeed: 0,
    })
  end

end
