class Dashing.Posters extends Dashing.Widget

  @accessor 'posters', ->
    items = @get('posters_raw')
    limit = if items.length < 8 then items.length else 8
    items = items[0..limit]
    items 

