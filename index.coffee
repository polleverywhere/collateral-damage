# Nightmare = require "nightmare"

# options =
#   show: true
#   width: 1024
#   height: 768
#   frame: false

# n = new Nightmare(options)
# n.goto "http://www.polleverywhere.com"
#   # .screenshot "/tmp/test.png"

path = require "path"
electronpath = require "electron-prebuilt"
child_process = require "child_process"

worker = child_process.spawn electronpath, ["./lib/browser.js", @port, "--enable-logging"], stdio: "inherit"
