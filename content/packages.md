---
title: Tidyverse packages
---

## Installation and use

* Install all the packages in the tidyverse by running `install.packages("tidyverse")`.

* Run `library(tidyverse)` to load the core tidyverse and make available 
  in your current R session.
  
Learn more about the tidyverse package at <http://tidyverse.tidyverse.org>.

<a href="http://tidyverse.tidyverse.org"><img src="/images/hex-tidyverse.png" width="120" height="139" float = "right"/></a>


## Core tidyverse

The core tidyverse includes the packages that you're likely to use in the every data analyses. As of tidyverse 1.1.0, the following packages are included in the code tidyverse:

<ul>
<li>
  <a href="http://ggplot2.tidyverse.org"><img src="/images/hex-ggplot2.png" width="120" height="139" />
  </a>
  ggplot2 is a system for declaratively creating graphics, based on The Grammar of Graphics. You provide the data, tell ggplot2 how to map variables to aesthetics, what graphical primitives to use, and it takes care of the details.
</li>

<li>
  <a href="http://dplyr.tidyverse.org"><img src="/images/hex-dplyr.png" width="120" height="139" />
  </a>
  dplyr provides is a grammar of data manipulation, providing a consistent set of verbs that help you solve the most common data manipulation challenges.
</li>

<li>
  <a href="http://tidyr.tidyverse.org"><img src="/images/hex-tidyr.png" width="120" height="139" />
  </a>
  tidyr provides a set of functions that help you get to tidy data. Tidy data is data with a consistent form: in brief, every variable goes in a column, and every column is a variable.
</li>

<li>
  <a href="http://readr.tidyverse.org"><img src="/images/hex-readr.png" width="120" height="139" />
  </a>
  readr provides a fast and friendly way to read rectangular data (like csv, tsv, and fwf). It is designed to flexibly parse many types of data found in the wild, while still cleanly failing when data unexpectedly changes. 
</li>

<li>
  <a href="http://purrr.tidyverse.org"><img src="/images/hex-purrr.png" width="120" height="139" />
  </a>
  purrr enhances R’s functional programming (FP) toolkit by providing a complete and consistent set of tools for working with functions and vectors. Once you master the basic concepts, purrr allows you to replace many for loops with code that is easier to write and more expressive.
</li>

<li>
  <a href="http://tibble.tidyverse.org"><img src="/images/hex-tibble.png" width="120" height="139" />
  </a>
  tibble is a modern re-imaginging of the data frame, keeping what time has proven to be effective, and throwing out what is not. Tibbles are data.frames that are lazy and surly: they do less (i.e. they don’t change variable names or types, and don’t do partial matching) and complain more (e.g. when a variable does not exist). This forces you to confront problems earlier, typically leading to cleaner, more expressive code. 
</li>

</ul>

The tidyverse also includes many other packages with more specialised usage. They are not loaded automatically with `library(tidyverse)`, so you'll need to load each one with its own call to `library()`.

## Import

As well as [readr](http://readr.tidyverse.org), for reading flat files, the tidyverse includes:

* [readxl](http://readxl.tidyverse.org) for `.xls` and `.xlsx` sheets.
* [haven](http://haven.tidyverse.org) for SPSS, Stata, and SAS data.

There are a handful for other packages that are not in the tidyverse, but are tidyverse-adjacent. They are very useful for importing data from other sources:

* [jsonlite](https://github.com/jeroen/jsonlite#jsonlite) for JSON.

* [xml2](https://github.com/r-lib/xml2) for XML.

* [httr](https://github.com/r-lib/httr) for web APIs.

* [rvest](https://github.com/hadley/rvest) for web scraping.

* [DBI](https://github.com/rstats-db/DBI) for relational databases.
  To connect to a specific database, you'll need to pair DBI with a specific
  backend like RSQLite, RPostgres, or odbc. Learn more at 
  <http://db.rstudio.com>.

## Wrangle

As well as [tidyr](http://tidyr.tidyverse.org), and [dplyr](http://dplyr.tidyverse), there are five packages designed to work with specific types of data:

* [stringr](http://stringr.tidyverse.org) for strings.
* [lubridate](http://lubridate.tidyverse.org) for dates and date-times.
* [forcats](http://forcats.tidyverse.org) for categorical variables (factors).
* [hms](https://github.com/tidyverse/hms) for time-of-day values.
* [blob](https://github.com/tidyverse/blob) for storing blob (binary) data.

## Program

As well as [purrr](http://purrr.tidyverse.org) which faciliates functional programming, there are two tidyverse packages that help with general programming challenges:

* [magrittr](http://magrittr.tidyverse.org) provides the pipe, `%>%` used 
  throughout the tidyverse. It also provide a number of more specialised
  piping operators (like `%$%` and `%<>%`) that can be useful in other places.

* [glue](https://github.com/tidyverse/glue) provides an alternative to 
  `paste()` that makes it easier to combine data and strings.

## Model

Modelling within the tidyverse is largely a work in progress. You can see some of the pieces in the [recipes](http://github.com/topepo/recipes) and [rsample](http://github.com/topepo/rsample) packages but we do not yet have a cohesive system that solves a wide range of challenges. This work will largely replace the [modelr](https://github.com/tidyverse/modelr) package used in R4DS.

You may also find [broom](https://github.com/tidyverse/broom) to be useful: it turns models into tidy data which you can then wrangle and visualise using the tools you already know for.
