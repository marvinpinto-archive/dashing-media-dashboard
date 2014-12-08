class Dashing.Posters extends Dashing.Widget

  @accessor 'posters', ->
    setlimit = if @get('setlimit') then @get('setlimit') else 8
    items = @get('posters_raw')
    limit = if items.length < 8 then items.length else setlimit
    items = items[0..limit]
    items 

