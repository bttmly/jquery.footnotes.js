Footnotify =
  
  # if you want to use different selectors or IDs, pass an object like this to Footnotify.init()
  config : 
    link : "sup.fnify-ref"
    note : "span.fnify-note"
    holder : ".footnotes"
    refIdStem : "fnify-ref-"
    noteIdStem : "fnify-note-"
    
  getElements : ->
    $links : $(this.config.link)
    $notes : $(this.config.note)
    $holder : $(this.config.holder)
  
  # init() will use getElements() to fill this with jQuery objects 
  # based on the values of config when init() is called.
  el : {}

  setupRefs : (links) ->
    noteStem = this.config.noteIdStem
    refStem  = this.config.refIdStem
    links.each (i) ->
      $(this)
        .html("[#{i+1}]")
        .wrap("<a href='##{noteStem}#{i+1}'>")
        .attr("id", "#{refStem}#{i+1}")
  
  setupNotes : (notes) ->
    noteStem = this.config.noteIdStem
    refStem  = this.config.refIdStem
    notes.each (i) ->
      $(this)
        .prepend("<sup><a href='##{refStem}#{i+1}'>[#{i+1}]</a></sup> ")
        .attr(
          id : "#{noteStem}#{i+1}"
        )
        .appendTo(Footnotify.config.holder)
        .wrap("<li>")

  calcOffsets : (links, notes, holder) ->
    holderTop = holder.offset().top
    i = 0
    lowestNote = 0

    while i < notes.length
      refTop = links.eq(i).offset().top
      
      # this logic could be improved.
      if refTop < holderTop
        if refTop < lowestNote
          noteTop = lowestNote
        else
          noteTop = holderTop
      else
        if refTop < lowestNote
          noteTop = lowestNote
        else
          noteTop = refTop

      notes.eq(i).parent("li").css("top", noteTop)
      lowestNote = notes.eq(i).offset().top + notes.eq(i).height()
      i++
  
  uiBind : ->
    # should use a debounced resize event here.
    # in Chrome zoom triggers resize; is this the case for all browsers?
    $(window).bind 'resize', =>
      this.calcOffsets(this.el.$links, this.el.$notes, this.el.$holder )
  
  init : (config) ->
    
    if config && typeof(config) is 'object'
      $.extend(this.config, config)
      
    el = this.el = this.getElements()

    if el.$links.length isnt el.$notes.length
      console.warn "Note/ref length mismatch."
    
    this.setupRefs(el.$links)
    this.setupNotes(el.$notes, el.$links)
    this.calcOffsets(el.$links, el.$notes, el.$holder)
    this.uiBind()
    
Footnotify.init()