# tidyverse.org

This repo is the source of <https://tidyverse.org>, and this readme tells you 
how it all works. 

* If you spot any small problems with the website, please feel empowered to fix 
  them directly with a PR. 
  
* If you see any larger problems, an issue is probably better: that way we can 
  discuss the problem before you commit any time to it.

* If you'd like to contribute a blog post, please chat with one of us first.
  Then read the [contributing guide](CONTRIBUTING.md).

This repo (and resulting website) is licensed as [CC BY-SA](license.md).

## Structure

The source of the website is a collection of `.md` and `.Rmd` files stored in 
[`content/`](content/), which are rendered for the site with 
[blogdown](https://bookdown.org/yihui/blogdown). 

* `content/*.md`: these files generate the top-level pages on the site:
  packages, learn, help, and contribute. 
  
* `content/articles/`: these files are the tidyverse blog. New blog entries
  should be given name `year-month-slug.md`. Unfortunately this data isn't
  actually used when generating the output file: you'll need to set up 
  the yaml metadata. More on that below.  
    + For `*.md` posts, no `*.html` file should be generated. If one is, it 
    should not be committed/pushed, and can be deleted.  
    
    + For `*.Rmd` posts, an `*.html` file _should_ be generated when you run 
    `blogdown::serve_site()` (see below).  
    
    + If you plan to include emoji in your post, you should use the `.Rmd` 
    format, and generate emoji using the [emo](https://github.com/hadley/emo)
    package.  

* `data/events.yaml`: this yaml file contains information about upcoming 
  events. The site automatically filters out events that have happened,
  sorts by date, and then shows at most two events.

## Previewing changes

### Locally

To build the site locally, you'll need to install blogdown, and then install 
hugo, the music behind the magic of blogdown:

```R
install.packages("blogdown")
blogdown::install_hugo()
```

Then run

```R
blogdown::serve_site()
```

This will open a preview of the site in your web browser, and it will 
automatically update whenever you modify one of the input files. For `.Rmd`, 
this will generate an `.html` file, which you should commit/push to GitHub. If 
this _does_ generate an `.html` file from an **`.md`** file, do **not** commit 
it.

#### Note re. local preview, not with blogdown

For generating files (and for previewing them as they will look on the site), 
you should use `blogdown::serve_site()`. If, accidentally or intentionally, you 
knit or preview the content using another method (e.g. click the **Preview** 
button in RStudio for `.[R]md`), you should delete the generated files before 
committing your work.

### In PRs

The tidyverse site is automatically published with 
[netlify](http://netlify.com/). One big advantage of netlify is that every PR 
automatically gets a live preview. Once the PR is merged, that preview becomes 
the live site.
