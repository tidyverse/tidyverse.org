---
title: Tidyverse packages
---

## Installation and use

* Install all the packages in the tidyverse by running `install.packages("tidyverse")`.

* Run `library(tidyverse)` to load the core tidyverse and make it available
  in your current R session.

Learn more about the tidyverse package at <http://tidyverse.tidyverse.org>.

<div class="package-section">

<div class="package-section-info">
  <h2 id="core-tidyverse">Core tidyverse</h2>
  <p>The core tidyverse includes the packages that you're likely to use in everyday data analyses. As of tidyverse 1.2.0, the following packages are included in the core tidyverse:</p>
</div>

<div class="packages">
  <div class="package">
    <img class="package-image" src="/images/hex-ggplot2.png" alt=""></img>
    <div class="package-info">
      <h3><a href="http://ggplot2.tidyverse.org/">ggplot2</a></h3>
      <p>ggplot2 is a system for declaratively creating graphics, based on The Grammar of Graphics. You provide the data, tell ggplot2 how to map variables to aesthetics, what graphical primitives to use, and it takes care of the details. <a href="http://ggplot2.tidyverse.org/" aria-hidden="true">Learn more ...</a></p>

    </div>
  </div>
  <div class="package">
    <img class="package-image" src="/images/hex-dplyr.png" alt=""></img>
    <div class="package-info">
      <h3><a href="http://dplyr.tidyverse.org/">dplyr</a></h3>
      <p>dplyr provides a grammar of data manipulation, providing a consistent set of verbs that solve the most common data manipulation challenges. <a href="http://dplyr.tidyverse.org/" aria-hidden="true">Learn more ...</a></p>
    </div>
  </div>
  <div class="package">
    <img class="package-image" src="/images/hex-tidyr.png" alt=""></img>
    <div class="package-info">
      <h3><a href="http://tidyr.tidyverse.org/">tidyr</a></h3>
      <p>tidyr provides a set of functions that help you get to tidy data. Tidy data is data with a consistent form: in brief, every variable goes in a column, and every column is a variable. <a href="http://tidyr.tidyverse.org/" aria-hidden="true">Learn more ...</a></p>
    </div>
  </div>
  <div class="package">
    <img class="package-image" src="/images/hex-readr.png" alt=""></img>
    <div class="package-info">
      <h3><a href="http://readr.tidyverse.org/">readr</a></h3>
      <p>readr provides a fast and friendly way to read rectangular data (like csv, tsv, and fwf). It is designed to flexibly parse many types of data found in the wild, while still cleanly failing when data unexpectedly changes. <a href="http://readr.tidyverse.org/" aria-hidden="true">Learn more ...</a></p>
    </div>
  </div>
  <div class="package">
    <img class="package-image" src="/images/hex-purrr.png" alt=""></img>
    <div class="package-info">
      <h3><a href="http://purrr.tidyverse.org/">purrr</a></h3>
      <p>purrr enhances R’s functional programming (FP) toolkit by providing a complete and consistent set of tools for working with functions and vectors. Once you master the basic concepts, purrr allows you to replace many for loops with code that is easier to write and more expressive.
      <a href="http://purrr.tidyverse.org/" aria-hidden="true">Learn more ...</a></p>
    </div>
  </div>
  <div class="package">
    <img class="package-image" src="/images/hex-tibble.png" alt=""></img>
    <div class="package-info">
      <h3><a href="http://tibble.tidyverse.org/">tibble</a></h3>
      <p>tibble is a modern re-imagining of the data frame, keeping what time has proven to be effective, and throwing out what it has not. Tibbles are data.frames that are lazy and surly: they do less and complain more forcing you to confront problems earlier, typically leading to cleaner, more expressive code.
      <a href="http://tibble.tidyverse.org/" aria-hidden="true">Learn more ...</a></p>
    </div>
  </div>
  <div class="package">
    <img class="package-image" src="/images/hex-stringr.png" alt=""></img>
    <div class="package-info">
      <h3><a href="http://stringr.tidyverse.org/">stringr</a></h3>
      <p>stringr provides a cohesive set of functions designed to make working with strings as easy as possible. It is built on top of stringi, which uses the ICU C library to provide fast, correct implementations of common string manipulations.
      <a href="http://stringr.tidyverse.org/" aria-hidden="true">Learn more ...</a></p>
    </div>
  </div>
  <div class="package">
    <img class="package-image" src="/images/hex-forcats.png" alt=""></img>
    <div class="package-info">
      <h3><a href="http://forcats.tidyverse.org/">forcats</a></h3>
      <p>forcats provides a suite of useful tools that solve common problems with factors. R uses factors to handle categorical variables, variables that have a fixed and known set of possible values.
      <a href="http://forcats.tidyverse.org/" aria-hidden="true">Learn more ...</a></p>
    </div>
  </div>
</div>
</div>

The tidyverse also includes many other packages with more specialised usage. They are not loaded automatically with `library(tidyverse)`, so you'll need to load each one with its own call to `library()`.

## Import

As well as [readr](http://readr.tidyverse.org), for reading flat files, the tidyverse includes:

* [readxl](http://readxl.tidyverse.org) for `.xls` and `.xlsx` sheets.

* [haven](http://haven.tidyverse.org) for SPSS, Stata, and SAS data.

There are a handful of other packages that are not in the tidyverse, but are tidyverse-adjacent. They are very useful for importing data from other sources:

* [jsonlite](https://github.com/jeroen/jsonlite#jsonlite) for JSON.

* [xml2](https://github.com/r-lib/xml2) for XML.

* [httr](https://github.com/r-lib/httr) for web APIs.

* [rvest](https://github.com/hadley/rvest) for web scraping.

* [DBI](https://github.com/rstats-db/DBI) for relational databases.
  To connect to a specific database, you'll need to pair DBI with a specific
  backend like RSQLite, RPostgres, or odbc. Learn more at
  <http://db.rstudio.com>.

## Wrangle

In addition to [tidyr](http://tidyr.tidyverse.org), and [dplyr](http://dplyr.tidyverse.org), there are five packages (including [stringr](http://stringr.tidyverse.org) and [forcats](http://forcats.tidyverse.org)) which are designed to work with specific types of data:

* [lubridate](http://lubridate.tidyverse.org) for dates and date-times.
* [hms](https://github.com/tidyverse/hms) for time-of-day values.
* [blob](https://github.com/tidyverse/blob) for storing blob (binary) data.

## Program

In addition to [purrr](http://purrr.tidyverse.org), which provides very consistent and natural methods for iterating on R objects, there are two additional tidyverse packages that help with general programming challenges:

* [magrittr](http://magrittr.tidyverse.org) provides the pipe, `%>%` used
  throughout the tidyverse. It also provide a number of more specialised
  piping operators (like `%$%` and `%<>%`) that can be useful in other places.

* [glue](https://github.com/tidyverse/glue) provides an alternative to
  `paste()` that makes it easier to combine data and strings.

## Model

Modelling within the tidyverse is largely a work in progress. You can see some of the pieces in the [recipes](http://github.com/topepo/recipes) and [rsample](http://github.com/topepo/rsample) packages but we do not yet have a cohesive system that solves a wide range of challenges. This work will largely replace the [modelr](https://github.com/tidyverse/modelr) package used in [R4DS](http://r4ds.had.co.nz/).

You may also find [broom](https://github.com/tidyverse/broom) to be useful: it turns models into tidy data which you can then wrangle and visualise using the tools you already know.

## Get help

If you’re asking for R help, reporting a bug, or requesting a new feature, you’re more likely to succeed if you include a good reproducible example, which is precisely what the [reprex](http://reprex.tidyverse.org/) package is meant for. You can learn more about reprex, along with other tips on how to help others help you in the [help section](https://www.tidyverse.org/help/).
