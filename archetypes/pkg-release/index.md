---
title: 'An exciting package release'
description: >
    Announcing the release of {pkgname} {pkgversion} on CRAN.
date: {{ .Date }}
author: Hadley Wickham
# Featured photo
photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth
  alt: "Photo of sparkler"
# one of: "case studies", "learn", "package", "programming", or "other"
categories: [package] 
---


```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE, comment = "#>", 
  fig.width = 7, 
  fig.align = 'center',
  fig.asp = 0.618, # 1 / phi
  out.width = "700px",
  fig.path = "figs/"
)
```

<!--Every package release should include the following standard text-->

We’re {exceedingly happy} to announce the release of {pkgname} {pkgversion} on CRAN. The goal of the {pkgname} package is to...

You can install {pkgname} with:

```{r install-pkg, eval = FALSE}
install.packages("{pkgname}") # insert pkgname here
```

Attach the package by running:

```{r use-pkg}
library({pkgname}) # insert pkgname here
```


## Acknowledgements

<!--Every package release should include an acknowledgements section individually thanks every major contributor, and collectively thanks all GitHub contributors. You can use `usethis::use_tidy_thanks()` to get all contributors to a package in a time interval and paste this into your post. Examples:
-->

```{r echo = FALSE, eval = FALSE}
# to use, set eval = TRUE
library(usethis)
use_tidy_thanks("OWNER/REPO") ## default: interval = since the last release
use_tidy_thanks("OWNER/REPO", from = "2018-05-01")
use_tidy_thanks("OWNER/REPO", from = "v1.3.0")
```
