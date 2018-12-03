---
title: dplyr 0.8.0 release candidate
author: Romain François
date: '2018-12-03'
slug: dplyr-0-8-0-release-candidate
description: > 
  What you need to know about upcoming changes in dplyr 0.8.0.
categories:
  - package
tags:
  - dplyr
  - tidyverse
photo:
  url: https://unsplash.com/photos/kU-WKSyTcp4
  author: Pau Casals
---



A new release of dplyr (0.8.0) is on the horizon, roughly planned for early January 2019. 

Since it is a major release with some potential
disruption, we'd love for the community to try it out, give us some feedback 
and [report issues](https://github.com/tidyverse/dplyr/issues)
before we submit to CRAN. This version represents about nine months of development, making dplyr more
respectful of factors and less surprising in its evaluation of expressions. 

In this post, we'll highlight the major changes, please see the 
[NEWS](https://github.com/tidyverse/dplyr/blob/master/NEWS.md) for a more 
detailed description of changes. Our formalised process for this release is captured 
in [this issue](https://github.com/tidyverse/dplyr/issues/3931).


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

The algorithm behind [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) has been redesigned to better respect factor levels, 
so that a group is created for each level of the factor, even if there is no data. This 
differs from previous versions of dplyr where groups were only created to 
match the observed data. This closes the epic issue [341](https://github.com/tidyverse/dplyr/issues/341) that dates back to 2014, and has generated 
a lot of press and frustration, see [Zero Counts in dplyr](https://kieranhealy.org/blog/archives/2018/11/19/zero-counts-in-dplyr/)
for a recent walkthrough of the issue. 

Let's illustrate the new algorithm with the [`count()`](https://dplyr.tidyverse.org/reference/count.html) function:


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
#> # … with 1 more row
df %>% 
  count(f1)
#> # A tibble: 3 x 2
#> # Groups:   [1]
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
#> # Groups:   [1]
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
#> # Groups:   [1]
#>   f1    f2        n
#>   <fct> <fct> <int>
#> 1 a     d         2
#> 2 a     e         1
#> 3 a     f         0
#> 4 b     d         0
#> # … with 5 more rows
```

When factors and non factors are involved in the grouping, the number of 
groups depends on the order. At each level of grouping, factors are always expanded
to one group per level, but non factors only create groups based on observed data. 


```r
df %>% 
  count(f1, x)
#> # A tibble: 3 x 3
#> # Groups:   [1]
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
consequently has no values for the vector `x`. In that case, [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) uses 
`NA`. 


```r
df %>% 
  count(x, f1)
#> # A tibble: 6 x 3
#> # Groups:   [1]
#>       x f1        n
#>   <dbl> <fct> <int>
#> 1     1 a         3
#> 2     1 b         0
#> 3     1 c         0
#> 4     2 a         0
#> # … with 2 more rows
```

When we group by `x` then `f1` we initially split the data according to `x` which 
gives 2 groups. Each of these two groups is then further divided in 3 groups, 
i.e. one for each level of `f1`. 

## Group preservation

The grouping structure is more coherently preserved by dplyr verbs. 


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
#> # … with 2 more rows
```

The expression `mean(y)` is evaluated for the empty groups as well, and gives 
consistent results with : 


```r
mean(numeric())
#> [1] NaN
```

In particular the result of [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) preserves the grouping structure of the input 
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

The resulting tibble after the [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) call has six groups, the same 
exact groups that were made by [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html). Previous versions of dplyr
would perform an implicit `group_by()` after the filtering, potentially losing
groups. 

Because this is potentially disruptive, [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) has gained a `.preserve` argument, 
when `.preserve` is `FALSE` the data is first filtered and then regrouped:


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

Note however, that even `.preserve = FALSE` respects the factors that are used as 
grouping variables, in particular `filter( , .preserve = FALSE)` is not a way to 
discard empty groups. The [forcats](https://forcats.tidyverse.org) 📦 may help: 


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
#> # … with 96 more rows
```

## New grouping fuctions

The grouping family is extended with new functions:

 - [`group_nest()`](https://dplyr.tidyverse.org/reference/group_nest.html) : similar to [`tidyr::nest()`](https://tidyr.tidyverse.org/reference/nest.html) but focusing on the grouping columns
   rather than the columns to nest
 - [`group_split()`](https://dplyr.tidyverse.org/reference/group_split.html) : similar to `base::split()` but the grouping is subject to the data mask
 - [`group_keys()`](https://dplyr.tidyverse.org/reference/group_keys.html) : retrieves a tibble with one row per group and one column per grouping variable
 - [`group_rows()`](https://dplyr.tidyverse.org/reference/group_rows.html) : retrieves a list of 1-based integer vectors, each vector represents the indices
   of the group in the grouped data frame

The primary use case for these functions is with already grouped data frames, that may directly 
or indirectly originate from [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html).


```r
data <- iris %>% 
  group_by(Species) %>% 
  filter(Sepal.Length > mean(Sepal.Length))

data %>% 
  group_nest()
#> # A tibble: 3 x 2
#>   Species    data             
#>   <fct>      <list>           
#> 1 setosa     <tibble [22 × 4]>
#> 2 versicolor <tibble [24 × 4]>
#> 3 virginica  <tibble [22 × 4]>
data %>% 
  group_split()
#> [[1]]
#> # A tibble: 22 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          5.4         3.9          1.7         0.4 setosa 
#> 3          5.4         3.7          1.5         0.2 setosa 
#> 4          5.8         4            1.2         0.2 setosa 
#> # … with 18 more rows
#> 
#> [[2]]
#> # A tibble: 24 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species   
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>     
#> 1          7           3.2          4.7         1.4 versicolor
#> 2          6.4         3.2          4.5         1.5 versicolor
#> 3          6.9         3.1          4.9         1.5 versicolor
#> 4          6.5         2.8          4.6         1.5 versicolor
#> # … with 20 more rows
#> 
#> [[3]]
#> # A tibble: 22 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species  
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>    
#> 1          7.1         3            5.9         2.1 virginica
#> 2          7.6         3            6.6         2.1 virginica
#> 3          7.3         2.9          6.3         1.8 virginica
#> 4          6.7         2.5          5.8         1.8 virginica
#> # … with 18 more rows
data %>% 
  group_keys()
#> # A tibble: 3 x 1
#>   Species   
#>   <fct>     
#> 1 setosa    
#> 2 versicolor
#> 3 virginica
data %>% 
  group_rows()
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22
#> 
#> [[2]]
#>  [1] 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45
#> [24] 46
#> 
#> [[3]]
#>  [1] 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68
```

Alternatively, these functions may be used on an ungrouped data frame, together with a 
grouping specification that is subject to the data mask. In that case, the grouping is 
implicitly performed by [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html): 


```r
iris %>% 
  group_nest(Species)
#> # A tibble: 3 x 2
#>   Species    data             
#>   <fct>      <list>           
#> 1 setosa     <tibble [50 × 4]>
#> 2 versicolor <tibble [50 × 4]>
#> 3 virginica  <tibble [50 × 4]>

iris %>% 
  group_split(Species)
#> [[1]]
#> # A tibble: 50 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa 
#> 4          4.6         3.1          1.5         0.2 setosa 
#> # … with 46 more rows
#> 
#> [[2]]
#> # A tibble: 50 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species   
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>     
#> 1          7           3.2          4.7         1.4 versicolor
#> 2          6.4         3.2          4.5         1.5 versicolor
#> 3          6.9         3.1          4.9         1.5 versicolor
#> 4          5.5         2.3          4           1.3 versicolor
#> # … with 46 more rows
#> 
#> [[3]]
#> # A tibble: 50 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species  
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>    
#> 1          6.3         3.3          6           2.5 virginica
#> 2          5.8         2.7          5.1         1.9 virginica
#> 3          7.1         3            5.9         2.1 virginica
#> 4          6.3         2.9          5.6         1.8 virginica
#> # … with 46 more rows

iris %>% 
  group_keys(Species)
#> # A tibble: 3 x 1
#>   Species   
#>   <fct>     
#> 1 setosa    
#> 2 versicolor
#> 3 virginica
```

These functions are related to each other in how they handle and organize the
grouping information and who/what is responsible for maintaining the relation between the 
data and the groups.  

 - A grouped data frame, as generated by [`group_by()`](https://dplyr.tidyverse.org/reference/group_by.html) stores the grouping information 
   as an attribute of the data frame, dplyr verbs use that information to maintain 
   the relationship
  
 - When using [`group_nest()`](https://dplyr.tidyverse.org/reference/group_nest.html) the data is structured as a data frame that has a list column
   to hold the non grouping columns. The result of [`group_nest()`](https://dplyr.tidyverse.org/reference/group_nest.html) is not a grouped data frame, 
   therefore the structure of the data frame maintains the relationship. 
   
 - When using [`group_split()`](https://dplyr.tidyverse.org/reference/group_split.html) the data is split into a list, and each element of the list
   contains a tibble with the rows of the associated group. The user is responsible to 
   maintain the relationship, and may benefit from the assistance of the [`group_keys()`](https://dplyr.tidyverse.org/reference/group_keys.html) 
   function, especially in the presence of empty groups. 

## Iterate on grouped tibbles by group

The new [`group_map()`](https://dplyr.tidyverse.org/reference/group_map.html) function provides a purrr style function that can be used to 
iterate on grouped tibbles. Each conceptual group of the data frame is exposed to the 
function with two pieces of information: 
 
 - The subset of the data for the group, exposed as `.x`. 
 - The key, a tibble with exactly one row and columns for each grouping variable, 
   exposed as `.y`


```r
mtcars %>% 
  group_by(cyl) %>%
  group_map(~ head(.x, 2L))
#> # A tibble: 6 x 11
#> # Groups:   cyl [3]
#>     cyl   mpg  disp    hp  drat    wt  qsec    vs    am  gear  carb
#> * <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1     4  22.8  108     93  3.85  2.32  18.6     1     1     4     1
#> 2     4  24.4  147.    62  3.69  3.19  20       1     0     4     2
#> 3     6  21    160    110  3.9   2.62  16.5     0     1     4     4
#> 4     6  21    160    110  3.9   2.88  17.0     0     1     4     4
#> # … with 2 more rows

mtcars %>%
  group_by(cyl) %>%
  group_map(~ tibble(mod = list(lm(mpg ~ disp, data = .x))))
#> # A tibble: 3 x 2
#> # Groups:   cyl [3]
#>     cyl mod     
#> * <dbl> <list>  
#> 1     4 <S3: lm>
#> 2     6 <S3: lm>
#> 3     8 <S3: lm>
```

The lambda function must return a data frame. [`group_map()`](https://dplyr.tidyverse.org/reference/group_map.html) row binds the data 
frames, recycles the grouping columns and structures the result as a grouped tibble. 

# Changes in filter and slice

Besides changes described previously related to preservation of the grouping structure, 
[`filter()`](https://dplyr.tidyverse.org/reference/filter.html) and [`slice()`](https://dplyr.tidyverse.org/reference/slice.html) now reorganize the data by groups for performance reasons: 


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

Hybrid evaluation is used in [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) and [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) to replace 
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
evaluation typically gives better performance because it needs fewer memory
allocations. 

In this example, a standard evaluation path would need to: 
 - create subsets of the `Petal.Length` column for each group
 - call the `base::mean()` function on each subset, which would also 
   imply a cost for S3 dispatching to the right method
 - collect all results in a new vector
 
In constrast, hybrid evaluation can directly allocate the final 
vector, and calculate all 3 means without having to allocate the subsets. 

## Flaws in previous version

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
hybrid versions was minimal, and the we had to rely on 
brittle heuristics to try to respect standard R evaluation semantics. 

## New implementation

The new hybrid system is stricter and falls back to standard R evaluation 
when the expression is not entirely recognized. 

The [`hybrid_call()`](https://dplyr.tidyverse.org/reference/hybrid_call.html) function (subject to change) can be used to test if an expression
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
evaluation rules in the data mask: a special environment that makes the 
columns available and uses contextual information for functions such as [`n()`](https://dplyr.tidyverse.org/reference/n.html)
and [`row_number()`](https://dplyr.tidyverse.org/reference/row_number.html). 


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

When [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) or [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html)  use expressions that cannot be handled by
hybrid evaluation, they call back to R from the C++ internals for each group. 

This is an expensive operation because the expressions have to be evaluated 
with extra care. Traditionally it meant wrapping the expression in an R `tryCatch()` 
before evaluating, but R 3.5.0 has added unwind protection and we exposed that to 
Rcpp. Consequently, the cost of evaluating an R expression carefully is lower 
than before. 

We ran a benchmark calculating the means of 10,000 small groups with the 
release version of dplyr and this release candidate with and without 
using the unwind protect feature. 

Just using the `mean()` function would not illustrate the feature, because dplyr would
use hybrid evaluation and never use callbacks to R, so instead we defined a `mean_` 
function that has the same body as `base::mean()`, we also compare this to 
the expression `sum(x) / n()` because it woudld have been handled by 
partial hybrid evaluation in previous versions. 

![](/articles/2018-12-dplyr-0-8-0_files/timings_summarise_mean.jpeg)

This is not a comprehensive benchmark analysis, but on this small example we can read: 

  - unwind protection has no impact when using the hybrid evaluation, this is not a surprise
    because the hybrid path does not call back to R. 
  - hybrid evaluation performs better on the release candidate. This is a direct consequence of
    the redesign of hybrid evaluation. 
  - unwind protection gives a performance boost `mean_()`. Please note that the 
    x axis is on a log scale. 
  - unwind protection more than compensates for no longer using partial hybrid evaluation. 
  
# nest_join

The [`nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html) function is the newest addition to the join family. 


```r
band_members %>% 
  nest_join(band_instruments)
#> Joining, by = "name"
#> # A tibble: 3 x 3
#>   name  band    band_instruments
#> * <chr> <chr>   <list>          
#> 1 Mick  Stones  <tibble [0 × 1]>
#> 2 John  Beatles <tibble [1 × 1]>
#> 3 Paul  Beatles <tibble [1 × 1]>
```

A nest join of `x` and `y` returns all rows and all columns from `x`, plus an additional column 
that contains a list of tibbles. Each tibble contains all the rows from `y` that match that row of `x`. 
When there is no match, the list column is a 0-row tibble with the same column names and types as `y`.

[`nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html) is the most fundamental join since you can recreate the other joins from it: 
 
  - [`inner_join()`](https://dplyr.tidyverse.org/reference/inner_join.html) is a [`nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html) plus an [`tidyr::unnest()`](https://tidyr.tidyverse.org/reference/unnest.html)
  - [`left_join()`](https://dplyr.tidyverse.org/reference/left_join.html) is a  [`nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html) plus an [`tidyr::unnest()`](https://tidyr.tidyverse.org/reference/unnest.html) with `drop=TRUE`
  - [`semi_join()`](https://dplyr.tidyverse.org/reference/semi_join.html) is a [`nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html) plus a [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) where you check that every element of data has at least one row. 
  - [`anti_join()`](https://dplyr.tidyverse.org/reference/anti_join.html) is a [`nest_join()`](https://dplyr.tidyverse.org/reference/nest_join.html) plus a [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) where you check every element has zero rows.

# Scoped variants

The scoped (or colwise) verbs are the set of verbs with `_at`, `_if` and `_all` suffixes. 
These verbs apply a certain behaviour (for instance, a mutating or summarising operation) to a given 
selection of columns. This release of dplyr improves the consistency of the syntax and the behaviour with grouped tibbles.


## A purrr-like syntax for passing functions

In dplyr 0.8.0, we have implemented support for functions and purrr-style lambda functions:


```r
iris <- as_tibble(iris) # For concise print method

mutate_if(iris, is.numeric, ~ . - mean(.))
#> # A tibble: 150 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1       -0.743      0.443         -2.36      -0.999 setosa 
#> 2       -0.943     -0.0573        -2.36      -0.999 setosa 
#> 3       -1.14       0.143         -2.46      -0.999 setosa 
#> 4       -1.24       0.0427        -2.26      -0.999 setosa 
#> # … with 146 more rows
```

And lists of functions and purrr-style lambda functions:


```r
fns <- list(
  centered = mean,                # Function object
  scaled = ~ . - mean(.) / sd(.)  # Purrr-style lambda
)
mutate_if(iris, is.numeric, fns)
#> # A tibble: 150 x 13
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <fct>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa 
#> 4          4.6         3.1          1.5         0.2 setosa 
#> # … with 146 more rows, and 8 more variables: Sepal.Length_centered <dbl>,
#> #   Sepal.Width_centered <dbl>, Petal.Length_centered <dbl>,
#> #   Petal.Width_centered <dbl>, Sepal.Length_scaled <dbl>,
#> #   Sepal.Width_scaled <dbl>, Petal.Length_scaled <dbl>,
#> #   Petal.Width_scaled <dbl>
```

This is now the preferred syntax for passing functions to the scoped verbs because it is simpler and consistent with purrr. 
Counting from dplyr 0.8.0, the hybrid evaluator recognises and inlines these lambdas, so that native implementation of 
common algorithms will kick in just as it did with expressions passed with `funs()`. 
Consequently, we are soft-deprecating `funs()`: it will continue to work without any warnings for now, 
but will eventually start issuing warnings.

## Behaviour with grouped tibbles

We have reviewed the documentation of all scoped variants to make clear how the scoped operations 
are applied to grouped tibbles. For most of the scoped verbs, the operation also apply on 
the grouping variables when they are part of the selection. This includes:

* [`arrange_all()`](https://dplyr.tidyverse.org/reference/arrange_all.html), [`arrange_at()`](https://dplyr.tidyverse.org/reference/arrange_at.html), and [`arrange_if()`](https://dplyr.tidyverse.org/reference/arrange_if.html)
* [`distinct_all()`](https://dplyr.tidyverse.org/reference/distinct_all.html), [`distinct_at()`](https://dplyr.tidyverse.org/reference/distinct_at.html), and [`distinct_if()`](https://dplyr.tidyverse.org/reference/distinct_if.html)
* [`filter_all()`](https://dplyr.tidyverse.org/reference/filter_all.html), [`filter_at()`](https://dplyr.tidyverse.org/reference/filter_at.html), and [`filter_if()`](https://dplyr.tidyverse.org/reference/filter_if.html)
* [`group_by_all()`](https://dplyr.tidyverse.org/reference/group_by_all.html), [`group_by_at()`](https://dplyr.tidyverse.org/reference/group_by_at.html), and [`group_by_if()`](https://dplyr.tidyverse.org/reference/group_by_if.html)
* [`select_all()`](https://dplyr.tidyverse.org/reference/select_all.html), [`select_at()`](https://dplyr.tidyverse.org/reference/select_at.html), and [`select_if()`](https://dplyr.tidyverse.org/reference/select_if.html)

This is not the case for summarising and mutating variants where operations are *not* applied on grouping variables. 
The behaviour depends on whether the selection is **implicit** (`all` and `if` selections) or **explicit** (`at` selections). 
Grouping variables covered by explicit selections (with [`summarise_at()`](https://dplyr.tidyverse.org/reference/summarise_at.html), [`mutate_at()`](https://dplyr.tidyverse.org/reference/mutate_at.html), and [`transmute_at()`](https://dplyr.tidyverse.org/reference/transmute_at.html) are always an error.
For implicit selections, the grouping variables are always ignored. In this case, the level of verbosity depends on the kind of operation:

* Summarising operations ([`summarise_all()`](https://dplyr.tidyverse.org/reference/summarise_all.html) and [`summarise_if()`](https://dplyr.tidyverse.org/reference/summarise_if.html)
  ignore grouping variables silently because it is obvious that
  operations are not applied on grouping variables.

* On the other hand it isn't as obvious in the case of mutating operations ([`mutate_all()`](https://dplyr.tidyverse.org/reference/mutate_all.html), [`mutate_if()`](https://dplyr.tidyverse.org/reference/mutate_if.html), [`transmute_all()`](https://dplyr.tidyverse.org/reference/transmute_all.html), and [`transmute_if()`](https://dplyr.tidyverse.org/reference/transmute_if.html)). 
 For this reason, they issue a message indicating which grouping variables are ignored.

In order to make it easier to explicitly remove the grouping columns from an `_at` selection, we have introduced a 
new selection helper [`group_cols()`](https://dplyr.tidyverse.org/reference/group_cols.html). Just like [`last_col()`](https://dplyr.tidyverse.org/reference/last_col.html) matches the last column of a tibble, 
[`group_cols()`](https://dplyr.tidyverse.org/reference/group_cols.html) matches all grouping columns:


```r
mtcars %>%
  group_by(cyl) %>%
  select(group_cols())
#> # A tibble: 32 x 1
#> # Groups:   cyl [3]
#>     cyl
#> * <dbl>
#> 1     6
#> 2     6
#> 3     4
#> 4     6
#> # … with 28 more rows
```

This new helper is mostly intended for selection in scoped variants:


```r
mtcars %>%
  group_by(cyl) %>%
  mutate_at(
    vars(starts_with("c")),
    ~ . - mean(.)
  )
#> Error: Column `cyl` can't be modified because it's a grouping variable
```

It makes it easy to remove explicitly the grouping variables:


```r
mtcars %>%
  group_by(cyl) %>%
  mutate_at(
    vars(starts_with("c"), -group_cols()),
    ~ . - mean(.)
  )
#> # A tibble: 32 x 11
#> # Groups:   cyl [3]
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear   carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>  <dbl>
#> 1  21       6   160   110  3.9   2.62  16.5     0     1     4  0.571
#> 2  21       6   160   110  3.9   2.88  17.0     0     1     4  0.571
#> 3  22.8     4   108    93  3.85  2.32  18.6     1     1     4 -0.545
#> 4  21.4     6   258   110  3.08  3.22  19.4     1     0     3 -2.43 
#> # … with 28 more rows
```
