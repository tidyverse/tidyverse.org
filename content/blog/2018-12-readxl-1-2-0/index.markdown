---
title: 'readxl 1.2.0'
slug: readxl-1-2-0
description: > 
  readxl 1.2.0 is now on CRAN.
date: '2018-12-20'
author: Jenny Bryan
photo:
  url: https://twitter.com/Thoughtfulnz/status/987900521309614080
  author: David Hood
categories:
  - package
---



We're stoked to announce that [readxl](http://readxl.tidyverse.org) 1.2.0 is now available on CRAN. Learn more about readxl at <http://readxl.tidyverse.org>. Detailed notes are always in the [change log](https://readxl.tidyverse.org/news/index.html#readxl-1-2-0).

The readxl package makes it easy to get tabular data out of Excel files and into R with code, not mouse clicks. It supports both the legacy `.xls` format and the modern XML-based `.xlsx` format. readxl is expressly designed to be easy to install and use on all operating systems. Therefore it has no external dependencies, such as Java or Perl, which have historically been a source of aggravation with some R packages that read Excel files.

The easiest way to install the latest version from CRAN is to install the whole tidyverse.


```r
install.packages("tidyverse")
```

Alternatively, install just readxl from CRAN:


```r
install.packages("readxl")
```

Regardless, you will still need to attach readxl explicitly. It is not a core tidyverse package, i.e. readxl is NOT attached via `library(tidyverse)`. Instead, do this in your script:


```r
library(readxl)
```

## Column name repair

The most exciting change in the v1.2.0 release is the introduction of the new `.name_repair` argument to `read_excel()`, `read_xlsx()`, and `read_xls()`. readxl exposes the `.name_repair` argument that is [coming soon to version 2.0.0 of the tibble package](https://www.tidyverse.org/articles/2018/11/tibble-2.0.0-pre-announce/). **Note: the following examples were executed with the not-yet-released version 2.0.0 of the tibble package.**

First, rest assured that if your sheet has unique column names, readxl leaves them alone, as always:


```r
read_excel(readxl_example("datasets.xlsx"), sheet = "iris", n_max = 3)
#> # A tibble: 3 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <chr>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa
```

However, spreadsheet column names frequently leave much to be desired. `.name_repair` is a more flexible alternative to passing a specific vector of `col_names`. You can express what you want in two main ways:

  * Levels of name repair:
    - `"minimal"`: use `""` for any missing names
    - `"unique"`: names are made unique **readxl's default**
    - `"universal"`: names are made `"unique"` and syntactic
  * Name repair strategy, as a function that takes (bad) names in and returns (good) names:
    - Function defined in base R, by another package, or by you
    - Anonymous function, specified using a purrr-style `~` formula

Here are two examples of specifying a name repair strategy.


```r
## pass custom function to implement "lower_snake_case"
my_custom_name_repair <- function(nms) tolower(gsub("[.]", "_", nms))
read_excel(
  readxl_example("datasets.xlsx"), n_max = 3,
  .name_repair = my_custom_name_repair
)
#> # A tibble: 3 x 5
#>   sepal_length sepal_width petal_length petal_width species
#>          <dbl>       <dbl>        <dbl>       <dbl> <chr>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa

## use purrr-style formula to truncate names at 3 characters
read_excel(
  readxl_example("datasets.xlsx"), sheet = "chickwts", n_max = 3,
  .name_repair = ~ substr(.x, start = 1, stop = 3)
)
#> # A tibble: 3 x 2
#>     wei fee      
#>   <dbl> <chr>    
#> 1   179 horsebean
#> 2   160 horsebean
#> 3   136 horsebean
```

Read more in readxl's new [Column Names](https://readxl.tidyverse.org/articles/articles/column-names.html) article.

## Hello, is any one there?

readxl now displays a progress spinner in interactive sessions if it looks like the operation might take several seconds or more. This should provide some measure of reassurance when reading large sheets. This was accompanied by a rationalization of when readxl checks for user interrupts.

## Updated libxls

The last user-visible change is that all known `.xls` regressions have been fixed. The previous version, readxl v1.1.0, included some big updates in the embedded libxls library, which were overwhelmingly positive. But there were a few reports of `.xls` files that went from "readable" to "unreadable". To the best of my knowledge, those regressions have now all been addressed upstream and in readxl v1.2.0.

## Acknowledgements

Special thanks to Evan Miller for his recent work on libxls.

Thank you to the 47 contributors who made this release possible: [&#x0040;2005m](https://github.com/2005m), [&#x0040;ajdamico](https://github.com/ajdamico), [&#x0040;alfredojavier5](https://github.com/alfredojavier5), [&#x0040;antuki](https://github.com/antuki), [&#x0040;apreshill](https://github.com/apreshill), [&#x0040;awwsmm](https://github.com/awwsmm), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;berkorbay](https://github.com/berkorbay), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;breichholf](https://github.com/breichholf), [&#x0040;brianwdavis](https://github.com/brianwdavis), [&#x0040;chrowe](https://github.com/chrowe), [&#x0040;ddheart](https://github.com/ddheart), [&#x0040;doctsh](https://github.com/doctsh), [&#x0040;dominicshore](https://github.com/dominicshore), [&#x0040;Gillis](https://github.com/Gillis), [&#x0040;gorkang](https://github.com/gorkang), [&#x0040;gregdutkowski](https://github.com/gregdutkowski), [&#x0040;gregleleu](https://github.com/gregleleu), [&#x0040;hidekoji](https://github.com/hidekoji), [&#x0040;hlenka](https://github.com/hlenka), [&#x0040;hroptatyr](https://github.com/hroptatyr), [&#x0040;j6t](https://github.com/j6t), [&#x0040;jamesdalg](https://github.com/jamesdalg), [&#x0040;jameshunterbr](https://github.com/jameshunterbr), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jeroen](https://github.com/jeroen), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;KS2907](https://github.com/KS2907), [&#x0040;KyleHaynes](https://github.com/KyleHaynes), [&#x0040;llrs](https://github.com/llrs), [&#x0040;ltierney](https://github.com/ltierney), [&#x0040;LTLA](https://github.com/LTLA), [&#x0040;mcSamuelDataSci](https://github.com/mcSamuelDataSci), [&#x0040;mdekstrand](https://github.com/mdekstrand), [&#x0040;msgoussi](https://github.com/msgoussi), [&#x0040;N1h1l1sT](https://github.com/N1h1l1sT), [&#x0040;pm321](https://github.com/pm321), [&#x0040;ptoche](https://github.com/ptoche), [&#x0040;randallhelms](https://github.com/randallhelms), [&#x0040;rnuske](https://github.com/rnuske), [&#x0040;roualdes](https://github.com/roualdes), [&#x0040;rrohwer](https://github.com/rrohwer), [&#x0040;SebVen](https://github.com/SebVen), [&#x0040;siemersn](https://github.com/siemersn), [&#x0040;VincentGuyader](https://github.com/VincentGuyader), and [&#x0040;yurasmol](https://github.com/yurasmol).
