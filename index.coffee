electronpath = require "electron-prebuilt"
child_process = require "child_process"
path = require "path"

env = process.argv[2]
envFile = "./collateral_damage.config.#{env}.coffee"
envFile = path.join(__dirname, envFile)

if process.platform == "linux"
  worker = child_process.spawn "xvfb-run", ["-a", "-s", "-screen 0 #{WIDTH}x#{HEIGHT}x24", electronpath, "./lib/app.js", envFile, "--enable-logging"], stdio: "inherit"
else
  worker = child_process.spawn electronpath, ["./lib/app.js", envFile, "--enable-logging"], stdio: "inherit"
