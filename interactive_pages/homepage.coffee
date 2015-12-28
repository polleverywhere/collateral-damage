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

        @window.webContents.once "did-fail-load", (event, code, desc) ->
          reject()

        @window.webContents.once "did-finish-load", =>
          @executeJavaScript ->
            # Remove animating background
            $(".hero-media video").remove()

            # Remove viz
            $(".device--laptop iframe").remove()

            # Remove carousel
            $(".carousel-slider").remove()

          setTimeout =>
            @window.capturePage (data) =>
              @saveScreenshot(data.toPng())
              resolve(data)
          , 1000