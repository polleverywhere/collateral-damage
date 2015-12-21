Promise         = require "bluebird"
Scenario        = require "../lib/scenario"
path            = require "path"

module.exports =
  class Homepage extends Scenario
    capturePage: =>
      new Promise (resolve, reject) =>
        @window.webContents.loadURL @url

        @window.webContents.once "did-fail-load", (event, code, desc) ->
          reject()

        @window.webContents.once "did-finish-load", =>
          @window.webContents.once "did-finish-load", =>
            @window.capturePage (data) =>
              @saveScreenshot(data.toPng())
              resolve(data)

          @executeJavaScript ->
            $("#header-pricing-link").get(0).click()
