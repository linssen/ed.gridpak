class EDJ
    @settings:
        debug: false
        STATIC_URL: "/static/"

    constructor: (settings) ->
        ###
        Cache some stuff, set off some methods
        -----------------------------------------------------------------------
        ###
        # Extend the settings object with any vars passed in
        $.extend(@constructor.settings, settings)

        # Cache the body for use later
        @constructor.$body = $("body")

        # Fire all functions that eval
        @constructor.go_go_go()

    @log = (args...) =>
        ###
        If we have a log, and we're in debug then use it
        -----------------------------------------------------------------------
        ###
        if @settings.debug and console?
            # Log each arg separately
            console.log message for message in args

    @go_go_go = () =>
        ###
        Determines all methods to run, and runs them
        -----------------------------------------------------------------------
        ###
        for prop of this
            _run = this[prop].run
            # If the run property is a true (evald function or boolean)
            if (typeof _run is "boolean" and _run) or (typeof _run is "function" and _run())
                # Tell the log we're off
                @log("EDJ running #{prop}")
                # Run the init method
                this[prop].init()

    @ios_rotate_fix =
        ###
        Alter viewport meta when device rotates

        Orientation and scale, Jeremy Keith: http://adactio.com/journal/4470/
        -----------------------------------------------------------------------
        ###
        run: =>
            return navigator.userAgent.match(/(ipad|iphone)/i)
    
        init: =>
            viewportmeta = document.querySelectorAll("meta[name='viewport']")[0] 
            if viewportmeta
                viewportmeta.content = "width=device-width, minimum-scale=1.0, maximum-scale=1.0"
                @$body.addEventListener("gesturestart", ->
                    viewportmeta.content = "width=device-width, minimum-scale=0.25, maximum-scale=1.6"
                , false)
