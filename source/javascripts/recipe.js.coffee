(($) ->
  RecipeComponents = {}
  Recipe = Backbone.Model.extend(
    urlRoot: "/recipes"
    defaults: {  } # put token to this
  )
  RecipeShow = Backbone.View.extend(
    initialize: (params) ->
      theRecipe = @
      recipeData = if params.data then params.data else {}
      $el = theRecipe.$el
      theRecipe.model = new Recipe recipeData
      theRecipe.type = params.type || "recipe-detail"
      unless params.type
        switch true
          when $el.is(".sticky-card")
            theRecipe.type = "sticky-card"
          when $el.is(".new-recipe-card")
            theRecipe.type = "new-recipe-card"
          else
            theRecipetype = "recipe-detail"
      for key, value of RecipeComponents
        ((key, value) ->
          value.init.apply(theRecipe)
        )(key, value)
      @getInfo()
      @
    events: {}
    getInfo: () ->
      model = @model
      data = model.toJSON()

      data.$follow = @findElm("follow")
      data.$fbShare = @findElm("fbShare")
      data.$favoritesCount = @findElm("favoritesCount")
      data.$viewsCount = @findElm("viewsCount")

      if jQuery.isEmptyObject(model.toJSON())
        #console.group()
        #console.log @type
        data.id = @$el.attr("data-recipe-id")
        data.url = "/recipes/" + data.id
        $title = @findElm("title")
        data.name = if $title then $title.attr("title") || $title.html() else ""
        data.cover_picture = @findElm("image").attr("src")
        if data.$favoritesCount
          favoritesHtml = data.$favoritesCount.html()
          data.favorites_count = favoritesHtml.slice(favoritesHtml.search(/[\d]+$/))
        if data.$viewsCount
          viewsHtml = data.$viewsCount.html()
          data.views_count = viewsHtml.slice( viewsHtml.search(/[\d]+$/) )
        model.set(
          id: data.id
          favorites_count: data.favorites_count
          image: data.cover_picture
          name: data.name
          url: data.url
          views_count: data.views_count
        )
        #console.log(data)
        #console.groupEnd()
      data
    findElm: (name) ->
      $el = @$el
      componentMap =
        "title": "a[title]"
        "image": "img"
        "follow": ".btn-follow-recipe"
        "list": ""
        "favoritesCount": ".like-count"
        "viewsCount": ".views-count"
      spMap =
        "new-card": {}
        "sticky-card":
          "favoritesCount": ".favorite-count"
        "recipe-detail":
          "title": "h1[itemprop='name']"
          "fbShare": ".btn-facebook"
          "viewsCount": ".view-count"
          "favoritesCount": ".fav-count"
      mapping = $.extend({}, componentMap, spMap[@type])
      $theElm = if mapping[name] then $el.find(mapping[name]) else []
      #console.log(name)
      #console.log($theElm.length)
      if $theElm.length then $theElm else null
  )

  $.fn.recipe = (options) ->
    isDom = if @selector.length then true else false
    $elms = null
    #console.log(isDom)
    # this is not element
    # this is element
    opts = $.extend({}, $.fn.recipe.defaults, options)
    if isDom
      $elms = $(@)
      $elms.each((idx) ->
        $(@).data("recipe", new RecipeShow({
          el: $(@)
          data: if opts.data then opts.data[idx] else null
        }))
      )

  $.fn.recipe.defaults = {}
  $.fn.recipe.extend = (key, opts, callback=() ->) ->
    if typeof key isnt "string"
      return
    opts = $.extend({
      init: () ->
      events: {}
      modelMethod: {}
    }, opts)
    RecipeComponents[key] = opts
    RecipeShow.prototype.events = _.extend({}, RecipeShow.prototype.events, opts.events)
    Recipe.prototype = _.extend({}, Recipe.prototype, opts.modelMethod)
    callback()
    RecipeShow
)(window.jQuery)