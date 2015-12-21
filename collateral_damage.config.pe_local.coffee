module.exports =
  # Debug mode currently shows the window on the desktop
  debug: false

  # window content sizes
  viewportWidth: 1024
  viewportHeight: 5000

  # Percentage difference where a diff is considered a failure
  misMatchThreshold: 1

  # Allow pointing this at different environments
  rootUrl: "http://localhost:5000"

  staticPages:
    "/plans":
      desc: "Business monthly plans"
      height: 2000

    "/plans#annual":
      desc: "Business annual plans"
      height: 2000

    "/plans/higher-ed":
      desc: "Higher-ed plans"
      height: 3000

    "/plans/k-12":
      desc: "K12 plans page"
      height: 2500

    "/how-it-works": "How it works"
    "/features":
      desc: "Features"
      height: 10000

    "/app":
      desc: "PollEv Presenter"
      height: 4000

    "/app/google-slides":
      desc: "Google Presenter"
      height: 3000

    # "/faq": "FAQ"

    "/guide": "User guide"
    "/edu-guide":
      desc: "Edu guide"
      height: 5000

    "/professional-support":
      desc: "Professional support"
      height: 1000

  interactivePages: [
    "navigate_to_plans_page.coffee"
  ]