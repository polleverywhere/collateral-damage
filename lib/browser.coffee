app             = require "app"
path            = require "path"
fs              = require "fs"
Queue           = require "promise-queue"
URI             = require "urijs"
NativeImage     = require("electron").nativeImage
mkdirp          = require "mkdirp"

DEBUG_MODE        = process.env.DEBUG_MODE == "true"

results = []
queue = new Queue(1, Infinity)

outputPath = path.join(__dirname, "../tmp/diffs")
scenariosPath = path.join(__dirname, "../scenarios")

mkdirp outputPath

printLogs = ->
  results.forEach (data) ->
    image = NativeImage.createFromDataURL(data.imageDataURL)

    console.log "#{data.name}: #{data.misMatchPercentage}% difference"
    fs.writeFile path.join(outputPath, "#{data.name}-diff.png"), image.toPng()

quit = ->
  app.quit()

app.on "ready", ->
  app.dock?.hide()

  # read every scenario
  fs.readdirSync(scenariosPath).forEach (file) ->
    pathname = path.join(scenariosPath, file)

    console.log "Adding scenario: #{file}"

    queue.add ->
      require(pathname)().then (data) ->
        results.push data

  queue.add printLogs
  queue.add quit
