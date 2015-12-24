electronpath = require "electron-prebuilt"
child_process = require "child_process"

args = process.argv.slice(2)
args.splice(0, 0, "./lib/app.js")

if process.platform == "linux"
  args = args.splice 0, 0, "-a", "-s", "-screen 0 #{WIDTH}x#{HEIGHT}x24", electronpath
  worker = child_process.spawn "xvfb-run", args, stdio: "inherit"
else
  worker = child_process.spawn electronpath, args, stdio: "inherit"
