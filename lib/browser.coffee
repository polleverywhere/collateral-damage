app             = require "app"
path            = require "path"
fs              = require "fs"
Queue           = require "promise-queue"
URI             = require "urijs"
NativeImage     = require("electron").nativeImage
mkdirp          = require "mkdirp"
JunitReporter   = require "./junit_reporter"

results = []
queue = new Queue(1, Infinity)

outputPath = path.join(__dirname, "../tmp/diffs")
scenariosPath = path.join(__dirname, "../scenarios")

# ensure the output path is there
mkdirp outputPath

printLogs = ->
  results.forEach (data) ->
    console.log data
    console.log "#{data.name}: #{data.misMatchPercentage}% difference"

writeJunitXML = ->
  new JunitReporter(results).writeTo path.join(outputPath, "report.xml")

quit = ->
  app.quit()

app.on "ready", ->
  app.dock?.hide()

  # read every scenario
  fs.readdirSync(scenariosPath).forEach (file) ->
    pathname = path.join(scenariosPath, file)

    queue.add ->
      clazz = require(pathname)
      scenario = new clazz
      scenario.run().then (data) ->
        results.push data

  queue.add printLogs
  queue.add writeJunitXML
  queue.add quit
