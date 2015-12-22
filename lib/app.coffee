DamageReport  = require "./damage_report"
envFile       = process.argv[2]
config        = require envFile

dr = new DamageReport
  config: config

dr.run()