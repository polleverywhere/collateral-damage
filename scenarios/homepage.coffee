ipc = require("electron").ipcMain
Promise         = require "bluebird"
BrowserWindow   = require "browser-window"
path            = require "path"
NativeImage     = require("electron").nativeImage

VIEWPORT_WIDTH    = parseInt(process.env.WIDTH) || 1024
VIEWPORT_HEIGHT   = parseInt(process.env.HEIGHT) || 768
DEBUG_MODE        = process.env.DEBUG_MODE == "true"

createWindow = (opts = {}) ->
  new BrowserWindow
    x: 0
    y: 0
    width: VIEWPORT_WIDTH
    height: VIEWPORT_HEIGHT
    show: DEBUG_MODE
    frame: false
    webPreferences:
      preload: path.join(__dirname, "../lib/preload.js")
      webSecurity: false
      overlayScrollbars: true
      nodeIntegration: false

exampleImage = ->
  NativeImage.createFromPath path.join(__dirname, "../examples/homepage.png")

compareImage = (window, image1, image2) ->
  new Promise (resolve, reject) ->
    ipc.once "compare-results", (event, results, dataUrl) ->
      window.close()
      results.imageDataURL = dataUrl
      resolve(results)

    window.webContents.send "compare", image1.toDataUrl(), image2.toDataUrl()

capturePage = (window, url) ->
  new Promise (resolve, reject) ->
    window.webContents.loadURL url

    window.webContents.once "did-fail-load", (event, code, desc) ->
      reject()

    window.webContents.once "did-finish-load", ->
      window.webContents.once "did-finish-load", ->
        window.capturePage (data) ->
          resolve(data)

      window.webContents.executeJavaScript '$("#header-pricing-link").get(0).click()'

name = ->
  filename = path.basename __filename
  ext = path.extname filename
  filename.replace ext, ""

module.exports = ->
  new Promise (resolve, reject) ->
    window = createWindow()

    capturePage(window, "http:/www.polleverywhere.com").then (image) ->
      compareImage(window, image, exampleImage()).then (results) ->

        results.name = name()
        results.description = "homepage diff test"

        resolve(results)
