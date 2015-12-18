ipc             = require("electron").ipcMain
Promise         = require "bluebird"
path            = require "path"
NativeImage     = require("electron").nativeImage
fs              = require "fs"
_               = require "lodash"

module.exports =
  class Scenario
    constructor: (options = {}) ->
      {@window, @config} = options

      @originalsPath = path.join(__dirname, "../originals")
      @diffsPath = path.join(__dirname, "../tmp/diffs")

      # allow each scenario to override these
      @viewportWidth = @config.viewportWidth
      @viewportHeight = @config.viewportHeight

      @misMatchThreshold = @config.misMatchThreshold

    name: =>
      _.snakeCase @constructor.name

    setSize: =>
      @window.setSize @viewportWidth, @viewportHeight

    imageName: =>
      "#{@name()}.png"

    executeJavaScript: (func) =>
      # regex = /^function\s*\(\){(.*)}$/m
      # functionContent = func.toString().match(regex)?[1]
      functionContent = "eval(" + func.toString().replace(/\n/g, "") + "())"
      console.log "executing #{functionContent}"
      @window.webContents.executeJavaScript functionContent

    originalImage: =>
      filePath = path.join(@originalsPath, @imageName())
      if fs.existsSync(filePath)
        NativeImage.createFromPath filePath
      else
        null

    compareImage: (image1, image2) =>
      new Promise (resolve, reject) =>
        console.log "Comparing image"

        ipc.once "compare-results", (event, results, dataUrl) =>
          console.log "Received image comparison"

          @saveDiffImage NativeImage.createFromDataURL(dataUrl).toPng()
          results.misMatchThreshold = @misMatchThreshold
          results.misMatchPercentage = parseFloat(results.misMatchPercentage)
          results.failure = @isFailure(results.misMatchPercentage)

          if results.failure
            results.message = "Threshold exceeds: #{results.misMatchThreshold}"

          console.log "Processed result:", results
          resolve(results)

        ipc.once "compare-error", (event, error) =>
          console.log "Error processing comparison"
          console.log error

          results =
            failure: true
            message: error

          console.log "Processed result:", results
          resolve(results)

        @window.webContents.send "compare", image1.toDataUrl(), image2.toDataUrl()

    saveImage: (data, path) =>
      fs.writeFile path, data

    saveDiffImage: (data) =>
      @saveImage data, path.join(@diffsPath, "#{@name()}-diff.png")

    saveScreenshot: (data) =>
      @saveImage data, path.join(@diffsPath, "#{@name()}.png")

    isFailure: (percentage) =>
      percentage > @misMatchThreshold
