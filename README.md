# Collateral Damage

![](http://cdn.dstv.com/mms.dstv.com/content/images/dstv/201011/lg/bom_collateral_damage.jpg)

Perceptual Difference Testing

## Installation

    $ npm install @polleverywhere/collateral-damage --save

## Commandline Interface

    $ ./node_modules/collateral-damage

Mucking with paths is gross. Take advantage of NPM Scripts by including these in your projects `package.json` file:

    "scripts": {
      "report": "collateral-damage report",
      "reset": "collateral-damage reset"
    },

[NPM Script](https://docs.npmjs.com/misc/scripts) will do all the paths magic for you so you can just execute:

    $ npm run collateral-damage-report
    $ npm run collateral-damage-reset

### Generating the diff images and junit xml report
    
    $ npm run collateral-damage-report report <config_name>

### Resetting baseline images

    # Reset all static baseline images
    $ npm run collateral-damage-reset <config_name> static

    # Reset specific static page
    $ npm run collateral-damage-reset <config_name> static -- --page=<static_page_path e.g. /plans>
    
    # Reset all interactive baseline images
    $ npm run collateral-damage-reset <config_name> interactive

    # Reset specific interactive page    
    $ npm run collateral-damage-reset <config_name> interactive -- --page=<interactive_page_file>

## Configuration in your project

### File structure
    
    Your project root
    |
    ├── collateral_damage.config.<config_name>.coffee (config file)
    ├── interactive_pages (scripts for interactive pages)
    |   ├── ...
    |
    ├── baselines (baseline images used for visual comparison)
    |   ├── interactive (images for interactive pages)
    |   |   ├── ...
    |   |
    |   ├── static (images for static pages)
    |   |   ├── ...

### Config files

They should be named `collateral_damage.config.<config_name>.coffee`

e.g. `collateral_damage.config.production.coffee`

Options:

    debug: false
    viewportWidth: 1024
    viewportHeight: 5000
    misMatchThreshold: 1
    rootUrl: "https://www.polleverywhere.com"
    staticPages:
      "/": "Homepage"
      "/another_path": 
        desc: "Another path"
        width: 2000
        height: 3000
    interactivePages: ["file names in ./interactive_pages"]


### Static pages

These are pages that do not need any interaction. The browser will navigate to this page and take a screenshot. You need to add a cooresponding base screenshot at `/baselines/static`

### Interactive pages

These are scripts that interact with a page and then takes a screenshot. `/interactive_pages/navigate_to_plans_page.coffee` is an example of how to perform actions on a page and take a screenshot. You will need to add a cooresponding baseline image at `/baselines/interactive`

## Output

Every page will generate a screenshot image and a cooresponding diff image. These files are located in `<project-root>/tmp/collateral-damage`. The files are named like this:

    faq-diff.png
    faq.png
    guide-diff.png
    guide.png
    ...
    report.xml (JUnit format)

