---
output: hugodown::hugo_document
slug: base-vs-magrittr-pipe
title: Differences between the base R and magrittr pipes
date: 2023-04-21
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
rmd_hash: 3f7097a99f43b212

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

R 4.1.0 introduced a native pipe operator, `|>`. As described in the [R News](https://cran.r-project.org/doc/manuals/r-devel/NEWS.html):

> R now provides a simple native forward pipe syntax `|>`. The simple form of the forward pipe inserts the left-hand side as the first argument in the right-hand side call. The pipe implementation as a syntax transformation was motivated by suggestions from Jim Hester and Lionel Henry.

The behaviour of the native pipe is by and large the same as that of the [`%>%`](https://magrittr.tidyverse.org/reference/pipe.html) pipe provided by the **magrittr** package. Both operators (`|>` and `%>%`) let you "pipe" an object forward to a function or call expression, thereby allowing you to express a sequence of operations that transform an object.

To learn more about the basic utility of pipes, see [The pipe](https://r4ds.hadley.nz/data-transform.html#the-pipe) section of R for Data Science.

Luckily there's no need to commit entirely to one pipe or the other --- you can use the base pipe for the majority of cases where it's sufficient and use the magrittr pipe when you really need its special features.

## `|>` vs. `%>%`

While `|>` and `%>%` behave identically for simple cases, there are a few crucial differences. These are most likely to affect you if you're a long-term user of `%>%` who has taken advantage of some of the more advanced features. But they're still good to know about even if you've never used `%>%` because you're likely to encounter some of them when reading wild-caught code.

-   By default, the pipe passes the object on its left-hand side to the first argument of the function on the right-hand side. `%>%` allows you to change the placement with a `.` placeholder. For example, `x %>% f(1)` is equivalent to `f(x, 1)` but `x %>% f(1, .)` is equivalent to `f(1, x)`. R 4.2.0 added a `_` placeholder to the base pipe, with one additional restriction: the argument has to be named. For example, `x |> f(1, y = _)` is equivalent to `f(1, y = x)`.

-   The `|>` placeholder is deliberately simple and can't replicate many features of the `%>%` placeholder: you can't pass it to multiple arguments, and it doesn't have any special behavior when the placeholder is used inside another function. For example, `df %>% split(.$var)` is equivalent to `split(df, df$var)`, and `df %>% {split(.$x, .$y)}` is equivalent to `split(df$x, df$y)`.

    With `%>%`, you can use `.` on the left-hand side of operators like `$`, `[[`, `[` , so you can extract a single column from a data frame with (e.g.) `mtcars %>% .$cyl`. R added support for this feature in R 4.3.0. For the special case of extracting a column out of a data frame, you can also use `dplyr::pull()`:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'>pull</span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span></span></code></pre>

    </div>

-   `%>%` allows you to drop the parentheses when calling a function with no other arguments; `|>` always requires the parentheses.

-   `%>%` allows you to start a pipe with `.` to create a function rather than immediately executing the pipe; this is not supported by the base pipe.

## Using the native pipe in packages

Because the native pipe wasn't introduced until 4.1.0, code using `|>` in function reference examples or vignettes will not work on older versions of R, as it is not valid syntax. This is a problem for the tidyverse because our [versioning policies](https://www.tidyverse.org/blog/2019/04/r-version-support/) mean that our packages need to work on R 3.5.0 and later.

Does this mean that you need to increase the minimum R version your package depends on in order to use `|>`? Not necessarily: there are two techniques we can use to keep vignettes and examples working.

For example, the base pipe is used in purrr 1.0.0. As can be seen in the [source for the "purrr \<-\> base R" vignette](https://github.com/tidyverse/purrr/commit/df4630c6e8cd5028386ee96b9036f1755f26adc4), certain code chunks are evaluated conditionally based on the version of R being used. The setup chunk for the vignette includes: `modern_r <- getRversion() >= "4.1.0"`. The results of this are then used in the `eval` argument to determine whether or not a code chunk that relies on "modern R" syntax should be run.

The other place we use the base pipe is in examples. To disable these we use a bit of a hack that requires three files [`configure`](https://github.com/tidyverse/purrr/blob/main/configure), [`cleanup`](https://github.com/tidyverse/purrr/blob/main/cleanup), and [`tools/examples.R`](https://github.com/tidyverse/purrr/blob/main/tools/examples.R). The basic idea is for pre-R 4.1.0 we re-define the `\examples{}` tag to display an informative message but not run the code; this ensures that `R CMD check` continues to work even on older versions of R.

