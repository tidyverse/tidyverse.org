---
output: hugodown::hugo_document
slug: base-vs-magrittr-pipe
title: Differences between the base R and magrittr pipes
date: 2023-03-07
author: Hadley Wickham
description: >
    A discussion of the (relatively minor) differences between the native R pipe, 
    `|>`, and the magrittr pipe, `%>%`.
photo:
  url: https://unsplash.com/photos/4CNNH2KEjhc
  author: Sigmund
# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [other] 
tags: [magrittr]
rmd_hash: 7d7b84d4fffc579a

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

**Note:** The following has been adapted from a section of the forthcoming second edition of [R for Data Science](https://r4ds.hadley.nz/) that had to be removed due to length limitations.

## Pipes

With the 4.1.0 release of R, a native pipe operator, `|>`, was introduced. Its behavior is by and large the same as that of the [`%>%`](https://magrittr.tidyverse.org/reference/pipe.html) pipe provided by the **magrittr** package. Both operators (`|>` and `%>%`) let you "pipe" an object forward to a function or call expression, thereby allowing you to express a sequence of operations that transform an object.

To learn more about the basic utility of pipes, see [The pipe](https://r4ds.hadley.nz/data-transform.html#the-pipe) section of R for Data Science.

## `|>` vs. `%>%`

While `|>` and `%>%` behave identically for simple cases, there are a few crucial differences. These are most likely to affect you if you're a long-term user of `%>%` who has taken advantage of some of the more advanced features. But they're still good to know about even if you've never used `%>%` because you're likely to encounter some of them when reading wild-caught code.

-   By default, the pipe passes the object on its left-hand side to the first argument of the function on the right-hand side. `%>%` allows you to change the placement with a `.` placeholder. For example, `x %>% f(1)` is equivalent to `f(x, 1)` but `x %>% f(1, .)` is equivalent to `f(1, x)`. R 4.2.0 added a `_` placeholder to the base pipe, with one additional restriction: the argument has to be named. For example, `x |> f(1, y = _)` is equivalent to `f(1, y = x)`.

-   The `|>` placeholder is deliberately simple and can't replicate many features of the `%>%` placeholder: you can't pass it to multiple arguments, and it doesn't have any special behavior when the placeholder is used inside another function. For example, `df %>% split(.$var)` is equivalent to `split(df, df$var)`, and `df %>% {split(.$x, .$y)}` is equivalent to `split(df$x, df$y)`.

    With `%>%`, you can use `.` on the left-hand side of operators like `$`, `[[`, `[` , so you can extract a single column from a data frame with (e.g.) `mtcars %>% .$cyl`. A future version of R may add similar support for `|>` and `_`. For the special case of extracting a column out of a data frame, you can also use [`dplyr::pull()`](https://dplyr.tidyverse.org/reference/pull.html):

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'>pull</span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span></span></code></pre>

    </div>

-   `%>%` allows you to drop the parentheses when calling a function with no other arguments; `|>` always requires the parentheses.

-   `%>%` allows you to start a pipe with `.` to create a function rather than immediately executing the pipe; this is not supported by the base pipe.

Luckily there's no need to commit entirely to one pipe or the other --- you can use the base pipe for the majority of cases where it's sufficient and use the magrittr pipe when you really need its special features.

