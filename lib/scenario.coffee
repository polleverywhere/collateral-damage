ipc             = require("electron").ipcMain
Promise         = require "bluebird"
BrowserWindow   = require "browser-window"
path            = require "path"
NativeImage     = require("electron").nativeImage
fs              = require "fs"
_               = require "lodash"

module.exports =
  class Scenario
    constructor: ->
      @originalsPath = path.join(__dirname, "../originals")
      @diffsPath = path.join(__dirname, "../tmp/diffs")

      # allow each scenario to override these
      @viewportWidth    = parseInt(process.env.WIDTH) || 1024
      @viewportHeight   = parseInt(process.env.HEIGHT) || 1200
      @misMatchThreshold = parseFloat(process.env.MISMATCH_THRESHOLD)

      @debugMode = process.env.DEBUG_MODE == "true"

    name: =>
      _.snakeCase @constructor.name

    window: (opts = {}) =>
      new BrowserWindow
        x: 0
        y: 0
        width: @viewportWidth
        height: @viewportHeight
        show: @debugMode
        frame: false
        webPreferences:
          preload: path.join(__dirname, "../lib/preload.js")
          webSecurity: false
          overlayScrollbars: true
          nodeIntegration: false

    imageName: =>
      "#{@name()}.png"

    originalImage: =>
      NativeImage.createFromPath path.join(@originalsPath, @imageName())

    compareImage: (window, image1, image2) =>
      new Promise (resolve, reject) =>
        ipc.once "compare-results", (event, results, dataUrl) =>
          window.close()

          @saveDiffImage NativeImage.createFromDataURL(dataUrl).toPng()
          results.misMatchThreshold = @misMatchThreshold
          results.misMatchPercentage = parseFloat(results.misMatchPercentage)
          results.failure = @isFailure(results.misMatchPercentage)

          resolve(results)

        window.webContents.send "compare", image1.toDataUrl(), image2.toDataUrl()

    saveImage: (data, path) =>
      fs.writeFile path, data

    saveDiffImage: (data) =>
      @saveImage data, path.join(@diffsPath, "#{@name()}-diff.png")

    saveScreenshot: (data) =>
      @saveImage data, path.join(@diffsPath, "#{@name()}.png")

    isFailure: (percentage) =>
      percentage > @misMatchThreshold
