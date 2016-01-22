ipc             = require("electron").ipcMain
Promise         = require "bluebird"
path            = require "path"
NativeImage     = require("electron").nativeImage
fs              = require "fs"
_               = require "lodash"

COMPARISON_TIMEOUT = 30000
WAIT_FOR_LOAD_TIMEOUT = 15000

module.exports =
  class Scenario
    constructor: (options = {}) ->
      {@window, @config, @page} = options

      @baselinesPath = path.join(process.cwd(), "./baselines")
      @outputPath = path.join(process.cwd(), "./tmp/collateral-damage")

      # allow each scenario to override these
      @viewportWidth = @page?.width || @config.viewportWidth
      @viewportHeight = @page?.height || @config.viewportHeight

      @misMatchThreshold = @config.misMatchThreshold

    name: =>
      if @page.desc?
        _.snakeCase @page.desc
      else
        _.snakeCase @constructor.name

    setSize: =>
      console.log "Setting viewport size to #{@viewportWidth}x#{@viewportHeight}"
      @window.setSize @viewportWidth, @viewportHeight

    imageName: =>
      "#{@name()}.png"

    executeJavaScript: (func) =>
      functionContent = func.toString().replace(/\n/g, "")

      new Promise (resolve, reject) =>
        console.log "executing JS"
        @window.webContents.send "exec-js", functionContent

        success = (event) ->
          ipc.removeListener "exec-js-error", error
          resolve()

        error = (event, message) ->
          ipc.removeListener "exec-js-success", success
          reject(message)

        ipc.once "exec-js-success", success
        ipc.once "exec-js-error", error

    waitForSelector: (selector) =>
      new Promise (resolve, reject) =>
        unless selector?
          resolve()
          return

        console.log "waiting for css", selector
        @window.webContents.send "wait-for-selector", selector

        success = (event, targetSelector) ->
          if selector == targetSelector
            removeListeners()
            resolve()

        error = (event, targetSelector, message, timeout) =>
          if selector == targetSelector
            removeListeners()
            reject @buildError(message: message, analysisTime: timeout)

        removeListeners = ->
          ipc.removeListener "wait-for-selector-success", success
          ipc.removeListener "wait-for-selector-error", error

        ipc.on "wait-for-selector-success", success
        ipc.on "wait-for-selector-error", error

    baselineImage: =>
      filePath = path.join(@baselinesPath, @imageName())
      if fs.existsSync(filePath)
        NativeImage.createFromPath filePath
      else
        null

    buildError: (opts = {}) =>
      _.defaults opts,
        name: @name()
        failure: true
        analysisTime: 0

    compareToBaseline: (image) =>
      new Promise (resolve, reject) =>
        if @config.mode != "reset"
          if (oImage = @baselineImage())
            console.log "Preparing for comparison"
            @compareImage(image, oImage)
              .then (results) =>
                results.name = @name()
                resolve(results)
              .catch Promise.TimeoutError, (e) =>
                resolve @buildError(message: e.message, analysisTime: e.timeout)
              .catch (e) =>
                resolve @buildError(message: e.message)
          else
            console.log "Could not find baseline image"
            resolve(name: @name(), failure: true, analysisTime: 0, message: "Baseline image not found")
        else
          resolve("Reset baseline image for #{@name()}")

    compareImage: (image1, image2) =>
      new Promise (resolve, reject) =>
        console.log "Comparing image"


        error = (event, error) ->
          ipc.removeListener "compare-success", success

          console.log "Error processing comparison"
          console.log error

          results =
            failure: true
            message: error

          console.log "Processed result:", results
          resolve(results)

        success = (event, results, dataUrl) =>
          ipc.removeListener "compare-error", error

          console.log "Received image comparison"

          @saveDiffImage NativeImage.createFromDataURL(dataUrl).toPng()
          results.misMatchThreshold = @misMatchThreshold
          results.misMatchPercentage = parseFloat(results.misMatchPercentage)
          results.failure = @isFailure(results.misMatchPercentage)

          if results.failure
            results.message = "Threshold exceeds: #{results.misMatchThreshold}"

          console.log "Processed result:", results
          resolve(results)

        ipc.once "compare-success", success
        ipc.once "compare-error", error

        setTimeout ->
          ipc.removeListener "compare-error", error
          ipc.removeListener "compare-success", success

          error = new Promise.TimeoutError("Exceeded time performing comparison")
          error.timeout = COMPARISON_TIMEOUT
          reject(error)

        , COMPARISON_TIMEOUT

        @window.webContents.send "compare", image1.toDataUrl(), image2.toDataUrl()

    saveImage: (data, path) =>
      fs.writeFile path, data

    saveDiffImage: (data) =>
      @saveImage data, path.join(@outputPath, "#{@name()}-diff.png")

    saveScreenshot: (image) =>
      # save screenshot to baseline path if in reset mode
      outputPath = if @config.mode == "reset"
        @baselinesPath
      else
        @outputPath

      @saveImage image.toPng(), path.join(outputPath, "#{@name()}.png")

    isFailure: (percentage) =>
      percentage > @misMatchThreshold

    clearCookies: =>
      new Promise (resolve, reject) =>
        @window.webContents.session.clearStorageData storages: ["cookies"], resolve

    loadUrl: (url) =>
      new Promise (resolve, reject) =>
        failure = (event, code, desc) =>
          @window.webContents.removeListener "did-finish-load", success
          reject("#{event} #{code} #{desc}")

        success = =>
          @window.webContents.removeListener "did-fail-load", failure

        @window.webContents.once "did-fail-load", reject
        @window.webContents.once "did-finish-load", resolve
        @window.webContents.loadURL url

    takeScreenshot: =>
      new Promise (resolve, reject) =>
        @window.capturePage (data) =>
          @saveScreenshot(data)
          resolve(data)