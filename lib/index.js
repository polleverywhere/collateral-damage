require("coffee-script/register");

var DamageReport = require("./lib/damage_report");
var Scenario = require("./lib/scenario");
var InteractivePage = require("./lib/interactive_page");
var StaticPage = require("./lib/static_page");
var JUnitReporter = require("./lib/junit_reporter");

module.exports = {
  DamageReport: DamageReport,
  Scenario: Scenario,
  InteractivePage: InteractivePage,
  StaticPage: StaticPage,
  JUnitReporter: JUnitReporter
}