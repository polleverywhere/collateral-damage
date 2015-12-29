Promise          = require "bluebird"
InteractivePage  = require "../lib/interactive_page"
path             = require "path"
URI              = require "urijs"

module.exports =
  class Homepage extends InteractivePage
    constructor: (options = {}) ->
      options.page =
        height: 2600

      super(options)

    capturePage: =>
      url = URI(@config.rootUrl).toString()

      new Promise (resolve, reject) =>
        @window.webContents.loadURL url

        @window.webContents.once "dom-ready", =>
          @executeJavaScript ->
            # Remove viz
            # Remove animating background
            # Remove carousel
            $(".device--laptop iframe, .hero-media video, .carousel-slider").remove()

          .then =>
            setTimeout =>
              @window.capturePage (data) =>
                @saveScreenshot(data.toPng())
                resolve(data)
            , 1000