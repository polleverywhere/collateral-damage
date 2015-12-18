module.exports =
  # Debug mode currently shows the window on the desktop
  debug: false

  # window content sizes
  viewportWidth: 1024
  viewportHeight: 5000

  # Percentage difference where a diff is considered a failure
  misMatchThreshold: 1

  # Allow pointing this at different environments
  rootUrl: "https://staging-rails-app.ops.pe"

  staticPages:
    "/": "Homepage"
    "/plans": "Business monthly plans"
    "/plans#annual": "Business annual plans"
    "/plans/higher-ed": "Higher-ed plans"
    "/plans/k-12": "K12 plans page"
    "/how-it-works": "How it works"
    "/features": "Features"
    "/app": "PollEv Presenter"
    "/app/google-slides": "Google Presenter"
    "/faq": "FAQ"
    "/guide": "Guide"
    "/edu-guide": "Edu guide"
    "/professional-support": "Professional support"

  customScenarios: [
    "navigate_to_plans_page.coffee"
  ]
