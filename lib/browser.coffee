app             = require "app"
path            = require "path"
fs              = require "fs"
Queue           = require "promise-queue"
URI             = require "urijs"
NativeImage     = require("electron").nativeImage
mkdirp          = require "mkdirp"

VIEWPORT_WIDTH    = parseInt(process.env.WIDTH) || 1024
VIEWPORT_HEIGHT   = parseInt(process.env.HEIGHT) || 768
DEBUG_MODE        = process.env.DEBUG_MODE == "true"

results = []
queue = new Queue(1, Infinity)

outputPath = path.join(__dirname, "../tmp/diffs")

mkdirp outputPath

printLogs = ->
  results.forEach (data) ->
    image = NativeImage.createFromDataURL(data.imageDataURL)
    console.log "writing file", data.name

    fs.writeFile path.join(outputPath, "#{data.name}.jpg"), image.toJpeg(50)

quit = ->
  app.quit()

app.on "ready", ->
  app.dock?.hide()

  queue.add ->
    require("../scenarios/homepage.coffee")().then (data) ->
      results.push data

  queue.add printLogs
  queue.add quit
