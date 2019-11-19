---
title: 'rlang 0.4.0'
author: Lionel Henry
date: '2019-06-27'
slug: rlang-0-4-0
description: >
  rlang 0.4.0 is now on CRAN!
categories:
  - package
tags:
  - rlang
  - r-lib
photo:
  url: https://unsplash.com/photos/ar7ZWQ-r87g
  author: Caitlin Wynne
---



It is with great excitement that we announce the release of [rlang 0.4.0](https://rlang.r-lib.org) on CRAN. rlang is a toolkit for working with core R and Tidyverse features, and hosts the tidy evaluation framework. The full set of changes can be found in the [changelog](https://rlang.r-lib.org/news/index.html#rlang-0-4-0). 

In this article, we introduce the most important of these, the new tidy evaluation operator `{{`. We will use a simple dplyr pipeline as a running example, let's start by attaching the package:


```r
library(dplyr)
```


## The good and bad of tidy evaluation

Tidy eval powers packages like dplyr and tidyr. It makes it possible to manipulate data frame columns as if they were defined in the workspace:


```r
gender
#> Error in eval(expr, envir, enclos): object 'gender' not found
mass
#> Error in eval(expr, envir, enclos): object 'mass' not found

starwars %>%
  group_by(gender) %>%
  summarise(mass_maximum = max(mass, na.rm = TRUE))
#> # A tibble: 5 x 2
#>   gender        mass_maximum
#>   <chr>                <dbl>
#> 1 <NA>                    75
#> 2 female                  75
#> 3 hermaphrodite         1358
#> 4 male                   159
#> 5 none                   140
```

We call this syntax __data masking__. This feature is unique to the R language and greatly streamlines the writing and reading of code in interactive scripts. Unfortunately, it also makes it more complex to reuse common patterns inside functions:


```r
max_by <- function(data, var, by) {
  data %>%
    group_by(by) %>%
    summarise(maximum = max(var, na.rm = TRUE))
}

starwars %>% max_by(mass, by = gender)
#> Error: Column `by` is unknown
```

Technically, this is because data-masked code needs to be _delayed_ and _transported_ to the data context. Behind the scenes, dplyr verbs achieve this by capturing the blueprint of your code, and resuming its evaluation inside the data mask. The example above fails because `group_by()` is capturing the wrong piece of blueprint. To solve this, tidy evaluation provides `enquo()` to delay the interpretation of code and capture its blueprint, and the surgery operator `!!` for modifying blueprints. The combination of using `enquo()` and `!!` is called the __quote-and-unquote__ pattern:


```r
max_by <- function(data, var, by) {
  data %>%
    group_by(!!enquo(by)) %>%
    summarise(maximum = max(!!enquo(var), na.rm = TRUE))
}

starwars %>% max_by(mass, by = gender)
#> # A tibble: 5 x 2
#>   gender        maximum
#>   <chr>           <dbl>
#> 1 <NA>               75
#> 2 female             75
#> 3 hermaphrodite    1358
#> 4 male              159
#> 5 none              140
```

We have come to realise that this pattern is difficult to teach and to learn because it involves a new, unfamiliar syntax, and because it introduces two new programming concepts (quote and unquote) that are hard to understand intuitively. This complexity is not really justified because this pattern is overly flexible for basic programming needs.


## A simpler interpolation pattern with `{{`

rlang 0.4.0 provides a new operator, `{{` (read: curly curly), which abstracts quote-and-unquote into a single __interpolation__ step. The curly-curly operator should be straightforward to use. When you create a function around a tidyverse pipeline, wrap the function arguments containing data frame variables with `{{`:


```r
max_by <- function(data, var, by) {
  data %>%
    group_by({{ by }}) %>%
    summarise(maximum = max({{ var }}, na.rm = TRUE))
}

starwars %>% max_by(height)
#> # A tibble: 1 x 1
#>   maximum
#>     <int>
#> 1     264

starwars %>% max_by(height, by = gender)
#> # A tibble: 5 x 2
#>   gender        maximum
#>   <chr>           <int>
#> 1 <NA>              167
#> 2 female            213
#> 3 hermaphrodite     175
#> 4 male              264
#> 5 none              200
```

This syntax should be reminiscent of string interpolation in the [glue](https://glue.tidyverse.org/) package by Jim Hester:


```r
var <- sample(c("woof", "meow", "mooh"), size = 1)
glue::glue("Did you just say {var}?")
#> Did you just say mooh?
```


## Other simple tidy evaluation patterns

There are a few existing patterns that aren't emphasised enough in the existing documentation. We are changing our teaching strategy to focus on these simpler patterns.

* If you would like to pass multiple arguments to a data-masking verb, pass `...` directly:

  
  ```r
  summarise_by <- function(data, ..., by) {
    data %>%
      group_by({{ by }}) %>%
      summarise(...)
  }
  
  starwars %>%
    summarise_by(
      average = mean(height, na.rm = TRUE),
      maximum = max(height, na.rm = TRUE),
      by = gender
    )
  #> # A tibble: 5 x 3
  #>   gender        average maximum
  #>   <chr>           <dbl>   <int>
  #> 1 <NA>             120      167
  #> 2 female           165.     213
  #> 3 hermaphrodite    175      175
  #> 4 male             179.     264
  #> 5 none             200      200
  ```

  You only need quote-and-unquote (with the plural variants `enquos()` and `!!!`) when you need to modify the inputs or their names in some way.

* If you have string inputs, use the `.data` pronoun:

  
  ```r
  max_by <- function(data, var, by) {
    data %>%
      group_by(.data[[by]]) %>%
      summarise(maximum = max(.data[[var]], na.rm = TRUE))
  }
  
  starwars %>% max_by("height", by = "gender")
  #> # A tibble: 5 x 2
  #>   gender        maximum
  #>   <chr>           <int>
  #> 1 <NA>              167
  #> 2 female            213
  #> 3 hermaphrodite     175
  #> 4 male              264
  #> 5 none              200
  ```

  The `.` pronoun from magrittr is not appropriate here because it represents the whole data frame, whereas `.data` represents the subset for the current group.


To learn more about the different ways of programming around tidyverse pipelines, we recommend reading the [new programming vignette in ggplot2](https://ggplot2.tidyverse.org/dev/articles/ggplot2-in-packages.html#using-aes-and-vars-in-a-package-function), written by [Dewey Dunnington](https://github.com/paleolimbot) who is currently interning at RStudio.


## Thanks!

The following people have contributed to this release by posting issues and pull requests:

[&#x0040;001ben](https://github.com/001ben), [&#x0040;asardaes](https://github.com/asardaes), [&#x0040;BillDunlap](https://github.com/BillDunlap), [&#x0040;burchill](https://github.com/burchill), [&#x0040;cpsievert](https://github.com/cpsievert), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;egnha](https://github.com/egnha), [&#x0040;flying-sheep](https://github.com/flying-sheep), [&#x0040;gaborcsardi](https://github.com/gaborcsardi), [&#x0040;gaelledoucet](https://github.com/gaelledoucet), [&#x0040;GaGaMan1101](https://github.com/GaGaMan1101), [&#x0040;grayskripko](https://github.com/grayskripko), [&#x0040;hadley](https://github.com/hadley), [&#x0040;harrysouthworth](https://github.com/harrysouthworth), [&#x0040;holgerbrandl](https://github.com/holgerbrandl), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;jazzmoe](https://github.com/jazzmoe), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jjesusfilho](https://github.com/jjesusfilho), [&#x0040;juangomezduaso](https://github.com/juangomezduaso), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;Marieag](https://github.com/Marieag), [&#x0040;mmuurr](https://github.com/mmuurr), [&#x0040;moodymudskipper](https://github.com/moodymudskipper), [&#x0040;paulponcet](https://github.com/paulponcet), [&#x0040;riccardopinosio](https://github.com/riccardopinosio), [&#x0040;richierocks](https://github.com/richierocks), [&#x0040;RolandASc](https://github.com/RolandASc), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;s-fleck](https://github.com/s-fleck), [&#x0040;siddharthprabhu](https://github.com/siddharthprabhu), [&#x0040;subratiter1](https://github.com/subratiter1), [&#x0040;wch](https://github.com/wch), [&#x0040;wetlandscapes](https://github.com/wetlandscapes), [&#x0040;wlandau](https://github.com/wlandau), [&#x0040;x1o](https://github.com/x1o), [&#x0040;XWeiZhou](https://github.com/XWeiZhou), [&#x0040;yenzichun](https://github.com/yenzichun), [&#x0040;yonicd](https://github.com/yonicd), and [&#x0040;zachary-foster](https://github.com/zachary-foster)
