---
title: dplyr 0.8.0 release candidate
author: Romain François
date: '2018-10-23'
slug: dplyr-0-8-0-release-candidate
description: > 
  What you need to know about upcoming changes for dplyr 0.8.0.
categories:
  - package
tags:
  - dplyr
  - tidyverse
photo:
  url: https://unsplash.com/photos/kU-WKSyTcp4
  author: Pau Casals
---



A new release of dplyr (0.8.0) is on the horizon, and since it is a major release, we'd love for the 
community to try it out, give us some feedback and [report issues](https://github.com/tidyverse/dplyr/issues)
before we submit to CRAN. This version represents about six months of development, making dplyr more
respectful of factors and less surprising in its evaluation of expressions. 

In this post, we'll highlight the major changes, please see the 
[NEWS](https://github.com/tidyverse/dplyr/blob/master/NEWS.md) for a more 
detailed description of changes. Our formalised process for this release is captured 
in [this issue](https://github.com/tidyverse/dplyr/issues/3931)


```r
# install.packages("devtools")
devtools::install_github("tidyverse/dplyr")
```

If needed, you can restore the release version by installing from CRAN:


```r
install.packages("dplyr")
```

# New grouping algorithm

## Group creation

The algorithm behind `group_by()` has been redesigned to better respect factor levels, 
a group is created for each level of the factor, even if there is no data. This 
differs from previous versions of dplyr where groups were only created to 
match the observed data. This closes the epic issue 
[341](https://github.com/tidyverse/dplyr/issues/341) that dates back to 2014. 

Let's illustrate the new algorithm with the [count()](https://dplyr.tidyverse.org/reference/tally.html) 
function:


```r
df <- tibble(
  f1 = factor(c("a", "a", "a", "b", "b"), levels = c("a", "b", "c")), 
  f2 = factor(c("d", "e", "d", "e", "f"), levels = c("d", "e", "f")), 
  x  = c(1, 1, 1, 2, 2), 
  y  = 1:5
)
df
#> # A tibble: 5 x 4
#>   f1    f2        x     y
#>   <fct> <fct> <dbl> <int>
#> 1 a     d         1     1
#> 2 a     e         1     2
#> 3 a     d         1     3
#> 4 b     e         2     4
#> # ... with 1 more row
df %>% 
  count(f1)
#> # A tibble: 3 x 2
#>   f1        n
#>   <fct> <int>
#> 1 a         3
#> 2 b         2
#> 3 c         0
```

Where previous versions of `dplyr` would have created only two groups (for levels `a` and `b`), 
it now creates one group per level, and the group related to the level `c` just happens to be 
empty. 

Groups are still made to match the data on other types of columns:


```r
df %>% 
  count(x)
#> # A tibble: 2 x 2
#>       x     n
#>   <dbl> <int>
#> 1     1     3
#> 2     2     2
```

Expansion of groups for factors happens at each step of the grouping, so if we group
by `f1` and `f2` we get 9 groups, 


```r
df %>% 
  count(f1, f2)
#> # A tibble: 9 x 3
#>   f1    f2        n
#>   <fct> <fct> <int>
#> 1 a     d         2
#> 2 a     e         1
#> 3 a     f         0
#> 4 b     d         0
#> # ... with 5 more rows
```

When factors and non factors are involved in the grouping, the number of 
groups depends on the order. At each level of grouping, factors are always expanded
to one group per level, but non factors only create groups based on observed data. 


```r
df %>% 
  count(f1, x)
#> # A tibble: 3 x 3
#>   f1        x     n
#>   <fct> <dbl> <int>
#> 1 a         1     3
#> 2 b         2     2
#> 3 c        NA     0
```


In this example, we group by `f1` then `x`. At the first layer, grouping on `f1` creates
two groups. Each of these grouops is then subdivided based on the values of the second 
variable `x`. Since `x` is always 1 when `f1` is `a` the group is not 
further divided. 

The last group, associated with the level `c` of the factor `f1` is empty, and 
consequently has no values for the vector `x`. In that case, `group_by()` uses 
`NA`. 


```r
df %>% 
  count(x, f1)
#> # A tibble: 6 x 3
#>       x f1        n
#>   <dbl> <fct> <int>
#> 1     1 a         3
#> 2     1 b         0
#> 3     1 c         0
#> 4     2 a         0
#> # ... with 2 more rows
```

When we group by `x` then `f1` we initially split the data according to `x` which 
gives 2 groups. Each of these two groups is then further divided in 3 groups, 
i.e. one for each level of `f1`. 

## Group preservation

The grouping structure is more coherently preserved by dplyr verbs, and the notion of 
lazy grouped data frame is now obsolete. We needed lazily grouped data frames 
in previous versions because the verbs did not reconstruct the groups. 


```r
df %>% 
  group_by(x, f1) %>% 
  summarise(y = mean(y))
#> # A tibble: 6 x 3
#> # Groups:   x [2]
#>       x f1        y
#>   <dbl> <fct> <dbl>
#> 1     1 a         2
#> 2     1 b       NaN
#> 3     1 c       NaN
#> 4     2 a       NaN
#> # ... with 2 more rows
```

The expression `mean(y)` is evaluated for the empty groups as well, and gives 
coherent results with : 


```r
mean(numeric())
#> [1] NaN
```

In particular the result of `filter()` preserves the grouping structure of the input 
data frame. 


```r
df %>% 
  group_by(x, f1) %>% 
  filter(y < 4)
#> # A tibble: 3 x 4
#> # Groups:   x, f1 [6]
#>   f1    f2        x     y
#>   <fct> <fct> <dbl> <int>
#> 1 a     d         1     1
#> 2 a     e         1     2
#> 3 a     d         1     3
```

The resulting tibble after the `filter()` call has six groups, the same 
exact groups that were made by `group_by()`. Previous versions of dplyr
would perform an implicit `group_by()` after the filtering, potentially losing
groups. 

Because this is potentially disruptive, `filter()` has gained a `.preserve` argument, 
the default value (`TRUE`) keeps the existing groups, but
when `.preserve` is `FALSE` the data is first filtered and then grouped by:


```r
df %>% 
  group_by(x, f1) %>% 
  filter(y < 5, .preserve = FALSE)
#> # A tibble: 4 x 4
#> # Groups:   x, f1 [6]
#>   f1    f2        x     y
#>   <fct> <fct> <dbl> <int>
#> 1 a     d         1     1
#> 2 a     e         1     2
#> 3 a     d         1     3
#> 4 b     e         2     4
```

Note however, than even `.preserve = FALSE` respects the factors that are used as 
grouping variables, in particular `filter( , .preserve = FALSE)` is not a way to 
discard empty groups. The forcats 📦 may help: 


```r
iris %>% 
  group_by(Species) %>% 
  filter(stringr::str_detect(Species, "^v")) %>% 
  ungroup() %>% 
  group_by(Species = forcats::fct_drop(Species))
#> # A tibble: 100 x 5
#> # Groups:   Species [2]
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species   
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>     
#> 1          7           3.2          4.7         1.4 versicolor
#> 2          6.4         3.2          4.5         1.5 versicolor
#> 3          6.9         3.1          4.9         1.5 versicolor
#> 4          5.5         2.3          4           1.3 versicolor
#> # ... with 96 more rows
```

# Changes in filter and slice

Besides changes described previously related to preservation of the grouping structure, 
`filter()` and `slice()` now reorganize the data by groups for performance reasons: 


```r
tibble(
  x = c(1, 2, 1, 2, 1), 
  y = c(1, 2, 3, 4, 5)
) %>% 
  group_by(x) %>% 
  filter(y < 5)
#> # A tibble: 4 x 2
#> # Groups:   x [2]
#>       x     y
#>   <dbl> <dbl>
#> 1     1     1
#> 2     1     3
#> 3     2     2
#> 4     2     4
```

# Redesigned hybrid evaluation

## What's hybrid evaluation again ?

Hybrid evaluation is used in `summarise()` and `mutate()` to replace 
potential expensive R operations by native C++ code that is group aware. 


```r
iris %>% 
  group_by(Species) %>% 
  summarise(Petal.Length = mean(Petal.Length))
#> # A tibble: 3 x 2
#>   Species    Petal.Length
#>   <fct>             <dbl>
#> 1 setosa             1.46
#> 2 versicolor         4.26
#> 3 virginica          5.55
```

In the example, the `base::mean()` function is never called because the 
hybrid alternative can directly calculate the mean for each group. Hybrid 
evaluation typically gives better performance because it needs less memory
allocations. 

In this example, a standard evaluation path would need to: 
 - create subsets of the `Petal.Length` column for each group
 - call the `base::mean()` function on each subset, which would also 
   imply a cost for S3 dispatching to the right method
 - collect all results in a new vector
 
In constrast, hybrid evaluation can directly allocate the final 
vector, and calculate all 3 means without having to allocate the subsets. 

## Flaws in previous hybrid

Previous versions of hybrid evaluation relied on folding to 
replace part of the expression by their hybrid result. For example, 
there are hybrid versions of `sum()` and `n()`, so previous 
versions attempted to use them for:


```r
iris %>% 
  group_by(Species) %>% 
  summarise(Petal.Length = sum(Petal.Length) / n())
#> # A tibble: 3 x 2
#>   Species    Petal.Length
#>   <fct>             <dbl>
#> 1 setosa             1.46
#> 2 versicolor         4.26
#> 3 virginica          5.55
```

The gain of replacing parts of the expression with the result of the
hybrid versions was minimal, and the we had to rely on many 
ad-hoc to try to respect standard R evaluation semantics. 

## New implementation

The new hybrid system is less greedy and falls back to standard R evaluation 
when the expression is not entirely recognized. 

The `hybrid_call()` function (subject to change) can be used to test if an expression
would be handled by hybrid or standard evaluation: 


```r
iris %>% hybrid_call(mean(Sepal.Length))
#> <hybrid evaluation>
#>   call      : base::mean(Sepal.Length)
#>   C++ class : dplyr::hybrid::internal::SimpleDispatchImpl<14, false, dplyr::NaturalDataFrame, dplyr::hybrid::internal::MeanImpl>
iris %>% hybrid_call(sum(Sepal.Length) / n())
#> <standard evaluation>
#>   call      : sum(Sepal.Length)/n()
iris %>% hybrid_call(+mean(Sepal.Length))
#> <standard evaluation>
#>   call      : +mean(Sepal.Length)
```

Hybrid is very picky about what it can handle, for example `TRUE` and `FALSE` 
are fine for `na.rm=` because they are reserved words that can't be replaced, but 
`T`, `F` or any expression that would resolve to a scalar logical are not: 


```r
iris %>% hybrid_call(mean(Sepal.Length, na.rm = TRUE))
#> <hybrid evaluation>
#>   call      : base::mean(Sepal.Length, na.rm = TRUE)
#>   C++ class : dplyr::hybrid::internal::SimpleDispatchImpl<14, true, dplyr::NaturalDataFrame, dplyr::hybrid::internal::MeanImpl>
iris %>% hybrid_call(mean(Sepal.Length, na.rm = T))
#> <standard evaluation>
#>   call      : mean(Sepal.Length, na.rm = T)
iris %>% hybrid_call(mean(Sepal.Length, na.rm = 1 == 1))
#> <standard evaluation>
#>   call      : mean(Sepal.Length, na.rm = 1 == 1)
```

The first step of the new hybrid system consists of studying the 
expression and compare it to known expression patterns. If we find an exact
match, then we have all the information we need, and R is never called 
to materialize the result. 

When there is no match, the expression gets evaluated for each group using R standard 
evaluation rules in the data mask: a special environment that makes the columns available
and uses context aware information for functions such as `n()`. 


```r
iris %>% 
  group_by(Species) %>% 
  summarise(Petal.Length = sum(Petal.Length) / n())
#> # A tibble: 3 x 2
#>   Species    Petal.Length
#>   <fct>             <dbl>
#> 1 setosa             1.46
#> 2 versicolor         4.26
#> 3 virginica          5.55
```

# Performance

TODO: 
 - some initial results in [this issue](https://github.com/tidyverse/dplyr/issues/3881)

# nest_by, nest_join

TODO

# colwise verbs

TODO 

# Tidy grouping structure

Previous versions of `dplyr` used a messy set of attributes in grouped
tibbles to keep track of the groups and their indices. This has been 
re-organized into a tibble that can be accessed with the new 
`group_data()` function. 


```r
iris %>% 
  group_by(Species) %>% 
  group_data()
#> # A tibble: 3 x 2
#>   Species    .rows     
#>   <fct>      <list>    
#> 1 setosa     <int [50]>
#> 2 versicolor <int [50]>
#> 3 virginica  <int [50]>
```

The first columns of that tibble describe the groups in terms of the 
grouping variables, and the last column (always called `.rows`)
is a list of integer vectors identifying the (one-based) indices of 
each group. 

The related function `group_rows()` gives just that last column. 


```r
iris %>% 
  group_by(Species) %>% 
  group_rows()
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
#> [24] 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46
#> [47] 47 48 49 50
#> 
#> [[2]]
#>  [1]  51  52  53  54  55  56  57  58  59  60  61  62  63  64  65  66  67
#> [18]  68  69  70  71  72  73  74  75  76  77  78  79  80  81  82  83  84
#> [35]  85  86  87  88  89  90  91  92  93  94  95  96  97  98  99 100
#> 
#> [[3]]
#>  [1] 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117
#> [18] 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134
#> [35] 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150
```
