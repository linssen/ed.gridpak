jQuery ->
    
    class Grid extends Backbone.Model
        defaults:
            minWidth: 0
            colNum: 6
            paddingWidth: 1.5
            paddingType: '%'
            gutterWidth: 2
            gutterType: '%'
            baseline_height: 22

        initialize: ->
            @bind "change:minWidth", @setLimits
            @bind "change:colNum change:paddingWidth change:paddingType
                change:gutterWidth change:gutterType", @setColWidth

        setLimits: =>
            console.log "will set limits for #{@cid}"

        setColWidth: =>
            gutterType = @get 'gutterType'
            gutterWidth = @get 'gutterWidth'
            colNum = @get 'colNum'

            gutterRemove = if gutterType == "%" then gutterWidth * (colNum - 1) else 0
            @set 'colWidth', (100 - gutterRemove) / colNum

    class GridList extends Backbone.Collection
        model: Grid

        getCurrent: =>
            ###
            Returns the grid in the collection that is currently being edited.
            Uses Underscore.js's _.find method.
            ###
            return @find (grid) ->
                grid.get('current') == true

        stringify: =>
            ###
            Converts the GridList collection into a JSON string and stores the
            contents in the #stringified input in the download form.
            ###
            $('#stringified').val JSON.stringify this

    class GridView extends Backbone.View
        tagName: 'li'
        template: _.template $('#grid_template').html()

        initialize: ->
            @model.bind 'change', @render
            @model.bind 'destroy', @unrender
            @model.bind 'error', @errorHandler

        render: =>
            $(@el).html @template @model.toJSON()

        unrender: =>
            $(@el).remove()
        
    class GridTabView extends Backbone.View
        tagName: 'li'
        template: _.template $('#grid_tab_template').html()

        initialize: ->
            @model.bind 'change', @render
            @model.bind 'remove', @unrender

        render: =>
            $(@el).html @template @model.toJSON()

        unrender: =>
            $(@el).remove()

        remove: (e) ->
            e.preventDefault()
            @model.destroy()

        open: (e) ->
            e.preventDefault()
            current = @model.collection.getCurrent()
            current.set 'current', false
            @model.set 'current', true

        events:
            'click .delete': 'remove'
            'click .open': 'open'

    class AppView extends Backbone.View
        el: $ '#gridpak'
        $browser: {}
        snap: 20

        initialize: ->
            @collection = new GridList(theGrids)
            @collection.bind 'add', @appendGrid
            @collection.bind 'change', @refreshOptions
            @collection.each(@appendGrid)

            @browser = $('#browser').resizable
                handles: 'e'
                grid: @snap
                minWidth: 200
                resize: (e, ui) =>
                    @resize(e, ui)

            @refreshOptions()
            
        events:
            "change #options input, #options select": 'updateGrid'

        resize: (e, ui) ->
            # resizer stuff
        
        updateGrid: () =>
            ###
            Fetches the options from the form and sets them to the current grid
            ###
            grid = @collection.getCurrent()

            gridOptions =
                colNum: parseInt $("#id_col_num").val()
                gutterWidth: parseInt $("#id_gutter_width").val()
                gutterType: $("#id_gutter_type").val()
                paddingWidth: parseInt $("#id_padding_width").val()
                paddingType: $("#id_padding_type").val()

            grid.set gridOptions

        refreshOptions: (e) =>
            ###
            Fetches the options from the current grid and sets them to the form
            ###
            grid = @collection.getCurrent()

            # Because we unset current before we set the new one it will
            # momentarily be undefined
            if not grid?
                return false

            $("#id_col_num").val grid.get('colNum')
            $("#id_gutter_width").val grid.get('gutterWidth')
            $("#id_gutter_type").val grid.get('gutterType')
            $("#id_padding_width").val grid.get('paddingWidth')
            $("#id_padding_type").val grid.get('paddingType')
        
        appendGrid: (grid) =>
            gridView = new GridView model: grid
            gridTabView = new GridTabView model: grid
            $('#grid_list').append gridView.render()
            $('#tabs').append gridTabView.render()

    gridpak = new AppView
