# Collateral Damage

                             ____
                     __,-~~/~    `---.
                   _/_,---(      ,    )
               __ /        <    /   )  \___
- ------===;;;'====------------------===;;;===----- -  -
                  \/  ~"~"~"~"~"~\~"~)~"/
                  (_ (   \  (     >    \)
                   \_( _ <         >_>'
                      ~ `-i' ::>|--"
                          I;|.|.|
                         <|i::|i|`.
                        (` ^'"`-' ")
                        
Perceptual Difference Testing

## Running tests

    $ npm install
    $ foreman start

## Configuration

### File structure
    
    |-- static_pages.json (static page configuration)
    |-- custom_scenarios (scripts for interactive pages)
        |-- ...
    |
    |-- originals (images used for diff testing)
        |-- custom (images for interactive pages)
            |-- ...
        |
        |-- static (images for static pages)
            |-- ...

### Static pages

`static_pages.json` includes the pages that will diffed. You need to add a cooresponding screenshot at `/originals/static`

### Interactive pages

`/custom_scenarios/sample_page.coffee` is an example of how to perform actions on a page and take a screenshot. You will need to add a cooresponding screenshot at `/originals/custom`

## Output

Every page will generate a screenshot image and a cooresponding diff image. These files are located in `/tmp/diffs`. The files are named like this:

    faq-diff.png
    faq.png
    guide-diff.png
    guide.png
    ...
    report.xml (JUnit format)