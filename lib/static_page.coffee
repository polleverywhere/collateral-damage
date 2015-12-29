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

      {@url} = options


    capturePage: (url) =>
      new Promise (resolve, reject) =>
        @window.webContents.loadURL url

        loadFailure = (event, code, desc) ->
          reject("#{event} #{code} #{desc}")

        @window.webContents.on "did-fail-load", loadFailure

        @window.webContents.once "did-finish-load", =>
          @window.webContents.removeListener "did-fail-load", loadFailure
          @window.capturePage (data) =>
            @saveScreenshot(data.toPng())
            resolve(data)

    name: =>
      _.snakeCase @page.desc

    run: =>
      @setSize()

      console.log "Running static page: #{@page.desc || @url}"
      new Promise (resolve, reject) =>
        @capturePage(@url).then(@compareToBaseline).then(resolve)
