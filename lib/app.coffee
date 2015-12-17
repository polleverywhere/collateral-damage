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

ROOT_URL = process.env.ROOT_URL

results = []
queue = new Queue(1, Infinity)

outputPath = path.join(__dirname, "../tmp/diffs")
customScenariosPath = path.join(__dirname, "../custom_scenarios")

VIEWPORT_WIDTH    = parseInt(process.env.VIEWPORT_WIDTH)
VIEWPORT_HEIGHT   = parseInt(process.env.VIEWPORT_HEIGHT)
DEBUG_MODE        = process.env.DEBUG_MODE == "true"

STATIC_PATHS = require "../static_pages.json"

createWindow = ->
  new BrowserWindow
    x: 0
    y: 0
    width: VIEWPORT_WIDTH
    height: VIEWPORT_HEIGHT
    show: DEBUG_MODE
    frame: false
    enableLargerThanScreen: true
    webPreferences:
      preload: path.join(__dirname, "../lib/preload.js")
      webSecurity: false
      overlayScrollbars: true
      nodeIntegration: false

setup = ->
  # ensure the output path is there
  mkdirp outputPath

printLogs = ->
  results.forEach (data) ->
    console.log data
    # console.log "#{data.name}: #{data.misMatchPercentage}% difference"

writeJunitXML = ->
  new JunitReporter(results).writeTo path.join(outputPath, "report.xml")

customScenarios = (window) ->
  # read every scenario
  fs.readdirSync(customScenariosPath).forEach (file) ->
    pathname = path.join(customScenariosPath, file)

    console.log "Queueing custom scenario: #{pathname}"
    queue.add ->
      clazz = require(pathname)
      scenario = new clazz(window: window)
      scenario.run().then (data) ->
        results.push data


staticPages = (window) ->
  for p, desc of STATIC_PATHS
    do (p, desc) ->
      # allows us to use hashes and other url elements
      uri = URI(p).origin(ROOT_URL)
      console.log "Queueing static page: #{uri.toString()}, #{desc}"

      queue.add ->
        new StaticPage(url: uri.toString(), desc: desc, window: window)
          .run()
            .then (data) ->
              results.push data

app.on "ready", ->
  app.dock?.hide()

  setup()

  window = createWindow()

  staticPages(window)
  customScenarios(window)

  queue.add printLogs
  queue.add writeJunitXML
  queue.add ->
    window.close()
    app.quit()
