# Collateral Damage

![](http://cdn.dstv.com/mms.dstv.com/content/images/dstv/201011/lg/bom_collateral_damage.jpg)

Perceptual Difference Testing

## Running tests

    $ npm install
    $ npm run damage-report <config_name>

## Configuration

### Config files

Files must be named `collateral_damage.config.<config_name>.coffee`

e.g. `collateral_damage.config.pe_prod.coffee`

Options:

    debug: false
    viewportWidth: 1024
    viewportHeight: 5000
    misMatchThreshold: 1
    rootUrl: "https://www.polleverywhere.com"
    staticPages: {"/": "Homepage"}
    customScenarios: ["file names in ./custom_scenarios"]

### File structure
    
    ├── static_pages.json (static page configuration)
    ├── custom_scenarios (scripts for interactive pages)
    |   ├── ...
    |
    ├── originals (images used for diff testing)
    |   ├── custom (images for interactive pages)
    |   |   ├── ...
    |   |
    |   ├── static (images for static pages)
    |   |   ├── ...

### Static pages

These are pages that do not need any interaction. The browser will navigate to this page and take a screenshot. You need to add a cooresponding base screenshot at `/originals/static`

### Custom scenarios

These are scripts that interact with a page and then takes a screenshot. `/custom_scenarios/navigate_to_plans_page.coffee` is an example of how to perform actions on a page and take a screenshot. You will need to add a cooresponding screenshot at `/originals/custom`

## Output

Every page will generate a screenshot image and a cooresponding diff image. These files are located in `/tmp/diffs`. The files are named like this:

    faq-diff.png
    faq.png
    guide-diff.png
    guide.png
    ...
    report.xml (JUnit format)

## Running in Docker (Not yet working in Ubuntu)

### Generate diff report

1. Build the docker image:

  `docker build -t collateral_damage --file=docker/Dockerfile .`

2. Run it in a Docker container and have it output the diffs in `./tmp`

  `docker run --name damage_report -it -v $(pwd)/tmp:/app/tmp collateral_damage npm run damage-report <config_name>`

3. Clean up the container for future use:

  `docker rm damage_report`
