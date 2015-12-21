app             = require "app"
path            = require "path"
fs              = require "fs"
Queue           = require "promise-queue"
URI             = require "urijs"
NativeImage     = require("electron").nativeImage
mkdirp          = require "mkdirp"
JunitReporter   = require "./junit_reporter"
StaticPage      = require "./static_page"
BrowserWindow   = require "browser-window"
_               = require "lodash"

envFile = process.argv[2]
config = require envFile

_.defaults config,
  viewportWidth: 1024
  viewportHeight: 5000
  misMatchThreshold: 1
  staticPages: {}
  interactivePages: []

console.log config

results = []
queue = new Queue(1, Infinity)

outputPath = path.join(__dirname, "../tmp/diffs")
interactivePagesPath = path.join(__dirname, "../interactive_pages")

createWindow = ->
  window = new BrowserWindow
    x: 0
    y: 0
    width: config.viewportWidth
    height: config.viewportHeight
    show: config.debug
    frame: false
    useContentSize: true
    enableLargerThanScreen: true
    webPreferences:
      preload: path.join(__dirname, "../lib/preload.js")
      webSecurity: false
      overlayScrollbars: true
      nodeIntegration: false

  # increase listener limit
  window.webContents.setMaxListeners(100)

  window

setup = ->
  # ensure the output path is there
  mkdirp outputPath

printLogs = ->
  results.forEach (data) ->
    console.log data
    # console.log "#{data.name}: #{data.misMatchPercentage}% difference"

writeJunitXML = ->
  new JunitReporter(results).writeTo path.join(outputPath, "report.xml")

interactivePages = (window) ->
  # read every scenario
  for file in config.interactivePages
    do (file) ->
      pathname = path.join(interactivePagesPath, file)

      console.log "Queueing interactive page: #{pathname}"
      queue.add ->
        clazz = require(pathname)
        scenario = new clazz(window: window, config: config)

        scenario.run()
          .then (data) ->
            results.push data

staticPages = (window) ->
  for p, opts of config.staticPages
    do (p, opts) ->
      # allows us to use hashes and other url elements
      uri = URI(p).origin(config.rootUrl)

      if _.isString(opts)
        opts =
          desc: opts

      console.log "Queueing static page: #{uri.toString()}, #{opts.desc}"

      queue.add ->
        page = new StaticPage
          url: uri.toString()
          page: opts
          window: window
          config: config

        page.run()
          .then (data) ->
            results.push data

app.on "ready", ->
  app.dock?.hide()

  setup()

  window = createWindow()

  staticPages(window)
  interactivePages(window)

  queue.add printLogs
  queue.add writeJunitXML
  queue.add ->
    window.close()
    app.quit()
