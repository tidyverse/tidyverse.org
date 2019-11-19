---
title: tidyr 1.0.0
author: Hadley Wickham
date: '2019-09-13'
slug: tidyr-1-0-0
categories:
  - package
tags:
  - tidyr
  - tidyverse
photo:
  url: https://unsplash.com/photos/0yL6nXhn0pI
  author: Victor Garcia
---



I'm very excited to announce the release of [tidyr 1.0.0](https://tidyr.tidyverse.org)! tidyr provides a set of tools for transforming data frames to and from [tidy data](https://tidyr.tidyverse.org/articles/tidy-data.html), where each variable is a column and each observation is a row. Tidy data is a convention for matching the semantics and structure of your data that makes using the rest of the tidyverse (and many other R packages) much easier. 

Install tidyr with:


```r
install.packages("tidyr")
```

As you might guess from the version number, this is a major release, and the 1.0.0 moniker indicates that I'm finally happy with the overall interface of the package. This has been a long time coming: it's five years since the first tidyr release, nine years since the first reshape2 release, and fourteen years since the first reshape release! 

This blog post summarises the four major changes to the package:

* New `pivot_longer()` and `pivot_wider()` provide improved tools for reshaping,
  superceding `spread()` and `gather()`. The new functions are substantially 
  more powerful, thanks to ideas from the 
  [data.table](https://CRAN.R-project.org/package=data.table) and
  [cdata](https://CRAN.R-project.org/package=cdata) packages, and I'm 
  confident that you'll find them easier to use and remember than their 
  predecessors. 
  
* New `unnest_auto()`, `unnest_longer()`, `unnest_wider()`, and `hoist()` 
  provide new tools for rectangling, converting deeply nested lists into tidy
  data frames.
  
* `nest()` and `unnest()` have been changed to match an emerging principle for 
  the design of  `...` interfaces. Four new functions (`pack()`/`unpack()`, and
  `chop()`/`unchop()`) reveal that nesting is the combination of two simpler 
  steps.
  
* New `expand_grid()`, a variant of `base::expand.grid()`. This is a useful 
  function to know about, but also serves as a good reason to discuss the 
  important role that [vctrs](http://vctrs.r-lib.org/) plays behind the scenes. 
  You shouldn't ever _have_ to learn about vctrs, but it brings improvements to 
  consistency and performance. 

As well as implementing the new features, I've spent considerable time on the documentation, including four major new vignettes:

* [`vignette("pivot")`](https://tidyr.tidyverse.org/articles/pivot.html), 
  [`vignette("rectangle")`](https://tidyr.tidyverse.org/articles/rectangle.html), 
  and [`vignette("nest")`](https://tidyr.tidyverse.org/articles/nest.html) 
  provide detailed documentation and case studies of pivotting, rectangling, 
  and nesting respectively.

* [`vignette("in-packages")`](https://tidyr.tidyverse.org/articles/in-packages.html)
  provides best practices for using tidyr inside
  another package, and detailed advice on working with multiple 
  versions of tidyr if an interface change has affected your package.

You can see a list of all the other minor bug fixes and improvements in the [release notes](https://tidyr.tidyverse.org/news/index.html#tidyr-1-0-0). I strongly recommend reading the complete release notes if you're a package developer.


```r
library(tidyr)
library(dplyr)
```

## Pivoting

New [`pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html) and [`pivot_wider()`](https://tidyr.tidyverse.org/reference/pivot_wider.html) provide modern alternatives to `spread()` and `gather()`. They have been carefully redesigned to be easier to learn and remember, and include many new features. `spread()` and `gather()` won't go away, but they've been retired which means that they're no longer under active development.

The best place to learn about `pivot_longer()` and `pivot_wider()` is [`vignette("pivot")`](https://tidyr.tidyverse.org/articles/pivot.html), or by watching my presentation to the [Vienna R users group](https://www.youtube.com/watch?v=D48JHU4llkk). Here I'll quickly show off a few of the coolest new features:

*   `pivot_longer()` can now separate column names into multiple variables in 
    a single step. For example, take the `who` dataset which has column names
    that look like `new_{diagnosis}_{gender}{age}`:
    
    
    ```r
    names(who)
    #>  [1] "country"      "iso2"         "iso3"         "year"        
    #>  [5] "new_sp_m014"  "new_sp_m1524" "new_sp_m2534" "new_sp_m3544"
    #>  [9] "new_sp_m4554" "new_sp_m5564" "new_sp_m65"   "new_sp_f014" 
    #> [13] "new_sp_f1524" "new_sp_f2534" "new_sp_f3544" "new_sp_f4554"
    #> [17] "new_sp_f5564" "new_sp_f65"   "new_sn_m014"  "new_sn_m1524"
    #> [21] "new_sn_m2534" "new_sn_m3544" "new_sn_m4554" "new_sn_m5564"
    #> [25] "new_sn_m65"   "new_sn_f014"  "new_sn_f1524" "new_sn_f2534"
    #> [29] "new_sn_f3544" "new_sn_f4554" "new_sn_f5564" "new_sn_f65"  
    #> [33] "new_ep_m014"  "new_ep_m1524" "new_ep_m2534" "new_ep_m3544"
    #> [37] "new_ep_m4554" "new_ep_m5564" "new_ep_m65"   "new_ep_f014" 
    #> [41] "new_ep_f1524" "new_ep_f2534" "new_ep_f3544" "new_ep_f4554"
    #> [45] "new_ep_f5564" "new_ep_f65"   "newrel_m014"  "newrel_m1524"
    #> [49] "newrel_m2534" "newrel_m3544" "newrel_m4554" "newrel_m5564"
    #> [53] "newrel_m65"   "newrel_f014"  "newrel_f1524" "newrel_f2534"
    #> [57] "newrel_f3544" "newrel_f4554" "newrel_f5564" "newrel_f65"
    ```
    
    You can now tease apart the variable names in a single step 
    (i.e. without [`separate()`](https://tidyr.tidyverse.org/reference/separate.html)))
    by supplying a vector of variable names to `names_to` and a regular 
    expression to `names_pattern` (simpler cases might only need `names_sep`):

    
    ```r
    who %>% pivot_longer(
      cols = new_sp_m014:newrel_f65,
      names_to = c("diagnosis", "gender", "age"), 
      names_pattern = "new_?(.*)_(.)(.*)",
      values_to = "count",
      values_drop_na = TRUE
    )
    #> # A tibble: 76,046 x 8
    #>   country     iso2  iso3   year diagnosis gender age   count
    #>   <chr>       <chr> <chr> <int> <chr>     <chr>  <chr> <int>
    #> 1 Afghanistan AF    AFG    1997 sp        m      014       0
    #> 2 Afghanistan AF    AFG    1997 sp        m      1524     10
    #> 3 Afghanistan AF    AFG    1997 sp        m      2534      6
    #> 4 Afghanistan AF    AFG    1997 sp        m      3544      3
    #> 5 Afghanistan AF    AFG    1997 sp        m      4554      5
    #> 6 Afghanistan AF    AFG    1997 sp        m      5564      2
    #> # … with 7.604e+04 more rows
    ```

*   `pivot_longer()` can now work with rows that contain multiple observations
    (this feature was inspired by data.table's `dcast()` method). For example,
    take the base `anscombe` dataset. Each row consists of four pairs of
    `x` and `y` measurements:
    
    
    ```r
    head(anscombe)
    #>   x1 x2 x3 x4   y1   y2    y3   y4
    #> 1 10 10 10  8 8.04 9.14  7.46 6.58
    #> 2  8  8  8  8 6.95 8.14  6.77 5.76
    #> 3 13 13 13  8 7.58 8.74 12.74 7.71
    #> 4  9  9  9  8 8.81 8.77  7.11 8.84
    #> 5 11 11 11  8 8.33 9.26  7.81 8.47
    #> 6 14 14 14  8 9.96 8.10  8.84 7.04
    ```
  
    We can now tidy this in a single step by using the special `.value` 
    variable name:
    
    
    ```r
    anscombe %>% 
      pivot_longer(
        everything(),
        names_to = c(".value", "set"),
        names_pattern = "(.)(.)"
      ) %>% 
      as_tibble()
    #> # A tibble: 44 x 3
    #>   set       x     y
    #>   <chr> <dbl> <dbl>
    #> 1 1        10  8.04
    #> 2 2        10  9.14
    #> 3 3        10  7.46
    #> 4 4         8  6.58
    #> 5 1         8  6.95
    #> 6 2         8  8.14
    #> # … with 38 more rows
    ```
    
*   `pivot_wider()` can now do simple aggregations (`reshape2::dcast()` fans 
    rejoice!). For example, take the base `warpbreaks` dataset (converted to a 
    tibble to print more compactly):    

    
    ```r
    warpbreaks <- warpbreaks %>% as_tibble() %>% select(wool, tension, breaks)
    warpbreaks
    #> # A tibble: 54 x 3
    #>   wool  tension breaks
    #>   <fct> <fct>    <dbl>
    #> 1 A     L           26
    #> 2 A     L           30
    #> 3 A     L           54
    #> 4 A     L           25
    #> 5 A     L           70
    #> 6 A     L           52
    #> # … with 48 more rows
    ```
    
    This is a designed experiment with nine replicates for every combination of
    `wool` (`A` and `B`) and `tension` (`L`, `M`, `H`). If we attempt to pivot 
    the levels of `wool` into the columns, we get a warning and the output
    contains list-columns:
    
    
    ```r
    warpbreaks %>% pivot_wider(names_from = wool, values_from = breaks)
    #> Warning: Values in `breaks` are not uniquely identified; output will contain list-cols.
    #> * Use `values_fn = list(breaks = list)` to suppress this warning.
    #> * Use `values_fn = list(breaks = length)` to identify where the duplicates arise
    #> * Use `values_fn = list(breaks = summary_fun)` to summarise duplicates
    #> # A tibble: 3 x 3
    #>   tension           A           B
    #>   <fct>   <list<dbl>> <list<dbl>>
    #> 1 L               [9]         [9]
    #> 2 M               [9]         [9]
    #> 3 H               [9]         [9]
    ```

    You can now summarise the duplicates with the `values_fn` argument:
    
    
    ```r
    warpbreaks %>% 
      pivot_wider(
        names_from = wool, 
        values_from = breaks,
        values_fn = list(breaks = mean)
      )
    #> # A tibble: 3 x 3
    #>   tension     A     B
    #>   <fct>   <dbl> <dbl>
    #> 1 L        44.6  28.2
    #> 2 M        24    28.8
    #> 3 H        24.6  18.8
    ```

Learn the full details and see many more examples in [`vignette("pivot")`](http://tidyr.tidyverse.org/articles/pivot.html).

## Rectangling

Rectangling is the art and craft of taking a deeply nested list (often sourced from wild-caught JSON or XML) and taming it into a tidy data set of rows and columns. tidyr 1.0.0 provides four new functions to aid rectangling:

* `unnest_longer()` takes each element of a list-column and makes a new row.
* `unnest_wider()` takes each element of a list-column and makes a new column.
* `unnest_auto()` uses some heuristics to guess whether you want 
  `unnest_longer()` or `unnest_wider()`.
* `hoist()` is similar to `unnest_wider()` but only plucks out selected
  components, and can reach down multiple levels.

To see them in action, take this small sample from `repurrrsive::got_chars`. It contains data about three characters from the Game of Thrones:


```r
characters <- list(
  list(
    name = "Theon Greyjoy",
    aliases = c("Prince of Fools", "Theon Turncloak", "Theon Kinslayer"),
    alive = TRUE
  ),
  list(
    name = "Tyrion Lannister",
    aliases = c("The Imp", "Halfman", "Giant of Lannister"),
    alive = TRUE
  ),
  list(
    name = "Arys Oakheart",
    alive = FALSE
  )
)
```

To work with the new tidyr rectangling tools, we first put the list into a data frame, creating a list-column:


```r
got <- tibble(character = characters)
got
#> # A tibble: 3 x 1
#>   character       
#>   <list>          
#> 1 <named list [3]>
#> 2 <named list [3]>
#> 3 <named list [2]>
```

We can then use `unnest_wider()` to make each element of that list into a column:


```r
got %>% 
  unnest_wider(character)
#> # A tibble: 3 x 3
#>   name             aliases   alive
#>   <chr>            <list>    <lgl>
#> 1 Theon Greyjoy    <chr [3]> TRUE 
#> 2 Tyrion Lannister <chr [3]> TRUE 
#> 3 Arys Oakheart    <???>     FALSE
```

Followed by `unnest_longer()` to turn each alias into its own row:


```r
got %>% 
  unnest_wider(character) %>% 
  unnest_longer(aliases)
#> # A tibble: 7 x 3
#>   name             aliases            alive
#>   <chr>            <chr>              <lgl>
#> 1 Theon Greyjoy    Prince of Fools    TRUE 
#> 2 Theon Greyjoy    Theon Turncloak    TRUE 
#> 3 Theon Greyjoy    Theon Kinslayer    TRUE 
#> 4 Tyrion Lannister The Imp            TRUE 
#> 5 Tyrion Lannister Halfman            TRUE 
#> 6 Tyrion Lannister Giant of Lannister TRUE 
#> 7 Arys Oakheart    <NA>               FALSE
```

Even more conveniently, you can use `unnest_auto()` to guess which direction a list column should be unnested in. Here it yields the same results as above, and the messages tell you why:


```r
got %>% 
  unnest_auto(character) %>% 
  unnest_auto(aliases)
#> Using `unnest_wider(character)`; elements have 2 names in common
#> Using `unnest_longer(aliases)`; no element has names
```

Alternatively, you can use `hoist()` to reach deeply into a data structure and put out just the pieces you need:


```r
got %>% hoist(character, 
  name = "name",
  alias = list("aliases", 1),
  alive = "alive"
)
#> # A tibble: 3 x 4
#>   name             alias           alive character       
#>   <chr>            <chr>           <lgl> <list>          
#> 1 Theon Greyjoy    Prince of Fools TRUE  <named list [1]>
#> 2 Tyrion Lannister The Imp         TRUE  <named list [1]>
#> 3 Arys Oakheart    <NA>            FALSE <named list [0]>
```

This syntax provides a more approachable alternative to using `purrr::map()` inside `dplyr::mutate()`, as we'd previously recommended:


```r
got %>% mutate(
  name = purrr::map_chr(character, "name"),
  alias = purrr::map_chr(character, list("aliases", 1), .default = NA),
  alive = purrr::map_lgl(character, "alive")
)
```

Learn more in [`vignette("rectangle")`](http://tidyr.tidyverse.org/articles/rectangle.html).

## Nesting

`nest()` and `unnest()` have been updated with new interfaces that are more closely aligned to evolving tidyverse conventions. The biggest change is to their operation with multiple columns: 


```r
# old
df %>% nest(x, y, z)
# new
df %>% nest(data = c(x, y, z))

# old
df %>% unnest(x, y, z)
# new
df %>% unnest(c(x, y, z))
```

I've done my best to ensure that common uses of `nest()` and `unnest()` will continue to work, generating an informative warning telling you precisely how you need to update your code. If this doesn't work, you can use `nest_legacy()` or `unnest_legacy()` to access the previous interfaces; see [`vignette("in-packages")`](https://tidyr.tidyverse.org/articles/in-packages.html#tidyr-v0-8-3---v1-0-0) for more advice on managing this transition.

Behind the scenes, I discovered that nesting (and unnesting) can be decomposed into the combination of two simpler operations:

* `pack()` and `unpack()` multiple columns into and out of a data 
  frame column. 
  
* `chop()` and `unchop()` chop up rows into and out of list-columns. It's 
  a bit like an explicit form of `dplyr::group_by()`.

<p><img src="/images/tidyr-1-0-0/nest-pack-chop.png" width="480" height="352" /></p>

This is primarily of internal interest, but it considerably simplifies the implementation of `nest()`, and you may occasionally find the underlying functions useful when working with exotic data structures.

## `expand_grid()`

[`expand_grid()`](https://tidyr.tidyverse.org/reference/expand_grid.html) completes the existing family of `expand()`, `nesting()`, and `crossing()` with a low-level function that works with vectors:


```r
expand_grid(
  x = 1:3,
  y = letters[1:3],
  z = LETTERS[1:3]
)
#> # A tibble: 27 x 3
#>       x y     z    
#>   <int> <chr> <chr>
#> 1     1 a     A    
#> 2     1 a     B    
#> 3     1 a     C    
#> 4     1 b     A    
#> 5     1 b     B    
#> 6     1 b     C    
#> # … with 21 more rows
```

Compared to the existing base function `expand.grid()`, `expand_grid()`:

* Varies the first element most slowly (not most quickly).
* Never converts strings to factors and doesn't add any additional attributes.
* Returns a tibble, not a data frame.
* Can expand data frames.

The last feature is quite powerful, as it allows you to generate partial grids:


```r
students <- tribble(
  ~ school, ~ student,
  "A",      "John",
  "A",      "Mary",
  "A",      "Susan",
  "B",      "John"
)
expand_grid(students, semester = 1:2)
#> # A tibble: 8 x 3
#>   school student semester
#>   <chr>  <chr>      <int>
#> 1 A      John           1
#> 2 A      John           2
#> 3 A      Mary           1
#> 4 A      Mary           2
#> 5 A      Susan          1
#> 6 A      Susan          2
#> 7 B      John           1
#> 8 B      John           2
```

This is made possible by the [vctrs](https://vctrs.r-lib.org) package. vctrs is primarily of interest to package developers but I want to talk about it briefly here because I've been having a lot of fun working with it. It's hard to concisely describe vctrs, but one aspect is carefully defining what a "vector" is, and providing a set of useful functions that work on all types of vctrs, without any special cases. One interesting finding is that thinking of a data frame as a vector of _rows_ (not columns, as R usually does) is suprisingly useful, and something you can expect to see in more places in the tidyverse in the future. 

Note that when data frame inputs are unnamed, they're automatically unpacked into individual columns in the output. It's also possible to create a column that is itself a data frame, a **df-column**, if you name it:


```r
expand_grid(student = students, semester = 1:2)
#> # A tibble: 8 x 2
#>   student$school $student semester
#>   <chr>          <chr>       <int>
#> 1 A              John            1
#> 2 A              John            2
#> 3 A              Mary            1
#> 4 A              Mary            2
#> 5 A              Susan           1
#> 6 A              Susan           2
#> 7 B              John            1
#> 8 B              John            2
```

Df-columns aren't particularly useful yet, but they provide powerful building blocks for future extensions. For example, we expect a future version of dplyr will support df-columns as a way for `mutate()` and `summarise()` to create multiple new columns from a single function call.

## Thanks

A big thanks to all 95 people who help to make this release possible! [&#x0040;abiyug](https://github.com/abiyug), [&#x0040;AdvikS](https://github.com/AdvikS), [&#x0040;ahcyip](https://github.com/ahcyip), [&#x0040;alexpghayes](https://github.com/alexpghayes), [&#x0040;aneisse](https://github.com/aneisse), [&#x0040;apreshill](https://github.com/apreshill), [&#x0040;atusy](https://github.com/atusy), [&#x0040;ax42](https://github.com/ax42), [&#x0040;banfai](https://github.com/banfai), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;brentthorne](https://github.com/brentthorne), [&#x0040;brunj7](https://github.com/brunj7), [&#x0040;coolbutuseless](https://github.com/coolbutuseless), [&#x0040;courtiol](https://github.com/courtiol), [&#x0040;cwickham](https://github.com/cwickham), [&#x0040;DanielReedOcean](https://github.com/DanielReedOcean), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;dewittpe](https://github.com/dewittpe), [&#x0040;donboyd5](https://github.com/donboyd5), [&#x0040;earowang](https://github.com/earowang), [&#x0040;eElor](https://github.com/eElor), [&#x0040;enricoferrero](https://github.com/enricoferrero), [&#x0040;fresques](https://github.com/fresques), [&#x0040;garrettgman](https://github.com/garrettgman), [&#x0040;gederajeg](https://github.com/gederajeg), [&#x0040;georgevbsantiago](https://github.com/georgevbsantiago), [&#x0040;giocomai](https://github.com/giocomai), [&#x0040;gireeshkbogu](https://github.com/gireeshkbogu), [&#x0040;gorkang](https://github.com/gorkang), [&#x0040;ha0ye](https://github.com/ha0ye), [&#x0040;hadley](https://github.com/hadley), [&#x0040;hplieninger](https://github.com/hplieninger), [&#x0040;iago-pssjd](https://github.com/iago-pssjd), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;jackdolgin](https://github.com/jackdolgin), [&#x0040;japhir](https://github.com/japhir), [&#x0040;jayhesselberth](https://github.com/jayhesselberth), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jeroenjanssens](https://github.com/jeroenjanssens), [&#x0040;jestarr](https://github.com/jestarr), [&#x0040;jgendrinal](https://github.com/jgendrinal), [&#x0040;Jim89](https://github.com/Jim89), [&#x0040;jl5000](https://github.com/jl5000), [&#x0040;jmcastagnetto](https://github.com/jmcastagnetto), [&#x0040;justasmundeikis](https://github.com/justasmundeikis), [&#x0040;Kaz272](https://github.com/Kaz272), [&#x0040;KenatRSF](https://github.com/KenatRSF), [&#x0040;koncina](https://github.com/koncina), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;kuriwaki](https://github.com/kuriwaki), [&#x0040;lazappi](https://github.com/lazappi), [&#x0040;leeper](https://github.com/leeper), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;markdly](https://github.com/markdly), [&#x0040;martinjhnhadley](https://github.com/martinjhnhadley), [&#x0040;MatthieuStigler](https://github.com/MatthieuStigler), [&#x0040;mattwarkentin](https://github.com/mattwarkentin), [&#x0040;mehrgoltiv](https://github.com/mehrgoltiv), [&#x0040;meriops](https://github.com/meriops), [&#x0040;mikemc](https://github.com/mikemc), [&#x0040;mikmart](https://github.com/mikmart), [&#x0040;mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [&#x0040;mitchelloharawild](https://github.com/mitchelloharawild), [&#x0040;mixolydianpink](https://github.com/mixolydianpink), [&#x0040;mkapplebee](https://github.com/mkapplebee), [&#x0040;moodymudskipper](https://github.com/moodymudskipper), [&#x0040;mpaulacaldas](https://github.com/mpaulacaldas), [&#x0040;Myfanwy](https://github.com/Myfanwy), [&#x0040;ogorodriguez](https://github.com/ogorodriguez), [&#x0040;onesandzeroes](https://github.com/onesandzeroes), [&#x0040;Overlytic](https://github.com/Overlytic), [&#x0040;paleolimbot](https://github.com/paleolimbot), [&#x0040;PMassicotte](https://github.com/PMassicotte), [&#x0040;psychometrician](https://github.com/psychometrician), [&#x0040;Rekyt](https://github.com/Rekyt), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;romatik](https://github.com/romatik), [&#x0040;rubenarslan](https://github.com/rubenarslan), [&#x0040;SchollJ](https://github.com/SchollJ), [&#x0040;seabbs](https://github.com/seabbs), [&#x0040;sethmund](https://github.com/sethmund), [&#x0040;sfirke](https://github.com/sfirke), [&#x0040;SimonCoulombe](https://github.com/SimonCoulombe), [&#x0040;Stephonomon](https://github.com/Stephonomon), [&#x0040;stufield](https://github.com/stufield), [&#x0040;tdjames1](https://github.com/tdjames1), [&#x0040;thierrygosselin](https://github.com/thierrygosselin), [&#x0040;tklebel](https://github.com/tklebel), [&#x0040;tmastny](https://github.com/tmastny), [&#x0040;trannhatanh89](https://github.com/trannhatanh89), [&#x0040;TrentLobdell](https://github.com/TrentLobdell), [&#x0040;wcmbishop](https://github.com/wcmbishop), [&#x0040;wulixin](https://github.com/wulixin), [&#x0040;yutannihilation](https://github.com/yutannihilation), and [&#x0040;zeehio](https://github.com/zeehio).
