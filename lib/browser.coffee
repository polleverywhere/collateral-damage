app             = require "app"
Queue           = require "promise-queue"
URI             = require "urijs"

VIEWPORT_WIDTH    = parseInt(process.env.WIDTH) || 1024
VIEWPORT_HEIGHT   = parseInt(process.env.HEIGHT) || 768
DEBUG_MODE        = process.env.DEBUG_MODE == "true"

results = []
queue = new Queue(1, Infinity)

app.on "ready", ->
  app.dock?.hide()

  queue.add ->
    require("../scenarios/homepage.coffee")().then (data) ->
      results.push data

  queue.add ->
    results.forEach (data) ->
      console.log data

    app.quit()