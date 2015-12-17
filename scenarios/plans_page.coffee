Promise         = require "bluebird"
Scenario        = require "../lib/scenario"

module.exports =
  class PlansPage extends Scenario
    capturePage: (window, url) =>
      new Promise (resolve, reject) =>
        window.webContents.loadURL url

        window.webContents.once "did-fail-load", (event, code, desc) ->
          reject()

        window.webContents.once "did-finish-load", =>
          window.webContents.once "did-finish-load", =>
            window.capturePage (data) =>
              @saveScreenshot(data.toPng())
              resolve(data)

          window.webContents.executeJavaScript '$("#header-pricing-link").get(0).click()'

    run: =>
      console.log "running #{@constructor.name} scenario"
      new Promise (resolve, reject) =>
        window = @window()

        @capturePage(window, "http://www.polleverywhere.com").then (image) =>
          @compareImage(window, image, @originalImage()).then (results) =>

            results.name = @name()

            resolve(results)
