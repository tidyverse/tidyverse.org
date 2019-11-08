---
title: haven 2.2.0
author: Hadley Wickham
date: '2019-11-08'
slug: haven-2-2-0
categories:
  - package
tags:
  - tidyverse
  - haven
description:
  A new version of haven makes it easy to read only parts of a file.
photo:
  url: https://unsplash.com/photos/R2bvzUYIdgY
  author: Tina Rolf
---



We're delighted to announce that [haven 2.2.0](https://haven.tidyverse.org/) is now on CRAN. haven enables R to read and write various data formats used by other statistical packages by wrapping the [ReadStat](https://github.com/WizardMac/ReadStat) C library written by [Evan Miller](https://www.evanmiller.org/). 

You can install haven from CRAN with:


```r
install.packages("haven")
```

This release features big improvements thanks to the hard work of [Mikko Marttila](https://github.com/mikmart): all `read_*()` functions gain three new arguments that allow you to read in only part of a large file. I'll quickly show of these features by saving out the [`diamonds`](https://ggplot2.tidyverse.org/reference/diamonds.html) dataset to a Stata file:


```r
library(haven)
write_dta(ggplot2::diamonds, "diamonds.dta")
```

`n_max` and `skip` allow you to read in just a portion of the rows:


```r
read_dta("diamonds.dta", n_max = 5)
#> # A tibble: 5 x 10
#>   carat         cut     color   clarity depth table price     x     y     z
#>   <dbl>   <dbl+lbl> <dbl+lbl> <dbl+lbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 0.23  5 [Ideal]       2 [E]   2 [SI2]  61.5    55   326  3.95  3.98  2.43
#> 2 0.21  4 [Premium]     2 [E]   3 [SI1]  59.8    61   326  3.89  3.84  2.31
#> 3 0.23  2 [Good]        2 [E]   5 [VS1]  56.9    65   327  4.05  4.07  2.31
#> 4 0.290 4 [Premium]     6 [I]   4 [VS2]  62.4    58   334  4.2   4.23  2.63
#> 5 0.31  2 [Good]        7 [J]   2 [SI2]  63.3    58   335  4.34  4.35  2.75
read_dta("diamonds.dta", skip = 4, n_max = 5)
#> # A tibble: 5 x 10
#>   carat          cut     color  clarity depth table price     x     y     z
#>   <dbl>    <dbl+lbl> <dbl+lbl> <dbl+lb> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  0.31 2 [Good]         7 [J] 2 [SI2]   63.3    58   335  4.34  4.35  2.75
#> 2  0.24 3 [Very Goo…     7 [J] 6 [VVS2]  62.8    57   336  3.94  3.96  2.48
#> 3  0.24 3 [Very Goo…     6 [I] 7 [VVS1]  62.3    57   336  3.95  3.98  2.47
#> 4  0.26 3 [Very Goo…     5 [H] 3 [SI1]   61.9    55   337  4.07  4.11  2.53
#> 5  0.22 1 [Fair]         2 [E] 4 [VS2]   65.1    61   337  3.87  3.78  2.49
```

And `col_select()` allows you to read in just some of the columns, using the same syntax that you use with [`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html):


```r
read_dta("diamonds.dta", col_select = c(x:z))
#> # A tibble: 53,940 x 3
#>        x     y     z
#>    <dbl> <dbl> <dbl>
#>  1  3.95  3.98  2.43
#>  2  3.89  3.84  2.31
#>  3  4.05  4.07  2.31
#>  4  4.2   4.23  2.63
#>  5  4.34  4.35  2.75
#>  6  3.94  3.96  2.48
#>  7  3.95  3.98  2.47
#>  8  4.07  4.11  2.53
#>  9  3.87  3.78  2.49
#> 10  4     4.05  2.39
#> # … with 53,930 more rows

read_dta("diamonds.dta", col_select = starts_with("c"))
#> # A tibble: 53,940 x 4
#>    carat           cut     color   clarity
#>    <dbl>     <dbl+lbl> <dbl+lbl> <dbl+lbl>
#>  1 0.23  5 [Ideal]         2 [E]  2 [SI2] 
#>  2 0.21  4 [Premium]       2 [E]  3 [SI1] 
#>  3 0.23  2 [Good]          2 [E]  5 [VS1] 
#>  4 0.290 4 [Premium]       6 [I]  4 [VS2] 
#>  5 0.31  2 [Good]          7 [J]  2 [SI2] 
#>  6 0.24  3 [Very Good]     7 [J]  6 [VVS2]
#>  7 0.24  3 [Very Good]     6 [I]  7 [VVS1]
#>  8 0.26  3 [Very Good]     5 [H]  3 [SI1] 
#>  9 0.22  1 [Fair]          2 [E]  4 [VS2] 
#> 10 0.23  3 [Very Good]     5 [H]  5 [VS1] 
#> # … with 53,930 more rows
```

These features allow you to read in datasets that would otherwise not fit in memory, and should substantially improve performance when you only need a few rows or columns from a large file.

This release includes a number of other bug fixes and small improvements, see the [changelog](https://haven.tidyverse.org/news/index.html) for a complete list.

## Acknowledgements

A big thanks to everyone who helped out with this release: 
[&#x0040;aaronrudkin](https://github.com/aaronrudkin), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;ccccfys](https://github.com/ccccfys), [&#x0040;courtiol](https://github.com/courtiol), [&#x0040;hadley](https://github.com/hadley), [&#x0040;Hadsga](https://github.com/Hadsga), [&#x0040;jeremy17-Endo](https://github.com/jeremy17-Endo), [&#x0040;KyleHaynes](https://github.com/KyleHaynes), [&#x0040;lguangyu](https://github.com/lguangyu), [&#x0040;mihagazvoda](https://github.com/mihagazvoda), [&#x0040;mikmart](https://github.com/mikmart), [&#x0040;MokeEire](https://github.com/MokeEire), [&#x0040;npaszty](https://github.com/npaszty), [&#x0040;pvanheus](https://github.com/pvanheus), [&#x0040;RaymondBalise](https://github.com/RaymondBalise), [&#x0040;sclewis23](https://github.com/sclewis23), [&#x0040;shubham1637](https://github.com/shubham1637), [&#x0040;sigbertklinke](https://github.com/sigbertklinke), [&#x0040;steffen-stell](https://github.com/steffen-stell), and [&#x0040;ttrodrigz](https://github.com/ttrodrigz).
