DamageReport  = require "./damage_report"
parseArgs     = require "minimist"
path          = require "path"
_             = require "lodash"

args   = parseArgs process.argv.slice(2)

config  = require path.join(process.cwd(), "collateral_damage.config.#{args._[1]}")
config["mode"] = args._[0]
pageType = args._[2]
options = args

if config["mode"] == "reset"
  if pageType == "static"
    config.interactivePages = []

    # clear out the static pages except for
    # the page passed in
    if options.page?
      config.staticPages = _.pick config.staticPages, options.page

  else if pageType == "interactive"
    config.staticPages = {}

    if options.page?
      config.interactivePages = [options.page]

dr = new DamageReport
  config: config

dr.run()