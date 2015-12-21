Promise         = require "bluebird"
Scenario        = require "./scenario"
_               = require "lodash"
URI             = require "urijs"
path            = require "path"

module.exports =
  class StaticPage extends Scenario
    constructor: (options = {}) ->
      super

      @originalsPath = path.join(__dirname, "../originals/static")

      {@url} = options


    capturePage: (url) =>
      new Promise (resolve, reject) =>
        @window.webContents.loadURL url

        loadFailure = (event, code, desc) ->
          reject("#{event} #{code} #{desc}")

        @window.webContents.on "did-fail-load", loadFailure

        @window.webContents.once "did-finish-load", =>
          console.log @window.getContentSize()
          @window.webContents.removeListener "did-fail-load", loadFailure
          @window.capturePage (data) =>
            @saveScreenshot(data.toPng())
            console.log "captured screenshot!"
            resolve(data)

    name: =>
      _.snakeCase @page.desc

    run: =>
      @setSize()

      console.log "Running static page: #{@page.desc || @url}"
      new Promise (resolve, reject) =>
        @capturePage(@url)
          .then (image) =>
            if (oImage = @originalImage())
              console.log "Preparing for comparison"
              @compareImage(image, oImage).then (results) =>
                results.name = @name()
                resolve(results)
            else
              console.log "could not find screenshot"
              resolve(name: @name(), failure: true, analysisTime: 0, message: "Original image not found")