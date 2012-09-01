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
        template: _.template($('#grid_template').html())

        initialize: ->
            @model.bind 'change', @render
            @model.bind 'destroy', @unrender
            @model.bind 'error', @errorHandler

        render: =>
            $(@el).html(@template(@model.toJSON()))

        unrender: =>
            $(@el).remove()
        
    class GridTabView extends Backbone.View
        tagName: 'li'
        template: _.template($('#grid_tab_template').html())

        initialize: ->
            @model.bind 'change', @render
            @model.bind 'remove', @unrender

        render: =>
            $(@el).html(@template(@model.toJSON()))

        unrender: =>
            $(@el).remove()

        remove: ->
            @model.destroy()

        events:
            'click .delete': 'remove'

    class AppView extends Backbone.View
        el: $ '#gridpak'
        $browser: {}
        snap: 20

        initialize: ->
            @collection = new GridList(theGrids)
            @collection.bind 'add', @appendGrid
            @collection.each(@appendGrid)

            @browser = $('#browser').resizable({
                handles: 'e'
                grid: @snap
                minWidth: 200
                resize: (e, ui) =>
                    @resize(e, ui)
            })

        resize: (e, ui) ->
            # resizer stuff
        
        appendGrid: (grid) =>
            gridView = new GridView model: grid
            gridTabView = new GridTabView model: grid
            $('#grid_list').append gridView.render()
            $('#tabs').append gridTabView.render()

    gridpak = new AppView
