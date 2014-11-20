class Dashing.Trstats extends Dashing.Widget

  @accessor 'transmission_activetorrents', ->
    @get('transmission_status_activetorrents')

  @accessor 'transmission_uploadspeed', ->
    mbits = @get('transmission_status_uploadspeed') * 0.000001
    res = Math.round(mbits*100)/100
    res.toFixed(2).toString() + " MBps"

  @accessor 'transmission_downloadspeed', ->
    mbits = @get('transmission_status_downloadspeed') * 0.000001
    res = Math.round(mbits*100)/100
    res.toFixed(2).toString() + " MBps"

