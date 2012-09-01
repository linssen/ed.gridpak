jQuery ->
    
    class Grid extends Backbone.Model
        defaults:
            min_width: 0
            col_num: 6
            padding_width: 1.5
            padding_type: '%'
            gutter_width: 2
            gutter_type: '%'
            baseline_height: 22

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
            

        resize: (e, ui) ->
            # resizer stuff
        
        refreshOptions: (e) =>
            grid = @collection.getCurrent()

            # Because we unset current before we set the new one it will
            # momentarily be undefined
            if not grid?
                return false

            $("#id_col_num").val grid.get('col_num')
            $("#id_gutter_width").val grid.get('gutter_width')
            $("#id_gutter_type").val grid.get('gutter_type')
            $("#id_padding_width").val grid.get('padding_width')
            $("#id_padding_type").val grid.get('padding_type')
        
        appendGrid: (grid) =>
            gridView = new GridView model: grid
            gridTabView = new GridTabView model: grid
            $('#grid_list').append gridView.render()
            $('#tabs').append gridTabView.render()

    gridpak = new AppView
