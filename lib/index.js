require("coffee-script/register");

var Scenario = require("./scenario");
var InteractivePage = require("./interactive_page");
var StaticPage = require("./static_page");
var JUnitReporter = require("./junit_reporter");

module.exports = {
  Scenario: Scenario,
  InteractivePage: InteractivePage,
  StaticPage: StaticPage,
  JUnitReporter: JUnitReporter
}