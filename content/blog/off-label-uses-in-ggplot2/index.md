---
output: hugodown::hugo_document

slug: off-label-uses-in-ggplot2
title: Off-label uses in ggplot2
date: 2021-06-24
author: Thomas Lin Pedersen
description: >
    A 2-3 sentence description of the post that appears on the articles page.
    This can be omitted if it would just recapitulate the title.

photo:
  url: https://unsplash.com/photos/n6vS3xlnsCc
  author: Kelley Bozarth

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [programming] 
tags: [ggplot2, off-label]
rmd_hash: 388c4c634b2cfa58

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

ggplot2 v3.3.4 landed on CRAN recently, and while every release of ggplot2 is cause for celebration, this was merely a patch release fixing a large number of bugs and it thus came and went without much fanfare. However, for a couple of users this release brought an unwelcome and surprise change. We feel that this is a great opportunity to talk a bit about some of the topics that Hadley discussed in his [rstudio::global(2021) keynote](https://www.rstudio.com/resources/rstudioglobal-2021/maintaining-the-house-the-tidyverse-built/) where he addresses the nature of breaking changes.

## The surprising use of `ggsave()`

The issue we will discuss in this blog post revolves around the use of [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) which is intended as a quick way for users to save the last created ggplot. More specifically the issue is related to this use pattern:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span>

<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>displ</span>, y <span class='o'>=</span> <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsave.html'>ggsave</a></span><span class='o'>(</span><span class='s'>"my_mpg_plot.png"</span><span class='o'>)</span></code></pre>

</div>

Now, if this is the first time you've seen [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) being added to a plot, you are not alone. This certainly caught us by surprise. Prior to v3.3.4, this actually worked (more on that later) but with the recent release running this code will result in the following error:

    Error: Can't add [`ggsave("my_mpg_plot.png")`](https://ggplot2.tidyverse.org/reference/ggsave.html) to a ggplot object.

If you were a user that had used this pattern for saving plots it very much felt like we had removed a feature, pulling the rug out from under your script with no warning. However, this use of [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) had never been advertised in any of the documentation and while it worked, it could not be considered a feature as such.

For completeness, this is the advertised and supported use of [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>displ</span>, y <span class='o'>=</span> <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span>

<span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsave.html'>ggsave</a></span><span class='o'>(</span><span class='s'>"my_mpg_plot.png"</span><span class='o'>)</span></code></pre>

</div>

## Off-label saving

The issue described above falls under the category of off-label use that Hadley talks about in his keynote. Off-label use of functions comprise of using functions in a way that only work *by accident*, and are thus susceptible to breakage at any point due to changes in the code. Another common word for this is "a hack", but this term can often imply that the user is full aware of the brittle nature of the setup. Off-label use can just as well be passed on between users to a point where some thinks that this is the correct, supported, way of doing things (this was certainly the case with the above issue).

In an age of the pipe it is easy to understand why this use was picked up and thought off as a real feature. [`+`](https://rdrr.io/r/base/Arithmetic.html), however, is not `%>%` (or `|>`). It is a compositional operator meant to assemble the description of a plot. There is no execution of logic (besides the assembly) going on, and thus the idea of adding [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) does not make theoretical nor practical sense. This is also the reason why we do not want to "fix" this issue and turn it into a regular feature.

## Why did it work, why did it fail

For those interested in the cause of both the accidental functionality and its breakage, here follows a description. [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) can be used to save any plot object but defaults to the object returned by [`ggplot2::last_plot()`](https://ggplot2.tidyverse.org/reference/last_plot.html). This function returns the last rendered *or* modified plot object. That means that whenever you add something to a plot the result will be retrievable with [`last_plot()`](https://ggplot2.tidyverse.org/reference/last_plot.html) but only until you manipulate or render another plot. What happens when adding [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) to a plot is that all the additions are resolved from the left and at each point the result is pushed to the [`last_plot()`](https://ggplot2.tidyverse.org/reference/last_plot.html) store. When it comes to the [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) term, it will evaluate it and add the result to the plot. Since the expected plot is present in the [`last_plot()`](https://ggplot2.tidyverse.org/reference/last_plot.html) store the evaluation of [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) will proceed as expected. Prior to ggplot2 v3.3.4 [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) returned `NULL` which, when added to a ggplot object is a no-op (i.e. it does nothing). The change that provoked the error is that with v3.3.4 [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) now returns the path to the saved file invisibly, and adding a string to a plot object is an error.

Based on this understanding there are some interesting observations we can make: First, while you'll get an error in v3.3.4, the plot is actually saved to a file since the error is thrown after the evaluation of [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html). This means that you can "fix" your code by putting the whole expression in a [`try()`](https://rdrr.io/r/base/try.html) block (please don't do this though 😬):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/try.html'>try</a></span><span class='o'>(</span>
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>)</span> <span class='o'>+</span> 
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>displ</span>, y <span class='o'>=</span> <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>+</span> 
    <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsave.html'>ggsave</a></span><span class='o'>(</span><span class='s'>"my_mpg_plot.png"</span><span class='o'>)</span>
<span class='o'>)</span></code></pre>

</div>

Another tidbit we can get is that the perceived feature was, even when it worked, extremely brittle. Consider the following code:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>p1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_point.html'>geom_point</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>displ</span>, y <span class='o'>=</span> <span class='nv'>hwy</span><span class='o'>)</span><span class='o'>)</span>

<span class='nv'>p2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mpg</span><span class='o'>)</span> <span class='o'>+</span> 
  <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_bar.html'>geom_bar</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nv'>cyl</span><span class='o'>)</span><span class='o'>)</span>

<span class='nv'>p1</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsave.html'>ggsave</a></span><span class='o'>(</span><span class='s'>"scatterplot.png"</span><span class='o'>)</span>
<span class='nv'>p2</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggsave.html'>ggsave</a></span><span class='o'>(</span><span class='s'>"barplot.png"</span><span class='o'>)</span></code></pre>

</div>

If you assumed that [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) could be added to a plot you'd expect the above to be totally valid code and that `scatterplot.png` would contain the plot from `p1`, and `barplot.png` would contain the plot from `p2`. However, since [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) just fetched the last modified or rendered plot by default, both png files would be identical and contain the barplot in `p2`.

## Wrapping up

In the end this short post is not intended to shame the users who used [`ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html) in an unsupported way. ggplot2 is such a huge package that it is easy to pick up usage patterns without ever thinking about whether it is the correct way - if it works it works. Instead, this post is meant to showcase how, even with rigorous testing and no breaking changes, an update can break someones workflow, often to the surprise of the developer. Once a package becomes popular enough, even the slightest change in the code have the capacity for disruption.

