class Dashing.Posters extends Dashing.Widget

  @accessor 'posters', ->
    setlimit = if @get('setlimit') then @get('setlimit') else 8
    items = @get('posters_raw')
    limit = Math.min(items.length, setlimit)
    items = items[0..limit-1]
    items 

