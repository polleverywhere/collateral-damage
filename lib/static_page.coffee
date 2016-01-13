Promise         = require "bluebird"
Scenario        = require "./scenario"
_               = require "lodash"
URI             = require "urijs"
path            = require "path"

module.exports =
  class StaticPage extends Scenario
    constructor: (options = {}) ->
      super

      @baselinesPath = path.join(process.cwd(), "./baselines/static")

      {@url, @page} = options

    capturePage: (url) =>
      new Promise (resolve, reject) =>
        @window.webContents.loadURL url

        failure = (event, code, desc) =>
          @window.webContents.removeListener "did-finish-load", success
          reject("#{event} #{code} #{desc}")

        success = =>
          @window.webContents.removeListener "did-fail-load", failure

          capture = =>
            @window.capturePage (image) =>
              @saveScreenshot(image)
              resolve(image)

          @waitForSelector(@page.waitForSelector)
            .delay(@page.delay || 0)
            .then(capture)

        @window.webContents.once "did-fail-load", failure
        @window.webContents.once "did-finish-load", success

    name: =>
      _.snakeCase @page.desc

    run: =>
      @setSize()

      console.log "Running static page: #{@page.desc || @url}"
      new Promise (resolve, reject) =>
        @capturePage(@url).then(@compareToBaseline).then(resolve)
