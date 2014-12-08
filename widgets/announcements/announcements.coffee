class Dashing.Announcements extends Dashing.Widget

  get_date = (epoch) ->
    month_names = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ]
    d = new Date(0)
    d.setUTCSeconds(epoch)
    mdate = ("0" + d.getDate()).slice(-2)
    month_names[d.getMonth()] + " " + mdate + ", " + d.getFullYear()

  timestamp_sort = (a,b) ->
    if parseInt(a.timestamp) < parseInt(b.timestamp)
      return -1
    else if parseInt(a.timestamp) > parseInt(b.timestamp)
      return 1
    else
      return 0

  @accessor 'announcements', ->
    items = @get('announcements_raw')
    items.sort timestamp_sort
    items.reverse()
    for item in items
      item['timestamp'] = get_date item['timestamp']
    items 

