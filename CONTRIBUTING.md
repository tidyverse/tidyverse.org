## Blog posts

Every blog post needs to start with a yaml metadata block that looks like this:

```yaml
title: Welcome!
slug: welcome
description: >
    A 2-3 sentence description of the post that appears on the articles page.
date: 2017-07-30
author: Hadley Wickham
photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth
categories: [Other]
```

Every blog post goes into its own subdirectory under `/content/blog`. The file must be named `index.Rmarkdown` or `index.md`. The slug should match the directory name. Generally, the `date` should be similar to the directory name, but won't be identical - name the directory according to when you created the blog post using the format `yyyy-mm-post-slug`, but make sure you update the date in the YAML header when you publish the post.

Categories should be one (or more of): "case studies", "learn", "package", "programming", or "other".

### Filetype

Posts should be written as either `.Rmarkdown`, or `.md` files (in the event that you do not have any code in your post). 

An `.Rmarkdown` file renders to `.md`, which Hugo uses to create a table of contents from your post headers, displayed in the sidebar. This does not work for `.Rmd`, which renders directly to `.html`.

If you are using `.Rmarkdown`, you should render the `.md` yourself before submitting the post using `blogdown::serve_site()`. This also provides a way for you to check that the post is rendering on the site the way you intended.

### RMarkdown setup

After the header, include our standard RMarkdown setup block:

````
```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>", 
  fig.width = 7, 
  fig.align = 'center',
  fig.asp = 0.618, # 1 / phi
  out.width = "700px"
)
```
````

The `library(PACKAGENAME)` call should be done explicitly in a visible code chunk.

### Photos

Every blog post needs to be accompanied by two versions of a photo:

* `thumbnail-sq.jpg` should be 300 x 300 pixels, and is shown on the articles listing.

* `thumbnail-wd.jpg` should be 200 pixels high and at least 1000 pixels wide.  
  It is shown on the individual article page.
  
If you don't already have a image in mind, I recommend looking on <https://unsplash.com> or <https://pexels.com>. Jenny Bryan's [collection of websites](https://github.com/jennybc/free-photos) has many more. If you do use a photo from a website, make sure to credit the author as shown with the `photo` metadata shown above.

Some indicative [magick](https://cran.r-project.org/web/packages/magick/vignettes/intro.html) code to produce suitable images:

```R
library(magick)
img <- image_read("giant_cloud_image.jpg")
img %>% 
  image_crop("2988x2988+1200+0") %>% 
  image_scale("300x300") %>% 
  image_write("content/articles/googledrive-initial-release-sq.jpg")
img %>% 
  image_crop("5000x1000+200+1400") %>% 
  image_scale("1000x200") %>% 
  image_write("content/articles/googledrive-initial-release-wd.jpg")
```

### Inline images

The images can live alongside the blog post and referred without relative path.

```
![](image-name.jpg)
```

### Acknowledgements

Every package release should include an acknowledgements section individually thanks every major contributor, and collectively thanks all GitHub contributors. You can use `usethis::use_tidy_thanks()` to get all contributors to a package in a time interval and paste this into your post. Examples:

```R
use_tidy_thanks("OWNER/REPO") ## default: interval = since the last release
use_tidy_thanks("OWNER/REPO", from = "2018-05-01")
use_tidy_thanks("OWNER/REPO", from = "v1.3.0")
```
### First sentence

```R
start <- tibble::tribble(
  ~word, ~modifiers,
  "chuffed", character(),
  "pleased", c("most", "very", "extremely", "well"),
  "stoked", character(),
  "chuffed", "very",
  "happy", c("so", "very", "exceedingly"),
  "thrilled", character(),
  "delighted", character(),
  "tickled pink", character(),
)

phrase <- function(package) {
  row <- start[sample(nrow(start), 1), ]

  phrase <- row$word
  modifiers <- row$modifiers[[1]]
  if (length(modifiers) > 0 && runif(1) < 0.5) {
    phrase <- paste0(sample(modifiers, 1), " ", phrase)
  }
  
  glue::glue("We're {phrase} to announce the release of {package}")
}

replicate(50, phrase("ggplot2"))
```
