# tidyverse.org

This repo is the source of <https://tidyverse.org>, and this readme tells you how it all works. 

* If you spot any small problems with the website, please feel empowered to fix 
  them directly with a PR. 
  
* If you see any larger problems, an issue is probably better: that way we can 
  discuss the problem before you commit any time to it.

* If you'd like to contribute a blog post, please chat with one of us first.
  Then reading the [contributing guide](CONTRIBUTING.md)

This repo (and resulting website) is licensed as [CC BY-SA](license.md).

## Structure

The source of the website is a collection of `.md` files stored in [`content/`](content/), and turned in to html with [blogdown](https://bookdown.org/yihui/blogdown). 

* `content/*.md`: these files generate the top-level pages on the site:
  packages, learn, help, and contribute. 
  
* `content/articles/`: these files are the tidyverse blog. New blog entries
  should be given name `year-month-slug.md`. Unfortunately this data isn't
  actually used when generating the output file: you'll need to set up 
  the yaml metadata. More on that below.

* `data/events.yaml`: this yaml file contains information about upcoming 
  events. The site automatically filters out events that have happened,
  sorts by date, and then shows at most two events.

## Previewing changes

### Locally

To build the site locally, you'll need to install blogdown, and then install hugo, the music behind the magic of blogdown:

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
