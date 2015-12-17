electronpath = require "electron-prebuilt"
child_process = require "child_process"

worker = child_process.spawn electronpath, ["./lib/app.js", "--enable-logging"], stdio: "inherit"
