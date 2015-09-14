module.exports = (grunt) ->

    grunt.initConfig

        pkg: grunt.file.readJSON "package.json"

        paths:
            styles: "./static/styles/"
            scripts: "./static/scripts/"

        concat:
            scripts:
                files:
                    "<%= paths.scripts %>dist/<%= pkg.name %>.js": [
                        "<%= paths.scripts %>lib/jquery/jquery.js"
                        "<%= paths.scripts %>lib/jquery-ui/jquery-ui.js"
                        "<%= paths.scripts %>lib/underscore/underscore.js"
                        "<%= paths.scripts %>lib/**/*.js"
                        "<%= paths.scripts %>build/*.js"
                    ]
            styles:
                files:
                    "<%= paths.styles %>dist/<%= pkg.name %>.css": "<%= paths.styles %>build/*.css"
        uglify:
            options:
                preserveComments: false
                mangle: true
            scripts:
                files:
                    "<%= paths.scripts %>dist/<%= pkg.name %>.js": [
                        "<%= paths.scripts %>lib/jquery/jquery.js"
                        "<%= paths.scripts %>lib/jquery-ui/jquery-ui.js"
                        "<%= paths.scripts %>lib/underscore/underscore.js"
                        "<%= paths.scripts %>lib/underscore/underscore.js"
                        "<%= paths.scripts %>lib/**/*.js"
                        "<%= paths.scripts %>build/*.js"
                    ]

        sass:
            build:
                files: [
                    expand: true
                    cwd: "<%= paths.styles %>"
                    src: ["*.scss", "!_*.scss"]
                    dest: "<%= paths.styles %>build/"
                    ext: ".css"
                ]

        cssmin:
            styles:
                files:
                    "<%= paths.styles %>dist/<%= pkg.name %>.css": "<%= paths.styles %>build/*.css"

        coffee:
            scripts:
                files: [
                    expand: true
                    cwd: "<%= paths.scripts %>"
                    src: ["*.coffee"]
                    dest: "<%= paths.scripts %>build/"
                    ext: ".js"
                ]

        qunit:
            dist: ["<%= paths.scripts %>test/*.html"]

        watch:
            coffee:
                files: ["<%= paths.scripts %>*.coffee"]
                tasks: ["coffee", "concat:scripts"]
            styles:
                files: ["<%= paths.styles %>*.scss"]
                tasks: ["sass", "concat:styles"]

        grunt.loadNpmTasks "grunt-contrib-qunit"
        grunt.loadNpmTasks "grunt-contrib-uglify"
        grunt.loadNpmTasks "grunt-contrib-coffee"
        grunt.loadNpmTasks "grunt-sass"
        grunt.loadNpmTasks "grunt-contrib-cssmin"
        grunt.loadNpmTasks "grunt-contrib-watch"
        grunt.loadNpmTasks "grunt-contrib-concat"

        grunt.registerTask "default", ["coffee", "uglify", "sass", "cssmin"]
        grunt.registerTask "test", ["qunit"]
