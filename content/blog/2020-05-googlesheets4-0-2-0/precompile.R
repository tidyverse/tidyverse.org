# this post can only be compiled by someone with the right token setup

library(knitr)

knit(
  # the leading `_` keeps blogdown from re-rendering the original
  "content/blog/2020-05-googlesheets4-0-2-0/index.Rmarkdown.orig",
  "content/blog/2020-05-googlesheets4-0-2-0/index.Rmarkdown"
)
