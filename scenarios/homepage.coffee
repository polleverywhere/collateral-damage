ipc = require("electron").ipcMain
Promise         = require "bluebird"
BrowserWindow   = require "browser-window"
path            = require "path"

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

compareImage = (window, image1, image2) ->
  new Promise (resolve, reject) ->
    ipc.once "compare-results", (event, results) ->
      resolve(results)
      window.close()

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

module.exports = ->
  new Promise (resolve, reject) ->
    window = createWindow()

    capturePage(window, "http:/www.polleverywhere.com").then (image) ->
      compareImage(window, image, image).then (data) ->
        resolve(data)
