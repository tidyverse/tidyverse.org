---
title: dplyr 0.8.1
slug: dplyr-0-8-1
author: Romain François
description: >
    dplyr 0.8.1 is now on CRAN.
date: '2019-05-17'
categories: [package]
tags:
  - dplyr
  - tidyverse
tags:
  - dplyr
photo:
  url: https://unsplash.com/photos/BiZ-_6kNjbI
  author: Sophie Elvis
---



## Introduction

We're delighted to announce the release of dplyr 0.8.1 on CRAN 🎉 !

This is a minor release that address follow ups from the community after the 
release of the [0.8.0 version](https://www.tidyverse.org/articles/2019/02/dplyr-0-8-0/). 

## group_map() and group_modify()

Shortly after the release of 0.8.0, we were notified by several members of the 
community that `group_map()` was great, except it didn't do what they had expected 😬. 

Because the function was (and still is) marked as experimental, we allowed ourselves to 
rectify the situation: 

 - The name `group_map()` is now used for iterating on groups of grouped tibbles, 
   characterised by `.x` and `.y` as before, but making no assumptions about the return 
   type of each operation and combining the results in a *list*. We can see this as 
   iterating, in the [purrr::map()](https://purrr.tidyverse.org/reference/map.html) 
   sense on the groups. 


```r
library(dplyr, warn.conflicts = FALSE)

# a list of vectors
iris %>%
  group_by(Species) %>%
  group_map(~ quantile(.x$Petal.Length, probs = c(0.25, 0.5, 0.75)))
#> [[1]]
#>   25%   50%   75% 
#> 1.400 1.500 1.575 
#> 
#> [[2]]
#>  25%  50%  75% 
#> 4.00 4.35 4.60 
#> 
#> [[3]]
#>   25%   50%   75% 
#> 5.100 5.550 5.875
```

 - The behaviour we previously had was renamed `group_modify()` to loosely echo 
   [purrr::modify()](https://purrr.tidyverse.org/reference/modify.html). In particular, 
   `group_modify()` always returns a grouped tibble, which combines the tibbles returned
   by evaluating each operation with a reconstructed grouping structure. 
 

```r
# to use group_modify() the lambda must return a data frame
iris %>%
  group_by(Species) %>%
  group_modify(~ {
     quantile(.x$Petal.Length, probs = c(0.25, 0.5, 0.75)) %>%
     tibble::enframe(name = "prob", value = "quantile")
  })
#> # A tibble: 9 x 3
#> # Groups:   Species [3]
#>   Species    prob  quantile
#>   <fct>      <chr>    <dbl>
#> 1 setosa     25%       1.4 
#> 2 setosa     50%       1.5 
#> 3 setosa     75%       1.58
#> 4 versicolor 25%       4   
#> 5 versicolor 50%       4.35
#> 6 versicolor 75%       4.6 
#> 7 virginica  25%       5.1 
#> 8 virginica  50%       5.55
#> 9 virginica  75%       5.88
```

## Attention to details in column wise functions

As we are phasing `funs()` out and prefer use of `purrr`-style lambda functions
in column wise verbs, we missed a few subtleties. 

Specifically, lambdas can now refer to: 

- local variables (from the scope): 


```r
to_inch <- function(data, ...) {
  # the local variable `inch` can be used in the lambda
  inch <- 0.393701
  data %>% 
    mutate_at(vars(...), ~ . * inch)
}
iris %>% 
  as_tibble() %>% 
  to_inch(-Species)
#> # A tibble: 150 x 5
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1         2.01        1.38        0.551      0.0787 setosa 
#>  2         1.93        1.18        0.551      0.0787 setosa 
#>  3         1.85        1.26        0.512      0.0787 setosa 
#>  4         1.81        1.22        0.591      0.0787 setosa 
#>  5         1.97        1.42        0.551      0.0787 setosa 
#>  6         2.13        1.54        0.669      0.157  setosa 
#>  7         1.81        1.34        0.551      0.118  setosa 
#>  8         1.97        1.34        0.591      0.0787 setosa 
#>  9         1.73        1.14        0.551      0.0787 setosa 
#> 10         1.93        1.22        0.591      0.0394 setosa 
#> # … with 140 more rows
```

- other columns of the data (from the data mask):


```r
iris %>% 
  as_tibble() %>% 
  mutate_at(vars(starts_with("Sepal")), ~ . / Petal.Width)
#> # A tibble: 150 x 5
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>           <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#>  1         25.5       17.5           1.4         0.2 setosa 
#>  2         24.5       15             1.4         0.2 setosa 
#>  3         23.5       16             1.3         0.2 setosa 
#>  4         23.0       15.5           1.5         0.2 setosa 
#>  5         25         18             1.4         0.2 setosa 
#>  6         13.5        9.75          1.7         0.4 setosa 
#>  7         15.3       11.3           1.4         0.3 setosa 
#>  8         25         17             1.5         0.2 setosa 
#>  9         22         14.5           1.4         0.2 setosa 
#> 10         49         31             1.5         0.1 setosa 
#> # … with 140 more rows
```

## Thanks

Thanks to all contributors for this release. 

[&#x0040;abalter](https://github.com/abalter), [&#x0040;ambevill](https://github.com/ambevill), [&#x0040;amitusa17](https://github.com/amitusa17), [&#x0040;AntoineHffmnn](https://github.com/AntoineHffmnn), [&#x0040;anuj2054](https://github.com/anuj2054), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;behrman](https://github.com/behrman), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;burchill](https://github.com/burchill), [&#x0040;cgrandin](https://github.com/cgrandin), [&#x0040;clemenshug](https://github.com/clemenshug), [&#x0040;codetrainee](https://github.com/codetrainee), [&#x0040;ColinFay](https://github.com/ColinFay), [&#x0040;dan-reznik](https://github.com/dan-reznik), [&#x0040;davidsjoberg](https://github.com/davidsjoberg), [&#x0040;DesiQuintans](https://github.com/DesiQuintans), [&#x0040;dirkschumacher](https://github.com/dirkschumacher), [&#x0040;earowang](https://github.com/earowang), [&#x0040;echasnovski](https://github.com/echasnovski), [&#x0040;eipi10](https://github.com/eipi10), [&#x0040;grabear](https://github.com/grabear), [&#x0040;grandtiger](https://github.com/grandtiger), [&#x0040;gregorp](https://github.com/gregorp), [&#x0040;hadley](https://github.com/hadley), [&#x0040;hanyroze](https://github.com/hanyroze), [&#x0040;hidekoji](https://github.com/hidekoji), [&#x0040;huftis](https://github.com/huftis), [&#x0040;iago-pssjd](https://github.com/iago-pssjd), [&#x0040;javierluraschi](https://github.com/javierluraschi), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jgellar](https://github.com/jgellar), [&#x0040;jhrcook](https://github.com/jhrcook), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;joel23888](https://github.com/joel23888), [&#x0040;JohnMount](https://github.com/JohnMount), [&#x0040;johnmous](https://github.com/johnmous), [&#x0040;jonathan-g](https://github.com/jonathan-g), [&#x0040;jwbeck97](https://github.com/jwbeck97), [&#x0040;jzadra](https://github.com/jzadra), [&#x0040;karimn](https://github.com/karimn), [&#x0040;kendonB](https://github.com/kendonB), [&#x0040;koncina](https://github.com/koncina), [&#x0040;kperkins](https://github.com/kperkins), [&#x0040;kputschko](https://github.com/kputschko), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;kyzphong](https://github.com/kyzphong), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;llrs](https://github.com/llrs), [&#x0040;mariodejung](https://github.com/mariodejung), [&#x0040;MichaelAdolph](https://github.com/MichaelAdolph), [&#x0040;michaelwhammer](https://github.com/michaelwhammer), [&#x0040;MilesMcBain](https://github.com/MilesMcBain), [&#x0040;mjherold](https://github.com/mjherold), [&#x0040;moodymudskipper](https://github.com/moodymudskipper), [&#x0040;msberends](https://github.com/msberends), [&#x0040;mvkorpel](https://github.com/mvkorpel), [&#x0040;nathancday](https://github.com/nathancday), [&#x0040;nicokuz](https://github.com/nicokuz), [&#x0040;nolistic](https://github.com/nolistic), [&#x0040;oscci](https://github.com/oscci), [&#x0040;paulponcet](https://github.com/paulponcet), [&#x0040;PhilippRuchser](https://github.com/PhilippRuchser), [&#x0040;philstraforelli](https://github.com/philstraforelli), [&#x0040;psychometrician](https://github.com/psychometrician), [&#x0040;Ranonymous](https://github.com/Ranonymous), [&#x0040;rinebob](https://github.com/rinebob), [&#x0040;romagnolid](https://github.com/romagnolid), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;rvg02010](https://github.com/rvg02010), [&#x0040;slyrus](https://github.com/slyrus), [&#x0040;snp](https://github.com/snp), [&#x0040;sowla](https://github.com/sowla), [&#x0040;ThiAmm](https://github.com/ThiAmm), [&#x0040;thothal](https://github.com/thothal), [&#x0040;wfmackey](https://github.com/wfmackey), [&#x0040;will458](https://github.com/will458), [&#x0040;wkdavis](https://github.com/wkdavis), [&#x0040;yutannihilation](https://github.com/yutannihilation), [&#x0040;ZahraEconomist](https://github.com/ZahraEconomist), and [&#x0040;zooman](https://github.com/zooman).
