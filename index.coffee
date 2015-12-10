electronpath = require "electron-prebuilt"
child_process = require "child_process"

worker = child_process.spawn electronpath, ["./lib/browser.js", "--enable-logging"], stdio: "inherit"
