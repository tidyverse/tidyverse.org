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

The slug should match the file name. Generally, the `date` should be similar to the file name, but won't be identical - name the file according to when you created the blog post using the format `yyyy-mm-post-slug`, but make sure you update the date in the YAML header when you publish the post.

Categories should be one (or more of): "case studies", "learn", "package", "programming", or "other".

### Filetype

Posts can be written in any of the blogdown-supported formats: `.Rmd`, `.Rmarkdown`, and `.md` (in the event that you do not have any code in your post). 

If you have any subheaders in your post you should use `.Rmarkdown`. An `.Rmarkdown` file renders to `.md`, which Hugo uses to create a table of contents, displayed in the sidebar. This does not work for `.Rmd`, which renders directly to `.html`.

### RMarkdown setup

After the header, include our standard RMarkdown setup block:

````
```{r setup, include = FALSE}
library(testthat)
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
```
````

(Replace `testthat` here and below with your own package name.)

### Photos

Every blog post needs to be accompanied by two versions of a photo:

* `slug-sq.jpg` should be 300 x 300 pixels, and is shown on the articles listing.

* `slug-wd.jpg` should be 200 pixels high and at least 1000 pixels wide.  
  It is shown on the individual article page.
  
If you don't already have a image in mind, I recommend looking on <https://unsplash.com>. If you do use a photo from a website, make sure to credit the author as shown with the `photo` metadata shown above.

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

Inline images can be added to articles by placing them in the `/static/images/` 
directory. By current convention, these go in a subdirectory for each post.
Images are added to the markdown by giving the full file-path, e.g.

```
![](/images/subdir/image-name.jpg)
```

### Acknowledgements

Every package release should include an acknowledgements section individually thanks every major contributor, and collectively thanks all GitHub contributors. You can use the following block of code to get all contributors:

```R
gh_users <- function(owner, repo, since) {
  x <- gh::gh(
    "/repos/:owner/:repo/issues", 
    owner = owner, 
    repo = repo, 
    since = since, 
    state = "all", 
    .limit = Inf
  )
  sort(unique(purrr::map_chr(x, c("user", "login"))))
}

users <- gh_users("r-dbi", "bigrquery", "2017-06-26")
length(users)
ack <- glue::glue_collapse(glue::glue("[\\@{users}](https://github.com/{users})"), ", ", last = ", and ")
clipr::write_clip(ack)
```

(Make sure to update owner, repo, and since)

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
  "deligthed", character(),
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
