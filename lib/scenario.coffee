ipc             = require("electron").ipcMain
Promise         = require "bluebird"
path            = require "path"
NativeImage     = require("electron").nativeImage
fs              = require "fs"
_               = require "lodash"

module.exports =
  class Scenario
    constructor: (options = {}) ->
      @window = options.window

      @originalsPath = path.join(__dirname, "../originals")
      @diffsPath = path.join(__dirname, "../tmp/diffs")

      # allow each scenario to override these
      @viewportWidth    = parseInt(process.env.VIEWPORT_WIDTH)
      @viewportHeight   = parseInt(process.env.VIEWPORT_HEIGHT)

      @misMatchThreshold = parseFloat(process.env.MISMATCH_THRESHOLD)

      @debugMode = process.env.DEBUG_MODE == "true"

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
        ipc.once "compare-results", (event, results, dataUrl) =>
          @saveDiffImage NativeImage.createFromDataURL(dataUrl).toPng()
          results.misMatchThreshold = @misMatchThreshold
          results.misMatchPercentage = parseFloat(results.misMatchPercentage)
          results.failure = @isFailure(results.misMatchPercentage)

          if results.failure
            results.message = "Threshold exceeds: #{results.misMatchThreshold}"

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
