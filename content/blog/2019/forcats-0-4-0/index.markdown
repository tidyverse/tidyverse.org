---
title: forcats 0.4.0
author: Mara Averick
date: '2019-05-10'
slug: forcats-0-4-0
description: > 
  What's new in forcats 0.4.0?
categories:
  - package
tags:
  - forcats
  - tidyverse
photo:
  url: https://www.pexels.com/photo/close-up-photo-of-a-hand-holding-three-white-kittens-1643456/
  author: Peng Louis
---



We are pleased to announce that [forcats 0.4.0](http://forcats.tidyverse.org/) is now on CRAN. 
The forcats package provides a suite of useful tools that solve common problems with factors in R. This version benefited from the hard work of contributors new and old at our first [tidyverse dev day](https://www.tidyverse.org/articles/2018/11/tidyverse-developer-day-2019/).  For a complete set of changes, please see the [release notes](https://github.com/tidyverse/forcats/releases/tag/v0.4.0).

To install the latest version, run:


```r
install.packages("forcats")
```

As always, attach the package with:


```r
library(forcats)
```


## New functions

[`fct_cross()`](https://forcats.tidyverse.org/reference/fct_cross.html) creates a new factor containing the combined levels from two or more input factors, similar to `base::interaction()`.  


```r
fruit <- factor(c("apple", "kiwi", "apple", "apple"))
colour <- factor(c("green", "green", "red", "green"))
fct_cross(fruit, colour)
#> [1] apple:green kiwi:green  apple:red   apple:green
#> Levels: apple:green apple:red kiwi:green
```

[`fct_lump_min()`](https://forcats.tidyverse.org/reference/fct_lump.html) preserves levels that appear at least `min` times (can also be used with the `w` weighted argument).  
 

```r
x <- factor(letters[rpois(50, 3)])
fct_lump_min(x, min = 10)
#>  [1] Other b     Other b     Other Other Other b     Other Other b    
#> [12] Other Other Other b     Other b     Other Other b     b     Other
#> [23] Other Other b     b     Other Other Other Other Other b     Other
#> [34] Other Other b     Other Other Other Other Other Other Other Other
#> [45] Other b     Other b    
#> Levels: b Other
```


[`fct_match()`](https://forcats.tidyverse.org/reference/fct_match.html) tests for the presence of levels in a factor, providing a safer alternative to `%in%` by throwing an error when there are unexpected levels.
 

```r
table(fct_match(gss_cat$marital, c("Married", "Divorced")))
#> 
#> FALSE  TRUE 
#>  7983 13500
table(gss_cat$marital %in% c("Maried", "Davorced"))
#> 
#> FALSE 
#> 21483
table(fct_match(gss_cat$marital, c("Maried", "Davorced")))
#> Error: Levels not present in factor: "Maried", "Davorced"
```

## Other improvements

* [`fct_relevel()`](https://forcats.tidyverse.org/reference/fct_relevel.html) can now relevel factors using a function that is passed the current levels.  
 
    
    ```r
    f <- factor(c("a", "b", "c", "d"), levels = c("b", "c", "d", "a"))
    fct_relevel(f, sort)
    #> [1] a b c d
    #> Levels: a b c d
    fct_relevel(f, rev)
    #> [1] a b c d
    #> Levels: a d c b
    ```

* [`as_factor()`](https://forcats.tidyverse.org/dev/reference/as_factor.html) now has a numeric method which orders factors in numeric order, unlike the other methods which default to order of appearance.

    
    ```r
    y <- c("1.1", "11", "2.2", "22")
    as_factor(y)
    #> [1] 1.1 11  2.2 22 
    #> Levels: 1.1 11 2.2 22
    z <- as.numeric(y)
    as_factor(z)
    #> [1] 1.1 11  2.2 22 
    #> Levels: 1.1 2.2 11 22
    ```

* [`fct_inseq()`](https://forcats.tidyverse.org/dev/reference/fct_inorder.html) reorders labels numerically, when possible.

Thanks to Emily Robinson, forcats also has a new [introductory vignette](https://forcats.tidyverse.org/articles/forcats.html).

## Acknowledgements

We're grateful for the 35 people who contributed to this release: [&#x0040;ahaque-utd](https://github.com/ahaque-utd), [&#x0040;AmeliaMN](https://github.com/AmeliaMN), [&#x0040;ashiklom](https://github.com/ashiklom), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;brianwdavis](https://github.com/brianwdavis), [&#x0040;corybrunson](https://github.com/corybrunson), [&#x0040;dalewsteele](https://github.com/dalewsteele), [&#x0040;ewenharrison](https://github.com/ewenharrison), [&#x0040;grayskripko](https://github.com/grayskripko), [&#x0040;gtm19](https://github.com/gtm19), [&#x0040;hack-r](https://github.com/hack-r), [&#x0040;hadley](https://github.com/hadley), [&#x0040;huftis](https://github.com/huftis), [&#x0040;isteves](https://github.com/isteves), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jonocarroll](https://github.com/jonocarroll), [&#x0040;jrosen48](https://github.com/jrosen48), [&#x0040;jthomasmock](https://github.com/jthomasmock), [&#x0040;kbodwin](https://github.com/kbodwin), [&#x0040;mdjeric](https://github.com/mdjeric), [&#x0040;orchid00](https://github.com/orchid00), [&#x0040;richierocks](https://github.com/richierocks), [&#x0040;robinsones](https://github.com/robinsones), [&#x0040;rosedu1](https://github.com/rosedu1), [&#x0040;RoyalTS](https://github.com/RoyalTS), [&#x0040;russHyde](https://github.com/russHyde), [&#x0040;Ryo-N7](https://github.com/Ryo-N7), [&#x0040;s-fleck](https://github.com/s-fleck), [&#x0040;seaaan](https://github.com/seaaan), [&#x0040;spedygiorgio](https://github.com/spedygiorgio), [&#x0040;tslumley](https://github.com/tslumley), [&#x0040;xuhuizhang](https://github.com/xuhuizhang), [&#x0040;zhiiiyang](https://github.com/zhiiiyang), and [&#x0040;zx8754](https://github.com/zx8754).

