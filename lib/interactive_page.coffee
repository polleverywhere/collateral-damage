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
        @capturePage(@url).then(@compareToBaseline).then(resolve)
