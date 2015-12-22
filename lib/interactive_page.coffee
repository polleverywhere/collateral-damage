Promise         = require "bluebird"
Scenario        = require "./scenario"
_               = require "lodash"
URI             = require "urijs"
path            = require "path"

module.exports =
  class InteractivePage extends Scenario
    constructor: (options = {}) ->
      super

      @baselinesPath = path.join(__dirname, "../baselines/interactive")

    run: =>
      @setSize()

      console.log "Running interactive page: #{@name()}"
      new Promise (resolve, reject) =>
        @capturePage()
          .then (image) =>
            if (oImage = @originalImage())
              console.log "Preparing for comparison"
              @compareImage(image, oImage).then (results) =>
                results.name = @name()
                resolve(results)
            else
              console.log "could not find screenshot"
              resolve(name: @name(), failure: true, analysisTime: 0, message: "Original image not found")