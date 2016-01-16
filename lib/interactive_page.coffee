Promise         = require "bluebird"
Scenario        = require "./scenario"
_               = require "lodash"
URI             = require "urijs"
path            = require "path"

module.exports =
  class InteractivePage extends Scenario
    constructor: (options = {}) ->
      super

      @baselinesPath = path.join(process.cwd(), "./baselines/interactive")

    capturePage: (url) =>
      Promise.reject "You need to implement the capturePage method to handle #{url}"

    run: =>
      @setSize()

      console.log "Running interactive page: #{@name()}"
      new Promise (resolve, reject) =>
        @clearCookies()
          .then =>
            @capturePage(@url)
          .then(@compareToBaseline)
          .then(resolve)
          .catch(reject)
