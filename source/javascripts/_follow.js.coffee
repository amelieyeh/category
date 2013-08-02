(($) ->
  unless $.fn.recipe
    return
  storage = if localStorage then localStorage else window.DocCookies
  getAuthToken = () ->
    key = $("[name=csrf-param]").attr("content")
    val = $("[name=csrf-token]").attr("content")
    {
      key: key
      val: val
    }
  User = Backbone.Model.extend(
    update: (attr) ->
      $.ajax(
        url: "/user/" + @get("name")
        data: attr
        dataType: "json"
        type: "PUT"
      )
  )
  user = new User()
  listRecipeNow = "list_recipe_now"
  users = null
  userInit = () ->
    if ICOOK? and ICOOK.current_user.length
      users = storage.getItem("users")
      if users
        users = JSON.parse(users)
      else
        users = {}
      #currentUser = users[ICOOK.current_user]
      userInfo =
        #"name": ICOOK.current_user
        "list_recipe_now": true
      if currentUser
        userInfo[listRecipeNow] = currentUser[listRecipeNow] if typeof currentUser[listRecipeNow] isnt "undefined"
      #users[ICOOK.current_user] = userInfo
      user.set(userInfo)
  userInit()
  List = Backbone.Model.extend(
    defaults: {  } # put token to this
    update: (data) ->
      $.ajax(
        url: @url()
        dataType: "json"
        type: "PUT"
        data: data
      )
  )
  ListCollection = Backbone.Collection.extend(
    model: List
  )
  ListItem = Backbone.View.extend(
    tagName: "li"
    attributes: () ->
      {
        "data-id": @model.id
      }
    events:
      "mouseover.listItem": "mouseover"
      "mouseout.listItem": "mouseout"
      "click.listItem input": "clickChecker"
      "click.listItem": "clickChecker"
    mouseover: (e) ->
      @$el.addClass("list-background")
      @
    mouseout: (e) ->
      unless @$el.find(":checked").length
        @$el.removeClass("list-background")
      @
    clickChecker: (e) ->
      e.stopPropagation()
      if $(e.target).is("input")
        @$el.toggleClass("list-on")
      else
        @$el.find("input").trigger("click.listItem")
    toggleState: () ->
      $el = @$el
      $input = $el.find("input")
      state = if $input.attr("checked") then false else true
      $el.find("input").attr("checked", state)
      $el.toggleClass("list-background")
    render: (checked) ->
      @$el.html(HandlebarsTemplates["recipes/list_item"](@model.attributes))
      checked and @toggleState()
      @
  )
  listCollection = new ListCollection()
  ListModal = Backbone.View.extend(
    initialize: (params) ->
      @collection = listCollection
      @recipeInfo = params.recipeInfo
      console.log typeof window.HandlebarsTemplates
      #console.log typeof window.HandlebarsTemplates["recipes/list_modal"]
      #@$el.html(HandlebarsTemplates["recipes/list_modal"](params.recipeInfo))
      @
    events:
      "click.listModal input": "clickInput"
      "click.listModal .add-btn": "clickAdd"
      "click.listModal .submit-btn": "clickSubmit"
      "click.listModal .cancel-btn": "clickCancel"
      "click.listModal .list-recipe-now input": "clickListNow"
      "click.listModal .list-recipe-now": "clickListNow"
    clickInput: (e) ->
      $target = $(e.target)
      if $target.is("[type='text']")
        $target.removeClass("error-input")
        $target.val("")
    clickAdd: (e) ->
      e.preventDefault()
      e.stopPropagation()
      $input = $(e.target).parents("#add-list").find("input")
      val = $input.val()
      val = "" if (/隢�敺‵撖怠�蝔勗嚗�/g).test(val)
      !val.length and $input.val("")
      if val.length
        authToken = getAuthToken()
        data =
          list:
            name: val
          #user_id: ICOOK.current_user
        data[authToken.key] = authToken.val
        $ul = @$el.find("ul")
        $ul.parent().scrollTop(0)
        @collection.create(data,
          success: (item) ->
            view = new ListItem(
              model: item
            )
            $ul.prepend(view.render().el)
            @
        )
      else
        $input.addClass("error-input")
        $input.val("隢�敺‵撖怠�蝔勗嚗�")
      @
    clickSubmit: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @isSubmit = true
      @$el.parent().modal("hide")
      @
    clickCancel: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @$el.parent().modal("hide")
      @
    clickListNow: (e) ->
      e.stopPropagation()
      @clickedListNow = true
      $immediate = @$el.find(".list-recipe-now input")
      unless $(e.target).is("input")
        checked = if $immediate.attr("checked") then false else true
        @setListNow(checked)
      checked = if $immediate.attr("checked") then true else false
      storage.setItem("users", JSON.stringify(users))
      @
    updateListNow: () ->
      if @clickedListNow
        $immediate = @$el.find(".list-recipe-now input")
        checked = if $immediate.attr("checked") then true else false
        _gaq.push(['_trackEvent', 'Recipe', 'Update-List-Recipe-Now', if checked then "choose" else "cancel"])
        user.set(listRecipeNow, checked)
        authToken = getAuthToken()
        data = {}
        data[authToken.key] = authToken[authToken.val]
        data.user =
          list_recipe_now: checked
          username: user.get("name")
        user.update(data)
        users[user.get("name")] = user.toJSON()
        storage.setItem("users", JSON.stringify(users))
      @
    setListNow: (checked) ->
      $immediate = @$el.find(".list-recipe-now input")
      #console.log checked
      $immediate.attr("checked", checked)
      @
    onShow: () ->
      theModal = @
      @isSubmit = false
      @clickedListNow = false
      recipeInfo = @recipeInfo
      authToken = getAuthToken()
      data = {}
      data[authToken.key] = authToken[authToken.val]
      #data.user_id = ICOOK.current_user
      #@collection.url = "/user/" + 
      .current_user + "/lists"
      @collection.url = ""
      @collection.fetch(
        data: data
        success: (collection) ->
          theModal.render(collection)
      )
      isListRecipeNow = user.get(listRecipeNow)
      @setListNow(isListRecipeNow)
      _gaq.push(['_trackEvent', 'Recipe', 'Added-to-list-clicked', recipeInfo.id + ' page: ' + document.location.pathname + document.location.search + ' ref: ' + document.referrer]);
      @
    onHide: () ->
      if @isSubmit
        $ul = @$el.find("ul")
        collection = @collection
        recipeId = @recipeInfo.id
        $listOn = $ul.find(".list-on")
        $listOn.each(() ->
          id = $(@).attr("data-id")
          theList = collection.get(id)
          theList.update({ recipe_id: recipeId })
        )
        @updateListNow()
      @
    render: (collection) ->
      idRegExp = new RegExp(":" + @recipeInfo.id + "}")
      $ul = @$el.find("ul").html("")
      collection.forEach((item, idx) ->
        recipes = item.toJSON().recipes
        recipesStr = JSON.stringify(recipes)
        isFollow = recipesStr.search(idRegExp)
        isFollow = if isFollow >= 0 then true else false
        view = new ListItem(
          model: item
        )
        $ul.append(view.render(isFollow).el)
      )
      @delegateEvents()
      @
  )
  modalEvents = true
  ListBtn = Backbone.View.extend(
    initialize: (params) ->
      @recipeInfo = params.recipeInfo
      $target = $(@$el.attr("href"))
      @$target = $target
      @listModalView = new ListModal(
        recipeInfo: params.recipeInfo
      )
      if modalEvents
        $target.on(
          "show": () ->
            theBtn = $target.data( "theListBtn" )
            if theBtn
              listModalView = theBtn.listModalView
              unless listModalView.$el.html().length
                listModalView.$el.html(HandlebarsTemplates["recipes/list_modal"](listModalView.recipeInfo))
              $target.html(listModalView.el)
              listModalView.onShow()
          "hide": () ->
            theBtn = $target.data( "theListBtn" )
            if theBtn
              theBtn.listModalView.onHide()
            $target.data( "theListBtn", null )
        )
        modalEvents = false
      @
    events:
      "click": "click"
    click: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @$target.data( "theListBtn", @ )
      @$target.modal("show")
  )
  RecipeFollow = Backbone.View.extend(
    initialize: (params) ->
      @type = params.type
      $list = @$el.siblings(".list-btn")
      unless $list.length
        listHtml = HandlebarsTemplates["recipes/list_btn"]()
        @$el.after(listHtml)
      @$list = @$el.siblings(".list-btn")
      switch @type
        when "recipe-detail"
          @$list.addClass("btn btn-danger")
      @listView = new ListBtn(
        el: @$list
        recipeInfo: params.recipeInfo
      )
      @recipeInfo = params.recipeInfo
      @showDesc()
      @
    events:
      "mouseover.follow": "mouseover"
      "mouseout.follow": "mouseout"
      "click.follow": "click"
    mouseover: (e) ->
      e.stopPropagation()
      @showDesc("over")
      @
    mouseout: (e) ->
      e.stopPropagation()
      @showDesc("out")
      @
    click: (e) ->
      e.preventDefault()
      e.stopPropagation()
      @toggleState("isEvent")
      @updateFavoritesCount()
      # must check user if exist
      ###if ICOOK.current_user
        @toggleState("isEvent")
        @updateFavoritesCount()
        @model.follow()
      else
        @model.cacheBeFollow()
        #$.getScript("/login.js?next=" + location.href)
        if /\%\w/.test(location.href)
          location.href = "/login?next=" + location.href
        else
          $.getScript("/login.js?next=" + location.href)
      ###
      @
    checkState: () ->
      state = "unfollow"
      state = "follow" if @$el.hasClass("btn-following-recipe")
      state
    showDesc: (mouseState) ->
      state = @checkState()
      $el = @$el
      $list = @$list
      recipeInfo = @recipeInfo
      $favoritesCount = recipeInfo.$favoritesCount
      switch state
        when "follow"
          desc = $el.attr("data-text-following")
          if mouseState is "over"
            desc = $el.attr("data-text-unfollow")
          $el.find("span").html(desc)
          $list and $list.removeClass("hidden")
          $favoritesCount and $favoritesCount.find("i").addClass("following")
        else
          desc = $el.attr("data-text-follow")
          $el.find("span").html(desc)
          $list and $list.addClass("hidden")
          $favoritesCount and $favoritesCount.find("i").removeClass("following")
    toggleState: (isEvent) ->
      @$el.toggleClass("btn-following-recipe")
      recipeInfo = @recipeInfo
      $favoritesCount = recipeInfo.$favoritesCount
      $favoritesCount.toggleClass("following-recipe")
      $heart = $favoritesCount.find("i")
      toggle = if $favoritesCount.hasClass("following-recipe") then "follow" else "unfollow"
      switch @type
        when "new-recipe-card"
          $heart.toggleClass("following")
        when "recipe-detail"
          $heart = @$el.find("i")
          $heart.toggleClass("icon-heart-empty")
          $heart.toggleClass("icon-heart")
      if isEvent
        #console.log "track-follow嚗�" + toggle
        if toggle is "follow"
          isListRecipeNow = user.get(listRecipeNow)
          isListRecipeNow and @$list.trigger("click")
        _gaq?.push( ['_trackSocial', 'icook', toggle + '-recipe', "/recipes/" + recipeInfo.id] )
        toggle = toggle.slice(0, 1).toUpperCase() + toggle.slice(1)
        _gaq?.push(['_trackEvent', 'Recipe', toggle, recipeInfo.id])
      @showDesc()
    updateFavoritesCount: () ->
      recipeInfo = @recipeInfo
      $favoritesCount = recipeInfo.$favoritesCount
      favoritesCount = recipeInfo.favorites_count
      state = @checkState()
      switch state
        when "follow"
          favoritesCount++
        else
          favoritesCount--
      if $favoritesCount
        favAttr = ( $favoritesCount.attr("data-title") )
        if favAttr
          favAttr = favAttr.replace(/^[\d]+/, favoritesCount)
          $favoritesCount.attr("data-title", favAttr)
          newHtml = ( $favoritesCount.html() ).replace(/[\d]+$/, favoritesCount)
          $favoritesCount.html(newHtml)
      recipeInfo.favorites_count = favoritesCount
  )
  $.fn.recipe.extend("follow", {
    init: () ->
      theRecipe = @
      recipeInfo = theRecipe.getInfo()
      $follow = recipeInfo.$follow
      unless $follow
        return
      theRecipe.followView = new RecipeFollow(
        el: $follow
        model: theRecipe.model
        type: theRecipe.type
        recipeInfo: recipeInfo
      )
    events: {}
    modelMethod:
      "follow": (data={}) ->
        theModel = @
        id = @get("id")
        data = $.extend({
          id: id
        }, data)
        $.ajax(
          url: @url() + "/follow"
          dataType: "json"
          type: "PUT"
          data: data
        ).error(() ->
          theModel.cacheBeFollow()
        ).done((result) ->
          #console.log "success"
          #console.log user
          user.set(listRecipeNow, result[listRecipeNow])
          users[user.get("name")] = user.toJSON()
          storage.setItem("users", JSON.stringify(users))
        )
      "cacheBeFollow": () ->
        id = @get("id")
        storage = if localStorage then localStorage else window.DocCookies
        recipeBeFollow = storage.getItem("recipeBeFollow")
        unless recipeBeFollow
          recipeBeFollow = "[]"
        recipeBeFollow = JSON.parse(recipeBeFollow)
        unless $.isArray( recipeBeFollow )
          recipeBeFollow = [recipeBeFollow]
        regexp = new RegExp(id)
        unless( regexp.test(recipeBeFollow) )
          recipeBeFollow.push(parseInt(id))
          recipeBeFollow = JSON.stringify(recipeBeFollow)
          storage.setItem("recipeBeFollow", recipeBeFollow)
  }, () ->
    $(document).on("keypress.addList", "#myModal input[type='text']", (e) ->
      if (e.keyCode == 13)
        if (e.shiftKey)
          $.noop()
        else if ($(@).val().replace(/\s/g, "").length > 0)
          e.preventDefault()
          $("#myModal").find(".add-btn").trigger("click")
        else
          $.noop()
    )
  )
)(window.jQuery)