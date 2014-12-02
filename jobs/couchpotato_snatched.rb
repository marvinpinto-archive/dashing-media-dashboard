require 'net/http'
require 'logger'
require 'json'
SCHEDULER.every '5m', :first_in => 0 do |job|

  logger = Logger.new(STDOUT)
  logger.level = Logger::INFO
  server_status = true

  url_string = ENV['COUCHPOTATO_API_URL'] +
    '/' +
    ENV['COUCHPOTATO_API_KEY'] +
    '/media.list/'

  begin
    uri = URI.parse(url_string)
    params = {'type' => 'movie',
              'release_status' => 'snatched'}
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
    movie_array = Array.new
    result['movies'].each do |child|
      movie_data = {'link' => 'http://www.imdb.com/title/' + child['info']['imdb'],
                    'name' => child['info']['original_title'],
                    'jpgsrc' => child['info']['images']['poster_original'][0]}
      movie_array.push(movie_data)
    end
    send_event('available_movies', { posters_raw: movie_array })
  else
    logger.error '%s is not reachable the moment' % ENV['COUCHPOTATO_API_URL']
    send_event('available_movies', { posters_raw: [] })
  end

end
