# Collateral Damage

![](http://cdn.dstv.com/mms.dstv.com/content/images/dstv/201011/lg/bom_collateral_damage.jpg)

Perceptual Difference Testing

## Running tests

    $ npm install
    $ npm run damage-report <config_name>

## Resetting baseline images

    npm run reset-static <config_name> <static_page_path>
    npm run reset-static <config_name> --all

    npm run reset-interactive <config_name> <interactive_page_file.coffee>
    npm run reset-interactive <config_name> --all

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
    staticPages:
      "/": "Homepage"
      "/another_path": 
        desc: "Another path"
        width: 2000
        height: 3000
    interactivePages: ["file names in ./interactive_pages"]

### File structure
    
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

### Static pages

These are pages that do not need any interaction. The browser will navigate to this page and take a screenshot. You need to add a cooresponding base screenshot at `/baselines/static`

### Interactive pages

These are scripts that interact with a page and then takes a screenshot. `/interactive_pages/navigate_to_plans_page.coffee` is an example of how to perform actions on a page and take a screenshot. You will need to add a cooresponding baseline image at `/baselines/interactive`

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
