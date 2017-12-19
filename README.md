# tidyverse.org

This repo is the source of <https://tidyverse.org>, and this readme tells you how it all works. If you spot any small problems with the website, please feel empowered to fix them directly with a PR. If you see any larger problems, an issue is probably better: that way we can discuss the problem before you commit any time to it.  Read more about contributing to the tidyverse at <https://www.tidyverse.org/contribute/>.

## Previewing changes

### Locally

The source of the website is a collection of `.md` files stored in [`content/`](content/), and turned in to html with [blogdown](https://bookdown.org/yihui/blogdown). To build the site locally, you'll need to install blogdown, and then install hugo, the music behind the magic of blogdown:

```R
install.packages("blogdown")
blogdown::install_hugo()
```

Then run

```R
blogdown::serve_site()
```

This will open a preview of the site in your web browser, and it will automatically update whenever you modify one of the input files.

### In PRs

The tidyverse site is automatically published with [netlify](http://netlify.com/). One big advantage of netlify is that every PR automatically gets a live preview. Once the PR is merged, that preview becomes the live site.

## Content

* `content/*.md`: these files generate the top-level pages on the site:
  packages, learn, help, and contribute. 
  
* `content/articles/`: these files are the tidyverse blog. New blog entries
  should be given name `year-month-slug.md`. Unfortunately this data isn't
  actually used when generating the output file: you'll need to set up 
  the yaml metadata. More on that below.

* `data/events.yaml`: this yaml file contains information about upcoming 
  events. The site automatically filters out events that have happened,
  sorts by date, and then shows at most two events.

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

The slug should match the file name. Generally, the `date` should be similar to the file name, but won't be identical - name the file according to when you created the blog post, but make sure you update the date when you publish the post.

Categories should be one (or more of): "case studies", "learn", "package", "programming", or "other".

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
