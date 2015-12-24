ipc             = require("electron").ipcMain
Promise         = require "bluebird"
path            = require "path"
NativeImage     = require("electron").nativeImage
fs              = require "fs"
_               = require "lodash"

module.exports =
  class Scenario
    constructor: (options = {}) ->
      {@window, @config, @page} = options

      @baselinesPath = path.join(__dirname, "../baselines")
      @diffsPath = path.join(__dirname, "../tmp/diffs")

      # allow each scenario to override these
      @viewportWidth = @page?.width || @config.viewportWidth
      @viewportHeight = @page?.height || @config.viewportHeight

      @misMatchThreshold = @config.misMatchThreshold

    name: =>
      _.snakeCase @constructor.name

    setSize: =>
      console.log "Setting viewport size to #{@viewportWidth}x#{@viewportHeight}"
      @window.setSize @viewportWidth, @viewportHeight

    imageName: =>
      "#{@name()}.png"

    executeJavaScript: (func) =>
      # regex = /^function\s*\(\){(.*)}$/m
      # functionContent = func.toString().match(regex)?[1]
      functionContent = "eval(" + func.toString().replace(/\n/g, "") + "())"
      console.log "executing #{functionContent}"
      @window.webContents.executeJavaScript functionContent

    baselineImage: =>
      filePath = path.join(@baselinesPath, @imageName())
      if fs.existsSync(filePath)
        NativeImage.createFromPath filePath
      else
        null

    compareToBaseline: (image) =>
      new Promise (resolve, reject) =>
        if @config.mode != "reset"
          if (oImage = @baselineImage())
            console.log "Preparing for comparison"
            @compareImage(image, oImage).then (results) =>
              results.name = @name()
              resolve(results)
          else
            console.log "Could not find baseline image"
            resolve(name: @name(), failure: true, analysisTime: 0, message: "Baseline image not found")
        else
          resolve("Reset baseline image for #{@name()}")

    compareImage: (image1, image2) =>
      new Promise (resolve, reject) =>
        console.log "Comparing image"

        compareError = (event, error) ->
          console.log "Error processing comparison"
          console.log error

          results =
            failure: true
            message: error

          console.log "Processed result:", results
          resolve(results)

        ipc.once "compare-results", (event, results, dataUrl) =>
          ipc.removeListener "compare-error", compareError

          console.log "Received image comparison"

          @saveDiffImage NativeImage.createFromDataURL(dataUrl).toPng()
          results.misMatchThreshold = @misMatchThreshold
          results.misMatchPercentage = parseFloat(results.misMatchPercentage)
          results.failure = @isFailure(results.misMatchPercentage)

          if results.failure
            results.message = "Threshold exceeds: #{results.misMatchThreshold}"

          console.log "Processed result:", results
          resolve(results)

        ipc.once "compare-error", compareError

        @window.webContents.send "compare", image1.toDataUrl(), image2.toDataUrl()

    saveImage: (data, path) =>
      fs.writeFile path, data

    saveDiffImage: (data) =>
      @saveImage data, path.join(@diffsPath, "#{@name()}-diff.png")

    saveScreenshot: (data) =>
      # save screenshot to baseline path if in reset mode
      outputPath = if @config.mode == "reset"
        @baselinesPath
      else
        @diffsPath

      @saveImage data, path.join(outputPath, "#{@name()}.png")

    isFailure: (percentage) =>
      percentage > @misMatchThreshold
