Promise         = require "bluebird"
Scenario        = require "./scenario"
_               = require "lodash"
URI             = require "urijs"
path            = require "path"

module.exports =
  class StaticPage extends Scenario
    constructor: (options = {}) ->
      super

      @baselinesPath = path.join(process.cwd(), "./baselines/static")

      {@url, @page} = options

    capturePage: (url) =>
      new Promise (resolve, reject) =>
        @loadUrl(url)
          .then =>
            @waitForSelector(@page.waitForSelector)
          .delay(@page.delay || 0)
          .then(@takeScreenshot)
          .then(resolve)

    run: =>
      @setSize()

      console.log "Running static page: #{@page.desc || @url}"
      new Promise (resolve, reject) =>
        @clearCookies()
          .then =>
            @capturePage(@url)
          .then(@compareToBaseline)
          .then(resolve)
          .catch(reject)