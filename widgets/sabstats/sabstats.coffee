class Dashing.Sabstats extends Dashing.Widget

  @accessor 'sabnzbd_paused', ->
    @get('sabnzbd_status_paused')

  @accessor 'sabnzbd_mbps', ->
    mbits = @get('sabnzbd_status_kbitspersec') * 0.001
    res = Math.round(mbits*100)/100
    res.toFixed(2).toString() + " MBps"

  @accessor 'sabnzbd_mbits_left', ->
    @get('sabnzbd_status_mbits_left')

  @accessor 'sabnzbd_time_left', ->
    @get('sabnzbd_status_time_left')

