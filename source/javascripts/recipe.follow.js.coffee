(($) ->
  unless $.fn.recipe
    return
  List = Backbone.Model.extend(
    defaults: {  } # put token to this
    update: (data) ->
      #$.ajax(
      #  url: @url()
      #  dataType: "json"
      #  type: "PUT"
      #  data: data
      #)
  )
  ListCollection = Backbone.Collection.extend(
    model: List
    url: "/lists/index.json"
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
      @$el.html($.tmpl("listItemTemplate", @model.attributes))
      checked and @toggleState()
      @
  )
  listCollection = new ListCollection()
  ListModal = Backbone.View.extend(
    initialize: (params) ->
      @collection = listCollection
      @recipeInfo = params.recipeInfo
      @$el.html($.tmpl("modalTemplate", params.recipeInfo))
      @
    events:
      "click.listModal .add-btn": "clickAdd"
      "click.listModal .submit-btn": "clickSubmit"
      "click.listModal .cancel-btn": "clickCancel"
    clickAdd: (e) ->
      console.log "clickAdd"
      e.preventDefault()
      e.stopPropagation()
      #console.log @recipeInfo.id
      $input = $(e.target).parents("#add-list").find("input")
      val = $input.val()
      val = "" if (/名稱不能為空/g).test(val)
      $input.val("")
      if val.length
        # must get current_user
        data =
          list:
            name: val
          user_id: "test"
        $el = @$el.find("ul")
        @collection.create(data,
          #wait: true
          success: (item) ->
            #console.log "success"
            #console.log arguments
            view = new ListItem(
              model: item
            )
            $ul.append(view.render().el)
            @
          error: () ->
            #console.log "error"
            #console.log arguments
            @
        )
      else
        $input.addClass("error-input")
        $input.val("名稱不能為空")
      @
    clickSubmit: (e) ->
      #console.log "submit"
      e.preventDefault()
      e.stopPropagation()
      @isSubmit = true
      @$el.parent().modal("hide")
      @
    clickCancel: (e) ->
      #console.log "cancel"
      e.preventDefault()
      e.stopPropagation()
      @$el.parent().modal("hide")
      @
    onShow: () ->
      theModal = @
      #console.log "on show"
      #console.log @recipeInfo.id
      # fetch list
      @isSubmit = false
      @collection.fetch(
        data:
          user_id: "test"
        success: (collection) ->
          #console.log "success"
          #console.log arguments
          theModal.render(collection)
      )
      @
    onHide: () ->
      console.log "on hide"
      if @isSubmit
        $ul = @$el.find("ul")
        collection = @collection
        recipeId = @recipeInfo.id
        $listOn = $ul.find(".list-on")
        #url= ["/user", ICOOK?.current_user, "lists"].join("/")]
        $listOn.each(() ->
          id = $(@).attr("data-id")
          theList = collection.get(id)
          theList.update({ recipe_id: recipeId })
        )
      @
    render: (collection) ->
      #console.log "render"
      #console.log @recipeInfo.id
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
        idx is 1 && ( isFollow = true )
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
      console.log(@$el.attr("href"));
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
      #console.log @recipeInfo
      @$target.data( "theListBtn", @ )
      @$target.modal("show")
  )
  RecipeFollow = Backbone.View.extend(
    initialize: (params) ->
      @type = params.type
      @$list = @$el.siblings(".list-btn")
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
      #console.log "click-follow"
      e.preventDefault()
      e.stopPropagation()
      # must check user if exist
      @toggleState()
      @updateFavoritesCount()
      @model.follow()
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
    toggleState: () ->
      @$el.toggleClass("btn-following-recipe")
      @showDesc()
    updateFavoritesCount: () ->
      recipeInfo = @recipeInfo
      # may use template to generate html
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
      #console.log "init-follow"
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
        data = $.extend({
          id: @get("id")
        }, data)
        #console.log @url()
        #$.ajax(
        #  url: @url() + "/follow"
        #  dataType: "json"
        #  type: "PUT"
        #  data: data
        #)
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
