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

      {@url, @page, @config} = options

    capturePage: (url) =>
      @window.setSize @viewportWidth, @viewportHeight
      new Promise (resolve, reject) =>
        @loadUrl(url)
          .then =>
            @waitForSelector(@page.waitForSelector)
          .delay(@page.delay || @config.delay)
          .then =>
            @getCurrentSize().then (size) =>
              @setSize(size.width, size.height)
          .delay(1000)
          .then(@takeScreenshot)
          .then(resolve)
          .catch ->
            console.log arguments
            reject arguments

    run: =>
      console.log "Running static page: #{@page.desc || @url}"
      new Promise (resolve, reject) =>
        @clearCookies()
          .then =>
            @capturePage(@url)
          .then(@compareToBaseline)
          .then(resolve)
          .catch(reject)
