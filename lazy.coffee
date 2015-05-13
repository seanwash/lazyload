class LazyLoad
  constructor: (lazySelector, container) ->
    return console.error 'LazyLoad: LazySelector is not defined' unless lazySelector?.length
    return console.error 'LazyLoad: Container is not defined' unless container?.length

    @container = $(container)
    @lazySelector = lazySelector
    @lazyItems = @container.find(lazySelector)
    @wh = $(window).height()
    @itemOffsets = []

    @updateOffsets()
    @checkOffsets()

    @container.on 'scroll', (e) => @checkOffsets()


  updateOffsets: =>
    for item in @lazyItems
      @itemOffsets.push $(item).offset().top


  checkOffsets: =>
    wscroll = @container.scrollTop()
    itemsToRemove = []

    for offset, i in @itemOffsets
      if offset <= wscroll + @wh + 200

        # Get all items that haven't already been loaded
        el = $(@lazySelector).not('.lazy-loaded').eq(i)
        return unless el.data('src')?.length

        # Load image
        @loadImage el
        # Add loaded el into items offset to remove so it doesn't
        # try to load that offset again
        itemsToRemove.push offset

    # Remove items with loaded images from list
    @itemOffsets = _.without @itemOffsets, itemsToRemove


  loadImage: (el) ->
    img = new Image()
    src = el.data 'src'
    img.src = src

    img.onload = =>
      @setBackgroundImage el, src
      el.addClass 'lazy-loaded'


  setBackgroundImage: (el, src) =>
    el[0].style.backgroundImage = "url('#{src}')"
    @removeSrcDataAttr el


  removeSrcDataAttr: (el) ->
    el.removeAttr 'data-src'


  revalidate: =>
    @updateOffsets()
    @checkOffsets()
