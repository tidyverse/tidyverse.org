---
title: forcats 0.5.0
author: Mara Averick
date: '2020-03-02'
slug: forcats-0-5-0
description: >
    Announcing the release of forcats 0.5.0 on CRAN. 
categories:
  - package
tags:
  - tidyverse
  - forcats
photo:
  url: https://unsplash.com/photos/YCPkW_r_6uA
  author: Jari Hytönen
---



We're exceedingly happy to announce the release of [forcats](https://forcats.tidyverse.org/) 0.5.0 on CRAN.
The goal of the forcats package is to provide a suite of tools that solve common problems with factors, including changing the order of levels or the values.

This release includes improvements to several existing functions, as well as a division of [`fct_lump()`](https://forcats.tidyverse.org/reference/fct_lump.html) into four new functions: `fct_lump_min()`, `fct_lump_prop()`, `fct_lump_n()`, and `fct_lump_lowfreq()`. For a complete inventory of updates in this version, please see the [Change log](https://forcats.tidyverse.org/dev/news/index.html).

You can install forcats with:


```r
install.packages("forcats")
```

Attach the package by running:


```r
library(forcats)
```

## New features

### `fct_lump()` function family

Lumping seems like a popular activity, and there are many interesting variants. Splitting fct_lump() into pieces makes it much easier for this collection to grow over time.

  * `fct_lump_min()` lumps levels that appear fewer than `min` times.  
  * `fct_lump_prop()` lumps levels that appear fewer than `prop * n` times.  
  * `fct_lump_n()` lumps all levels except for the `n` most frequent (or least frequent, if `n < 0`).  
  * `fct_lump_lowfreq()` lumps together the least frequent levels, ensuring that `"Other"` is still the smallest level.  
  



```r
x <- factor(rep(LETTERS[1:8], times = c(40, 10, 5, 27, 3, 1, 1, 1)))

x %>% table()
#> .
#>  A  B  C  D  E  F  G  H 
#> 40 10  5 27  3  1  1  1

x %>% fct_lump_min(5) %>% table()
#> .
#>     A     B     C     D Other 
#>    40    10     5    27     6

x %>% fct_lump_prop(0.10) %>% table()
#> .
#>     A     B     D Other 
#>    40    10    27    11

x %>% fct_lump_n(3) %>% table()
#> .
#>     A     B     D Other 
#>    40    10    27    11

x %>% fct_lump_lowfreq() %>% table()
#> .
#>     A     D Other 
#>    40    27    21
```

### New arguments, and helpers

[`fct_collapse()`](https://forcats.tidyverse.org/reference/fct_collapse.html) now has an argument, `other_level`, which allows a user-specified `Other` level. Factors are now correctly collapsed when `other_level` is not `NULL`, and makes `Other` the last level.

[`fct_reorder2()`](https://forcats.tidyverse.org/reference/fct_reorder.html) now has a helper function, `first2()`, which sorts `.y` by the first value of `.x`. 

## Acknowledgements

A special thanks goes out to everyone who contributed to forcats during Tidyverse developer day: [Kelly Bodwin](https://github.com/kbodwin), [Layla Bouzoubaa](https://github.com/labouz), [Scott Brenstuhl](https://github.com/808sAndBR), [Jonathan Carroll](https://github.com/jonocarroll), [Monica Gerber](https://github.com/monicagerber), [John Goldin](https://github.com/johngoldin), [Laura Gomez](https://github.com/gralgomez), [Mitchell O'Hara-Wild](https://github.com/mitchelloharawild), [Riinu Pius](https://github.com/riinuots), and [Emily Robinson](https://github.com/robinsones). 

We're extremely grateful for all 48 people who helped with this release:
[&#x0040;808sAndBR](https://github.com/808sAndBR), [&#x0040;adisarid](https://github.com/adisarid), [&#x0040;alejandroschuler](https://github.com/alejandroschuler), [&#x0040;AmeliaMN](https://github.com/AmeliaMN), [&#x0040;AndrewKinsman](https://github.com/AndrewKinsman), [&#x0040;avishaitsur](https://github.com/avishaitsur), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;bczucz](https://github.com/bczucz), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;bxc147](https://github.com/bxc147), [&#x0040;cuttlefish44](https://github.com/cuttlefish44), [&#x0040;dan-reznik](https://github.com/dan-reznik), [&#x0040;dpprdan](https://github.com/dpprdan), [&#x0040;dylanjm](https://github.com/dylanjm), [&#x0040;GegznaV](https://github.com/GegznaV), [&#x0040;ghost](https://github.com/ghost), [&#x0040;gralgomez](https://github.com/gralgomez), [&#x0040;gtm19](https://github.com/gtm19), [&#x0040;hadley](https://github.com/hadley), [&#x0040;hongcui](https://github.com/hongcui), [&#x0040;jamiefo](https://github.com/jamiefo), [&#x0040;jburos](https://github.com/jburos), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;johngoldin](https://github.com/johngoldin), [&#x0040;jonocarroll](https://github.com/jonocarroll), [&#x0040;jtr13](https://github.com/jtr13), [&#x0040;jwilliman](https://github.com/jwilliman), [&#x0040;jzadra](https://github.com/jzadra), [&#x0040;kbodwin](https://github.com/kbodwin), [&#x0040;kei51e](https://github.com/kei51e), [&#x0040;kyzphong](https://github.com/kyzphong), [&#x0040;labouz](https://github.com/labouz), [&#x0040;ledbettc](https://github.com/ledbettc), [&#x0040;lwjohnst86](https://github.com/lwjohnst86), [&#x0040;martinjhnhadley](https://github.com/martinjhnhadley), [&#x0040;melissakey](https://github.com/melissakey), [&#x0040;mitchelloharawild](https://github.com/mitchelloharawild), [&#x0040;monicagerber](https://github.com/monicagerber), [&#x0040;mstr3336](https://github.com/mstr3336), [&#x0040;riinuots](https://github.com/riinuots), [&#x0040;robinsones](https://github.com/robinsones), [&#x0040;sgschreiber](https://github.com/sgschreiber), [&#x0040;sinarueeger](https://github.com/sinarueeger), [&#x0040;sindribaldur](https://github.com/sindribaldur), [&#x0040;stelsemeyer](https://github.com/stelsemeyer), [&#x0040;VincentGuyader](https://github.com/VincentGuyader), [&#x0040;yimingli](https://github.com/yimingli), and [&#x0040;zkamvar](https://github.com/zkamvar).
