---
title: ggplot2 3.0.0 - dev notes
date: '2018-07-01'
slug: ggplot2-3-0-0-dev-notes
author: Mara Averick
categories: [package]
description: >
  ggplot2 3.0.0 — what package developers need to know.
photo:
  url: https://unsplash.com/photos/8KfCR12oeUM
  author: Christopher Burns
---



As noted in our [pre-release announcement](https://www.tidyverse.org/articles/2018/05/ggplot2-2-3-0/) back in May, ggplot2 3.0.0 contains some breaking changes that we believe to be worthwhile in the interest of improving future code. Here, we outline the most prominent of those changes, and "symptomatic" error messages you may encounter. For our complete list of such messages, please see the [Breaking changes](https://github.com/tidyverse/ggplot2/blob/master/NEWS.md#breaking-changes) section of the [release notes](https://github.com/tidyverse/ggplot2/blob/master/NEWS.md).

## Tidy evaluation

ggplot2 now supports tidy evaluation, making it more programmable, and more consistent with the rest of the tidyverse. 

The primary developer-facing change is that `aes()` now contains quosures (expression + environment pairs) rather than symbols. As a result, you'll need to take a different approach to extracting the information you need.


```r
x_var <- quo(cyl)
y_var <- quo(mpg)

by_cyl <- mtcars %>%
  group_by(!!x_var) %>%
  summarise(mean = mean(!!y_var))

ggplot(by_cyl, aes(!!x_var, mean)) +
  geom_point()
```

<img src="/articles/2017-07-ggplot2-3-0-0-dev-notes_files/figure-html/aes-quo-1.png" width="672" />


```r
# need better counter example to -> Errors 
#> undefined columns selected
#> invalid 'type' (list) of argumen
# ggplot(mtcars, aes(x_var, y_var)) +
#  geom_point()
```


