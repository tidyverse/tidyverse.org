[![Netlify Status](https://api.netlify.com/api/v1/badges/90b72bec-4010-40b3-bce3-2d84c3fd417f/deploy-status)](https://app.netlify.com/sites/tidyverse-org/deploys)

# tidyverse.org

This repo is the source of <https://tidyverse.org>, and this readme tells you 
how it all works. 

* If you spot any small problems with the website, please feel empowered to fix 
  them directly with a PR. 
  
* If you see any larger problems, an issue is probably better: that way we can 
  discuss the problem before you commit any time to it.

This repo (and resulting website) is licensed as [CC BY-SA](LICENSE.md).

## Workflow

This site now uses [hugodown](http://github.com/r-lib/hugodown/issues) rather than blogdown. Install it with:

```r
remotes::install_github("r-lib/hugodown")
```

* To add a new post call `hugodown::tidy_post_create("short-name")`. 
  This creates `content/blog/short-name/`containing an `index.Rmd` file that 
  tells you what to do next.
  
* To add a new event call `hugodown::post_create("events/year-event-name")`.

* Knit to `.Rmd` to generate a `.md`.

* To preview the site (i.e. turn `.md` into `.html`), call 
  `hugodown::server_start()` (you only need to do this once per session as it
  will continue to run in the background).

* Every blog post has to be accompanied by a photo (precise details are 
  provided in the `.Rmd` template). If you don't already have a image in 
  mind, try <https://unsplash.com>, <https://pexels.com>, or Jenny Bryan's 
  [free photo](https://github.com/jennybc/free-photos) link collection. 
  
The tidyverse site is automatically published with [netlify](http://netlify.com/), so every PR will automatically get a live preview. Once the PR is merged, that preview becomes the live site.

### Changes from blogdown

The main difference is that hugodown cleanly separates the process of building the site into two steps: hugodown generates `.md` from `.Rmd`,  then hugo generates `.html` from `.md`. This leads to the following changes:

* We once again use `.Rmd`, which generates `.md`, not `.html`.

* `.Rmd`s are only rendered when you explicitly knit them. If you're concerned
  that an `.md` is out of date, call `hugodown::site_outdated()` to list all 
  `.Rmd`s that need to be re-rendered.

* `.Rmd` files use `output: hugodown::hugo_document` to which automatically sets
  the correct chunk knitr options.

* If you want to change an old blog post to use hugodown, you need to rename
  it from `.Rmarkdown` to `.Rmd`, delete the `.markdown` file, and set
  `output: hugodown::hugo_document` in the yaml metadata.
