Promise         = require "bluebird"
InteractivePage = require "../lib/interactive_page"
path            = require "path"
URI             = require "urijs"

module.exports =
  class NavigateToPlansPage extends InteractivePage
    constructor: (options = {}) ->
      options.page =
        height: 2000

      super(options)

    capturePage: =>
      url = URI(@config.rootUrl).toString()

      new Promise (resolve, reject) =>
        @window.webContents.loadURL url

        @window.webContents.once "did-fail-load", (event, code, desc) ->
          reject()

        @window.webContents.once "did-finish-load", =>
          @window.webContents.once "did-finish-load", =>
            @window.capturePage (data) =>
              @saveScreenshot(data.toPng())
              resolve(data)

          @executeJavaScript ->
            $("#header-pricing-link").get(0).click()
