---
output: hugodown::hugo_document

slug: haven-2-2-0
title: haven 2.2.0
date: 2020-05-27
author: Hadley Wickham
description: >
    haven now uses vctrs which means labelled classes will be preserved in
    tidyr and dplyr operation.

photo:
  url: https://unsplash.com/photos/45GmTCcW8Hk
  author: Sergey Nikolaev

categories: [package] 
tags: [haven]
rmd_hash: efb089f53fbbab4f

---

We're tickled pink to announce the release of [haven](https://haven.tidyverse.org) 2.2.0. haven allows you to read and write SAS, SPSS, and Stata data formats from R, thanks to the wonderful [ReadStat](https://github.com/WizardMac/ReadStat) C library written by [Evan Miller](https://www.evanmiller.org/).

You can install haven from CRAN with:

``` r
install.packages("haven")
```

This release is mainly in preparation for dplyr 1.0.0. It includes improved [vctrs support](https://www.tidyverse.org/blog/2020/04/dplyr-1-0-0-and-vctrs/) for the `labelled()` class that haven uses to represent labelled vectors that come from SAS, Stata, and SPSS. This is not terribly exciting, but it means that the labelled class is now preserved by every dplyr operation where it makes sense:

``` r
library(haven)
library(dplyr, warn.conflicts = FALSE)

x <- labelled(sample(5), c("bad" = 1, "good" = 5), "scores")
df <- tibble(x, y = letters[c(1, 3, 5, 7, 9)])
df
#> # A tibble: 5 x 2
#>           x y    
#>   <int+lbl> <chr>
#> 1  5 [good] a    
#> 2  3        c    
#> 3  4        e    
#> 4  1 [bad]  g    
#> 5  2        i

df %>% arrange(x)
#> # A tibble: 5 x 2
#>           x y    
#>   <int+lbl> <chr>
#> 1  1 [bad]  g    
#> 2  2        i    
#> 3  3        c    
#> 4  4        e    
#> 5  5 [good] a
df %>% filter(y %in% c("a", "c"))
#> # A tibble: 2 x 2
#>           x y    
#>   <int+lbl> <chr>
#> 1  5 [good] a    
#> 2  3        c

bind_rows(df, df)
#> # A tibble: 10 x 2
#>            x y    
#>    <int+lbl> <chr>
#>  1  5 [good] a    
#>  2  3        c    
#>  3  4        e    
#>  4  1 [bad]  g    
#>  5  2        i    
#>  6  5 [good] a    
#>  7  3        c    
#>  8  4        e    
#>  9  1 [bad]  g    
#> 10  2        i

df2 <- tibble(y = letters[1:10])
df2 %>% left_join(df)
#> Joining, by = "y"
#> # A tibble: 10 x 2
#>    y             x
#>    <chr> <int+lbl>
#>  1 a      5 [good]
#>  2 b     NA       
#>  3 c      3       
#>  4 d     NA       
#>  5 e      4       
#>  6 f     NA       
#>  7 g      1 [bad] 
#>  8 h     NA       
#>  9 i      2       
#> 10 j     NA
```

Acknowledgements
----------------

As always thanks to the GitHub community who helped make this release happen! [@180312allison](https://github.com/180312allison), [@armenic](https://github.com/armenic), [@batpigandme](https://github.com/batpigandme), [@beckerbenj](https://github.com/beckerbenj), [@bergen288](https://github.com/bergen288), [@courtiol](https://github.com/courtiol), [@deschen1](https://github.com/deschen1), [@edvbb](https://github.com/edvbb), [@Ghanshyamsavaliya](https://github.com/Ghanshyamsavaliya), [@hadley](https://github.com/hadley), [@JackLandry](https://github.com/JackLandry), [@Jagadeeshkb](https://github.com/Jagadeeshkb), [@jimhester](https://github.com/jimhester), [@kurt-vd](https://github.com/kurt-vd), [@larmarange](https://github.com/larmarange), [@lionel-](https://github.com/lionel-), [@mayer79](https://github.com/mayer79), [@mikmart](https://github.com/mikmart), [@mitchelloharawild](https://github.com/mitchelloharawild), [@omsai](https://github.com/omsai), [@pdbailey0](https://github.com/pdbailey0), [@randrescastaneda](https://github.com/randrescastaneda), [@richarddmorey](https://github.com/richarddmorey), [@romainfrancois](https://github.com/romainfrancois), [@rubenarslan](https://github.com/rubenarslan), [@sda030](https://github.com/sda030), [@Sdurier](https://github.com/Sdurier), and [@tobwen](https://github.com/tobwen).
