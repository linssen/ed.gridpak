jQuery ->
    
    class Grid extends Backbone.Model
        defaults:
            minWidth: 0
            maxWidth: false
            colNum: 6
            paddingWidth: 1.5
            paddingType: '%'
            gutterWidth: 2
            gutterType: '%'
            baselineHeight: 22

        initialize: ->
            @bind "destroy", @resetCurrent
            @bind "change:minWidth", @setLimits
            @bind "change:colNum change:paddingWidth change:paddingType
                change:gutterWidth change:gutterType", @setColWidth

        validate: (attrs) =>
            settings =
                maxCols: 99
                allowedTypes: ["px", "%"]
                minGridWidth: 100
                minMinWidth: 220

            # Check integers
            if (attrs.minWidth? and not @isInt attrs.minWidth) or
                (attrs.maxWidth? and not @isInt attrs.maxWidth) or
                (attrs.colNum? and not @isInt attrs.colNum) or
                (attrs.paddingWidth? and not @isNum attrs.paddingWidth) or
                (attrs.gutterWidth? and not @isNum attrs.gutterWidth)
                    return "Numbers please"

            # Make sure we don't exceed the col num limit
            if attrs.colNum > settings.maxCols or attrs.colNum < 1
                return "There must be between 1 and #{settings.maxCols} columns"

            # Some must be positive
            if (attrs.paddingWidth? and attrs.paddingWidth < 0) or
                (attrs.gutterWidth? and attrs.gutterWidth < 0)
                    return "Must be a positive number" 

        setLimits: =>
            ###
            Calculates the grids maxWidth from the next grids minWidth. Relies
            on the collection being intact.
            ###
            nextGrid = @collection.at @collection.indexOf(this) + 1
            maxWidth = if nextGrid? then (nextGrid.get "minWidth") - 1 else false
            @set "maxWidth", maxWidth

        setColWidth: =>
            ###
            Calculates the column widths based on the grid's options.
            ###
            gutterType = @get 'gutterType'
            gutterWidth = @get 'gutterWidth'
            colNum = @get 'colNum'

            gutterRemove = if gutterType == "%" then gutterWidth * (colNum - 1) else 0
            @set 'colWidth', (100 - gutterRemove) / colNum

        resetCurrent: =>
            ###
            If we delete the 'current' model, then we'll need to replace it
            with it's nearest neighbour (preference on next, not prev).
            ###
            if not @get "current"
                return false

            index = @collection.indexOf this
            maxIndex = @collection.length - 1
            newIndex = if index < maxIndex then index + 1 else index - 1
            grid = @collection.at newIndex
            grid.set "current", true

        isInt: (num) ->
            ###
            Determines whether the var is a number.
            ###
            return typeof num == "number" and num % 1 == 0

        isNum: (num) ->
            ###
            Determines whether the var is a float.
            ###
            return (not isNaN parseFloat num) and isFinite num

    class GridList extends Backbone.Collection
        model: Grid

        comparator: (grid) =>
            ###
            Used to order the grids ascending by their minWidth.
            ###
            return grid.get "minWidth"

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

        dump: =>
            ###
            Converts the GridList collection to a readable string and dumps it
            in the console log, useful for debugging.
            ###
            message = ""
            @each (grid) =>
                message += "#{grid.cid}: #{grid.get "minWidth"} - #{grid.get "maxWidth"}\t"
                message += "padding: #{grid.get "paddingWidth"}#{grid.get "paddingType"} | "
                message += "gutter: #{grid.get "gutterWidth"}#{grid.get "gutterType"} | "
                message += "baseline: #{grid.get "baselineHeight"}\n"
            console.log message

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
            "change #options select": 'typeSwitch'

        resize: (e, ui) ->
            # resizer stuff
        
        updateGrid: () =>
            ###
            Fetches the options from the form and sets them to the current grid.
            ###
            grid = @collection.getCurrent()

            gridOptions =
                colNum: parseInt $("#id_col_num").val()
                gutterWidth: parseFloat $("#id_gutter_width").val()
                gutterType: $("#id_gutter_type").val()
                paddingWidth: parseFloat $("#id_padding_width").val()
                paddingType: $("#id_padding_type").val()

            grid.set gridOptions

        refreshOptions: (e) =>
            ###
            Fetches the options from the current grid and sets them to the form.
            ###
            grid = @collection.getCurrent()

            # Because we unset current before we set the new one it will
            # momentarily be undefined.
            if not grid?
                return false

            $("#id_col_num").val grid.get('colNum')
            $("#id_gutter_width").val grid.get('gutterWidth')
            $("#id_gutter_type").val grid.get('gutterType')
            $("#id_padding_width").val grid.get('paddingWidth')
            $("#id_padding_type").val grid.get('paddingType')
        
        appendGrid: (grid) =>
            grid.setLimits()
            grid.setColWidth()

            gridView = new GridView model: grid
            gridTabView = new GridTabView model: grid
            $('#grid_list').append gridView.render()
            $('#tabs').append gridTabView.render()

        typeSwitch: (e) =>
            ###
            Deals with the change between px and % for gutter and padding types .
            ###
            grid = @collection.getCurrent()

            $select = $(e.target)
            $input = $select.prev("input")
            oldWidth = $input.val()

            # If we've switched from % to px
            if $select.val() == "px"
                newWidth = parseInt(@browser.width() * (oldWidth / 100))
                step = 1
            else
                newWidth = (oldWidth / @browser.width()) * 100
                step = 0.1

            # HTML data attributes are camel cased to jQuery attrs, and we'll
            # use them to set the correct grid attribute
            grid.set $input.data("gridAttr"), newWidth

            # Set the number input increments to something more useful
            # (percentages are float, and px are integers)
            $input.attr "step", step

            @refreshOptions

    gridpak = new AppView
