---
output: hugodown::hugo_document

slug: r4ds-2e
title: R for Data Science, 2nd edition
date: 2023-07-11
author: Mine Çetinkaya-Rundel
description: >
    The second edition of R for Data Science is out,
    and it's a major reworking of the first edition.
photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn] 
tags: [book]
rmd_hash: 02fdb713a9b1904b

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're thrilled to announce the publication of the 2nd edition of [R for Data Science](r4ds.hadley.nz).

The second edition is a major reworking of the first edition, removing material we no longer think is useful, adding material we wish we included in the first edition, and generally updating the text and code to reflect changes in best practices.

You can read the book online for free at <a href="https://r4ds.hadley.nz/" class="uri">https://r4ds.hadley.nz</a>, or [buy a physical copy](https://www.amazon.com/Data-Science-Transform-Visualize-Model/dp/1492097403/ref=sr_1_1?crid=19VLZ2HBNTMG2).

Read below to find out what's new and what's gone compared to the first edition.

## What's new?

We have renamed the first part of the book to ["Whole game"](https://r4ds.hadley.nz/whole-game.html), with the goal of giving you the rough details of the \"whole game\" of data science, including data visualization, transformation, tidying, and import, before we dive into the details. The data visualization chapter has gained a new section written with the ["cake first"](https://datasciencebox.org/01-design-principles.html) approach, which starts with the final visualization you will learn to make, and then builds up to it layer-by-layer. The data tidying chapter introduces the basics of lengthening and widening data and the data import chapter introduces reading tabular data.

The second part of the book is [\"Visualize\"](https://r4ds.hadley.nz/visualize.html), which gives data visualization tools and best practices a more thorough coverage compared to the first edition.

The third part of the book is now called [\"Transform\"](https://r4ds.hadley.nz/transform.html)and gains new chapters on numbers, logical vectors, and missing values. Much of this content was previously part of the data transformation chapter. In this edition we have expanded them to cover all the details.

The fourth part of the book is called [\"Import\"](https://r4ds.hadley.nz/import.html), it\'s a new set of chapters that goes beyond reading flat text files to working with spreadsheets (Excel and GoogleSheets), databases, and big data (with Arrow) as well as rectangling hierarchical data and scraping data from web sites.

The [\"Program\"](https://r4ds.hadley.nz/program.html) part has been rewritten from to focus on the most important parts of function writing and iteration. Function writing now includes details on how to wrap tidyverse functions (dealing with the challenges of tidy evaluation), since this has become much easier and more important over the last few years. We have also added a new chapter on important base R functions that you\'re likely to see in wild-caught R code.

Finally, the [\"Communicate\"](https://r4ds.hadley.nz/communicate.html) part remains, but has been thoroughly updated to feature [Quarto](https://quarto.org/) instead of R Markdown. This edition of the book has been written in Quarto, and it\'s clearly the tool of the future.

## What's gone?

The first edition of the book featured a part on modeling, which has now been removed. We never had enough room to fully do modelling justice, and there are now much better resources available. We generally recommend using the [tidymodels](https://www.tidymodels.org/) packages and reading [Tidy Modeling with R](https://www.tmwr.org/) by Max Kuhn and Julia Silge.

## Acknowledgements

This book isn\'t just the product of Hadley, Mine, and Garrett but is the result of many conversations (in person and online) that we\'ve had with many people in the R community. Huge thanks to [all contributors](And,%20as%20always,%20issues%20and%20pull%20requests%20welcome%20on%20the%20book%20repository.) for the conversations, issues, and pull requests. And, as always, issues and pull requests welcome on the [book repository](https://github.com/hadley/r4ds/).

