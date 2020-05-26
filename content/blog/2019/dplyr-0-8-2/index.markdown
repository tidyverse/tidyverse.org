---
title: dplyr 0.8.2
slug: dplyr-0-8-2
author: Romain François
description: >
  dplyr 0.8.2 is now on CRAN.
date: '2019-06-29'
categories: [package]
tags:
  - dplyr
  - tidyverse
photo:
  url: https://unsplash.com/photos/xFTNsGW1isI
  author: Joanna Kosinska
---



## Introduction

We're delighted to announce the release of dplyr 0.8.2 on CRAN 🍉 !

This is a minor maintenance release in the `0.8.*` series, addressing a collection of 
issues since the [0.8.1](https://www.tidyverse.org/articles/2019/05/dplyr-0-8-1/) and 
[0.8.0](https://www.tidyverse.org/articles/2019/02/dplyr-0-8-0/) versions.

## top_n() and top_frac()

[top_n()](https://dplyr.tidyverse.org/reference/top_n.html) has been around for a long time in 
[dplyr](https://dplyr.tidyverse.org/index.html), as a convenient wrapper around 
[filter()](https://dplyr.tidyverse.org/articles/dplyr.html?q=filter)
and [min_rank()](https://dplyr.tidyverse.org/reference/ranking.html), 
to select top (or bottom) entries in each group of a tibble. 

In this release, [top_n()](https://dplyr.tidyverse.org/reference/top_n.html) is no longer 
limited to a constant number of entries per group, its `n` argument is now quoted
to be evaluated later in the context of the group. 

Here are the top half countries, i.e. `n() / 2`, in terms of life expectancy in 2007. 


```r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
gapminder::gapminder %>% 
  filter(year == 2007) %>% 
  group_by(continent) %>% 
  top_n(n() / 2, lifeExp)
#> # A tibble: 70 x 6
#> # Groups:   continent [5]
#>    country   continent  year lifeExp        pop gdpPercap
#>    <fct>     <fct>     <int>   <dbl>      <int>     <dbl>
#>  1 Algeria   Africa     2007    72.3   33333216     6223.
#>  2 Argentina Americas   2007    75.3   40301927    12779.
#>  3 Australia Oceania    2007    81.2   20434176    34435.
#>  4 Austria   Europe     2007    79.8    8199783    36126.
#>  5 Bahrain   Asia       2007    75.6     708573    29796.
#>  6 Belgium   Europe     2007    79.4   10392226    33693.
#>  7 Benin     Africa     2007    56.7    8078314     1441.
#>  8 Canada    Americas   2007    80.7   33390141    36319.
#>  9 Chile     Americas   2007    78.6   16284741    13172.
#> 10 China     Asia       2007    73.0 1318683096     4959.
#> # … with 60 more rows
```

[top_frac()](https://dplyr.tidyverse.org/reference/top_n.html) is new convenience shortcut for 
the top n percent, i.e. 


```r
gapminder::gapminder %>% 
  filter(year == 2007) %>% 
  group_by(continent) %>% 
  top_frac(0.5, lifeExp)
#> # A tibble: 70 x 6
#> # Groups:   continent [5]
#>    country   continent  year lifeExp        pop gdpPercap
#>    <fct>     <fct>     <int>   <dbl>      <int>     <dbl>
#>  1 Algeria   Africa     2007    72.3   33333216     6223.
#>  2 Argentina Americas   2007    75.3   40301927    12779.
#>  3 Australia Oceania    2007    81.2   20434176    34435.
#>  4 Austria   Europe     2007    79.8    8199783    36126.
#>  5 Bahrain   Asia       2007    75.6     708573    29796.
#>  6 Belgium   Europe     2007    79.4   10392226    33693.
#>  7 Benin     Africa     2007    56.7    8078314     1441.
#>  8 Canada    Americas   2007    80.7   33390141    36319.
#>  9 Chile     Americas   2007    78.6   16284741    13172.
#> 10 China     Asia       2007    73.0 1318683096     4959.
#> # … with 60 more rows
```

## tbl_vars() and group_cols()

[tbl_vars()](https://dplyr.tidyverse.org/reference/tbl_vars.html) now returns a `dplyr_sel_vars` 
object that keeps track of the grouping variables. This information powers 
[group_cols()](https://dplyr.tidyverse.org/reference/group_cols.html), which can now be used
in every function that uses tidy selection of columns. 

Functions in the tidyverse and beyond may start to use the 
[tbl_vars()](https://dplyr.tidyverse.org/reference/tbl_vars.html)/[group_cols()](https://dplyr.tidyverse.org/reference/group_cols.html) duo, 
starting from [tidyr](https://tidyr.tidyverse.org) and this [pull request](https://github.com/tidyverse/tidyr/pull/668)


```r
# pak::pkg_install("tidyverse/tidyr#668")

iris %>%
  group_by(Species) %>% 
  tidyr::gather("flower_att", "measurement", -group_cols())
#> # A tibble: 600 x 3
#> # Groups:   Species [3]
#>    Species flower_att   measurement
#>    <fct>   <chr>              <dbl>
#>  1 setosa  Sepal.Length         5.1
#>  2 setosa  Sepal.Length         4.9
#>  3 setosa  Sepal.Length         4.7
#>  4 setosa  Sepal.Length         4.6
#>  5 setosa  Sepal.Length         5  
#>  6 setosa  Sepal.Length         5.4
#>  7 setosa  Sepal.Length         4.6
#>  8 setosa  Sepal.Length         5  
#>  9 setosa  Sepal.Length         4.4
#> 10 setosa  Sepal.Length         4.9
#> # … with 590 more rows
```

## group_split(), group_map(), group_modify()

[group_split()](https://dplyr.tidyverse.org/reference/group_split.html) always keeps 
a `ptype` attribute to track the prototype of the splits. 


```r
mtcars %>%
  group_by(cyl) %>%
  filter(hp < 0) %>% 
  group_split()
#> list()
#> attr(,"ptype")
#> # A tibble: 0 x 11
#> # … with 11 variables: mpg <dbl>, cyl <dbl>, disp <dbl>, hp <dbl>,
#> #   drat <dbl>, wt <dbl>, qsec <dbl>, vs <dbl>, am <dbl>, gear <dbl>,
#> #   carb <dbl>
```

[group_map()](https://dplyr.tidyverse.org/reference/group_map.html) and [group_modify()](https://dplyr.tidyverse.org/reference/group_map.html) 
benefit from this in the edge case where there are no groups. 


```r
mtcars %>%
  group_by(cyl) %>%
  filter(hp < 0) %>% 
  group_map(~.x)
#> list()
#> attr(,"ptype")
#> # A tibble: 0 x 10
#> # … with 10 variables: mpg <dbl>, disp <dbl>, hp <dbl>, drat <dbl>,
#> #   wt <dbl>, qsec <dbl>, vs <dbl>, am <dbl>, gear <dbl>, carb <dbl>

mtcars %>%
  group_by(cyl) %>%
  filter(hp < 0) %>% 
  group_modify(~.x)
#> # A tibble: 0 x 11
#> # Groups:   cyl [0]
#> # … with 11 variables: cyl <dbl>, mpg <dbl>, disp <dbl>, hp <dbl>,
#> #   drat <dbl>, wt <dbl>, qsec <dbl>, vs <dbl>, am <dbl>, gear <dbl>,
#> #   carb <dbl>
```

## Thanks

Thanks to all contributors for this release.

[&#x0040;abirasathiy](https://github.com/abirasathiy), [&#x0040;ajkroeg](https://github.com/ajkroeg), [&#x0040;alejandroschuler](https://github.com/alejandroschuler), [&#x0040;anuj2054](https://github.com/anuj2054), [&#x0040;arider2](https://github.com/arider2), [&#x0040;arielfuentes](https://github.com/arielfuentes), [&#x0040;artidata](https://github.com/artidata), [&#x0040;BenPVD](https://github.com/BenPVD), [&#x0040;bkmontgom](https://github.com/bkmontgom), [&#x0040;brodieG](https://github.com/brodieG), [&#x0040;cderv](https://github.com/cderv), [&#x0040;clanker](https://github.com/clanker), [&#x0040;clemenshug](https://github.com/clemenshug), [&#x0040;CSheehan1](https://github.com/CSheehan1), [&#x0040;danielecook](https://github.com/danielecook), [&#x0040;dannyparsons](https://github.com/dannyparsons), [&#x0040;daskandalis](https://github.com/daskandalis), [&#x0040;davidbaniadam](https://github.com/davidbaniadam), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;deliciouslytyped](https://github.com/deliciouslytyped), [&#x0040;earowang](https://github.com/earowang), [&#x0040;fkatharina](https://github.com/fkatharina), [&#x0040;hadley](https://github.com/hadley), [&#x0040;Hardervidertsie](https://github.com/Hardervidertsie), [&#x0040;iago-pssjd](https://github.com/iago-pssjd), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;jackdolgin](https://github.com/jackdolgin), [&#x0040;jangorecki](https://github.com/jangorecki), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jjesusfilho](https://github.com/jjesusfilho), [&#x0040;jonjhitchcock](https://github.com/jonjhitchcock), [&#x0040;jxu](https://github.com/jxu), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;laresbernardo](https://github.com/laresbernardo), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;LukeGoodsell](https://github.com/LukeGoodsell), [&#x0040;madmark81](https://github.com/madmark81), [&#x0040;MarkusBerroth](https://github.com/MarkusBerroth), [&#x0040;matheus-donato](https://github.com/matheus-donato), [&#x0040;mattfidler](https://github.com/mattfidler), [&#x0040;MatthieuStigler](https://github.com/MatthieuStigler), [&#x0040;md0u80c9](https://github.com/md0u80c9), [&#x0040;michaelhogersosis](https://github.com/michaelhogersosis), [&#x0040;MikeJohnPage](https://github.com/MikeJohnPage), [&#x0040;MJL9588](https://github.com/MJL9588), [&#x0040;moodymudskipper](https://github.com/moodymudskipper), [&#x0040;mwillumz](https://github.com/mwillumz), [&#x0040;Nelson-Gon](https://github.com/Nelson-Gon), [&#x0040;qdread](https://github.com/qdread), [&#x0040;randomgambit](https://github.com/randomgambit), [&#x0040;rcorty](https://github.com/rcorty), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;romatik](https://github.com/romatik), [&#x0040;spressi](https://github.com/spressi), [&#x0040;sstoeckl](https://github.com/sstoeckl), [&#x0040;stephLH](https://github.com/stephLH), [&#x0040;urskalbitzer](https://github.com/urskalbitzer), [&#x0040;vpanfilov](https://github.com/vpanfilov), and [&#x0040;ZahraEconomist](https://github.com/ZahraEconomist).
