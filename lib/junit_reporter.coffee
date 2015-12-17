XMLWriter       = require "xml-writer"
fs              = require "fs"

module.exports =
  class JunitReporter
    constructor: (@results) ->

    writeTo: (path) =>
      console.log "writing junit xml to: #{path}"
      xml = @toXML()

      console.log xml
      fs.writeFile(path, xml)

    toTestCaseElement: (xmlwriter, result) ->
      xmlwriter.startElement("testcase")
        .writeAttribute("name", result.name)
        .writeAttribute("mismatch", result.misMatchPercentage)
        .writeAttribute("time", result.analysisTime)

      if result.failure
        xmlwriter.startElement("failure")
          .writeAttribute("message", result.message)
          .endElement()

      xmlwriter.endElement()

    toXML: =>
      w = new XMLWriter(true)
      w.startDocument()
      w.startElement("testsuite")
      w.writeAttribute("name", "Collateral Damage Report")
      w.writeAttribute("tests", @results.length)
      w.writeAttribute("time", @totalTime())
      w.writeAttribute("failures", @failureCount())

      for result in @results
        @toTestCaseElement(w, result)

      w.endDocument()
      w.toString()

    failureCount: =>
      count = 0

      for result in @results
        count += 1 if result.failure

      count

    totalTime: =>
      time = 0

      for result in @results
        time += result.analysisTime

      time