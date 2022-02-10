---
output: hugodown::hugo_document

slug: rlang-1-0-0-errors
title: New error style coming up in rlang 1.0.0
date: 2021-12-22
author: Lionel Henry
description: >
    rlang 1.0.0 is near and introduces a new style of error display. Feedback welcome!

photo:
  url: https://unsplash.com/photos/-eDpBjt6UL0
  author: Bryan Goff

categories: [package]
tags: []
rmd_hash: d4257e1bd4354c31

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
* [x] Add intro sentence, e.g. the standard tagline for the package
* [/] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

[rlang](https://rlang.r-lib.org/) 1.0.0 is getting ready for release and we'd like to get your feedback on the new style of error messages featured in this release.

The rlang package provides several low-level frameworks, like tidy evaluation, for the tidyverse. The 1.0.0 release focuses on one of these frameworks, **rlang errors**. This set of tools to signal and display errors gets a substantial overhaul. The three main changes to rlang errors that we'll review in this blog post are:

1.  Fully committing to the display of errors as bulleted lists
2.  Including the erroring function call by default, as in base R
3.  Embracing chained errors to represent contextual information

Attach these packages to follow the examples in the blog post:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rlang.r-lib.org'>rlang</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span><span class='o'>)</span></code></pre>

</div>

Here is how a typical rlang error looked before:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>add1</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='m'>1</span> <span class='o'>+</span> <span class='nv'>x</span>

<span class='nv'>mtcars</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>new <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/add1.html'>add1</a></span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; Error: Problem with `mutate()` column `new`.</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> `new = add1("foo")`.</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> non-numeric argument to binary operator</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> The error occurred in group 1: cyl = 4.</span></code></pre>

</div>

And here is how the same error looks with the next versions of rlang and dplyr:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>mtcars</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>new <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/add1.html'>add1</a></span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in </span><span style='font-weight: bold; font-weight: 100;'>`mutate()`:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Problem while computing `new = add1("foo")`.</span>
<span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> The error occurred in group 1: cyl = 4.</span>
<span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in </span><span style='font-weight: bold; font-weight: 100;'>`1 + x`:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> non-numeric argument to binary operator</span></code></pre>

</div>

For RStudio users, another change is that the error message no longer appears in red but instead uses terminal colours and boldness to style the different parts of the error message.

If you'd like to try the new error style on your computer, install the development versions of rlang and dplyr (the latter needs to be adapted to the new error style) from github with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='http://pak.r-lib.org/reference/pkg_install.html'>pkg_install</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"r-lib/rlang"</span>, <span class='s'>"tidyverse/dplyr"</span><span class='o'>)</span><span class='o'>)</span></code></pre>

</div>

## Displaying errors as bullet lists

[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) makes it easy to structure error messages as a **bullet list**. We believe that errors should be both informative about the context of the error and easy to skim. A bullet list arrangement that lays out important pieces of information line by line provides the right trade off for this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rlang.r-lib.org/reference/abort.html'>abort</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>
  <span class='s'>"This is the error message."</span>,
  <span class='s'>"*"</span> <span class='o'>=</span> <span class='s'>"This is a bullet."</span>,
  <span class='s'>"*"</span> <span class='o'>=</span> <span class='s'>"This is another bullet."</span>
<span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> This is the error message.</span>
<span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> This is a bullet.</span>
<span class='c'>#&gt; <span style='color: #00BBBB;'>•</span> This is another bullet.</span></code></pre>

</div>

The bullet symbol can be customised to provide a clue about the kind of information contained in the bullet. Use "ℹ" bullets to provide contextual information or hints, and "✖" bullets to state a problematic input or state.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rlang.r-lib.org/reference/abort.html'>abort</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>
  <span class='s'>"This is the error message."</span>,
  <span class='s'>"x"</span> <span class='o'>=</span> <span class='s'>"Can't do this."</span>,
  <span class='s'>"i"</span> <span class='o'>=</span> <span class='s'>"You could do that instead."</span>
<span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> This is the error message.</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> Can't do this.</span>
<span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> You could do that instead.</span></code></pre>

</div>

Here is a dplyr example of an informative error message structured as a bullet list:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>mtcars</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>new <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/rep.html'>rep</a></span><span class='o'>(</span><span class='nv'>am</span>, <span class='m'>2</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in </span><span style='font-weight: bold; font-weight: 100;'>`mutate()`:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Problem while computing `new = rep(am, 2)`.</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> `new` must be size 11 or 1, not 22.</span>
<span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> The error occurred in group 1: cyl = 4.</span></code></pre>

</div>

While rlang has featured error bullets for a while already, the 1.0.0 version fully commits to that format. The main error message (the error header in rlang terms) has become a bullet with a leading "!" sign that makes it easy to skim for error headers in a long R output.

## Displaying the erroring function

By default, [`base::stop()`](https://rdrr.io/r/base/stop.html) shows the function in which it was called:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>add1</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='kr'>if</span> <span class='o'>(</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>is.numeric</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='kr'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='o'>(</span><span class='s'>"`x` must be numeric."</span><span class='o'>)</span>
  <span class='o'>&#125;</span>
  <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span>
<span class='o'>&#125;</span>

<span class='nf'><a href='https://rdrr.io/r/stats/add1.html'>add1</a></span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span>
<span class='c'>#&gt; Error in add1("foo"): `x` must be numeric.</span></code></pre>

</div>

In rlang, we initially decided to turn off that feature because quite often the erroring function is unrelated to the function called by the user. This happens for instance when [`stop()`](https://rdrr.io/r/base/stop.html) or [`abort()`](https://rlang.r-lib.org/reference/abort.html) are called from a helper function:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>add1</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'>check_numeric</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span>
  <span class='nv'>x</span> <span class='o'>+</span> <span class='m'>1</span>
<span class='o'>&#125;</span>

<span class='nv'>check_numeric</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='kr'>if</span> <span class='o'>(</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>is.numeric</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='kr'><a href='https://rdrr.io/r/base/stop.html'>stop</a></span><span class='o'>(</span><span class='s'>"`x` must be numeric."</span><span class='o'>)</span>
  <span class='o'>&#125;</span>
<span class='o'>&#125;</span>

<span class='nf'><a href='https://rdrr.io/r/stats/add1.html'>add1</a></span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span>
<span class='c'>#&gt; Error in check_numeric(x): `x` must be numeric.</span></code></pre>

</div>

To avoid distracting users with irrelevant information, [`abort()`](https://rlang.r-lib.org/reference/abort.html) just didn't include a call in the error. However, we were missing out on contextual information that could help users understand the origin of an error without having to look at the backtrace, and that context is particularly important in a long pipeline of function calls.

To improve on the situation, we added a `call` argument to [`abort()`](https://rlang.r-lib.org/reference/abort.html) that makes it easy to throw an error on the behalf of another function. If you call [`abort()`](https://rlang.r-lib.org/reference/abort.html) from a helper function, pass the caller environment to automatically pick up the corresponding function call:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>check_numeric</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='kr'>if</span> <span class='o'>(</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/numeric.html'>is.numeric</a></span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>&#123;</span>
    <span class='nf'><a href='https://rlang.r-lib.org/reference/abort.html'>abort</a></span><span class='o'>(</span><span class='s'>"`x` must be numeric."</span>, call <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/sys.parent.html'>parent.frame</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
  <span class='o'>&#125;</span>
<span class='o'>&#125;</span>

<span class='nf'><a href='https://rdrr.io/r/stats/add1.html'>add1</a></span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in </span><span style='font-weight: bold; font-weight: 100;'>`add1()`:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `x` must be numeric.</span></code></pre>

</div>

We have started to adapt our packages to pass the correct function call to [`abort()`](https://rlang.r-lib.org/reference/abort.html) but there is still a lot of work to do on that front. If you find a function call that looks off in an error message, please let us know by filing an issue.

## Chained errors

Chained errors are another important feature of rlang 1.0. This feature was somewhat hidden in previous versions because it only impacted the appearance of backtraces. In this release, we have decided to show the whole chain of messages to the user, making error chaining much more useful.

One important use case for chaining errors is as a scaffholding for displaying contextual information when the user provides computations nested in a particular step, such as a dplyr verb or a ggplot geom.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>mtcars</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/group_by.html'>group_by</a></span><span class='o'>(</span><span class='nv'>cyl</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>
    out1 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/add1.html'>add1</a></span><span class='o'>(</span><span class='nv'>am</span><span class='o'>)</span>,
    out2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/stats/add1.html'>add1</a></span><span class='o'>(</span><span class='s'>"foo"</span><span class='o'>)</span>
  <span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in </span><span style='font-weight: bold; font-weight: 100;'>`mutate()`:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Problem while computing `out2 = add1("foo")`.</span>
<span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> The error occurred in group 1: cyl = 4.</span>
<span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in </span><span style='font-weight: bold; font-weight: 100;'>`add1()`:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> `x` must be numeric.</span></code></pre>

</div>

In this example, dplyr combines all three features (bullet lists, the display of erroring functions, and chained errors) to structure the error message in a hierarchy. At the topmost level, the [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) error provides information about the current expression being evaluated, as well as the current group. The chained error then displays the function that errored within [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) as well as the full error message.

Currenty only the development version of dplyr takes advantage of chained errors. We hope to implement them in other tidyverse and tidymodels packages in the coming year to make it easier to detect failing steps in large pipelines.

## Use rlang style errors globally

Normally, only the errors thrown with [`abort()`](https://rlang.r-lib.org/reference/abort.html) use the new display. Add a call to `global_handle()` in your `.Rprofile` to use the rlang style globally, including base errors.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># In .Rprofile</span>
<span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'>global_handle</span><span class='o'>(</span><span class='o'>)</span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>
<span class='m'>1</span> <span class='o'>+</span> <span class='s'>"foo"</span>
<span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in </span><span style='font-weight: bold; font-weight: 100;'>`1 + "foo"`:</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> non-numeric argument to binary operator</span>
</code></pre>

</div>

## Taking feedback

Given the scope of the changes, we felt it appropriate to delay the release of rlang 1.0 until late January to get more feedback on the new display of errors. Please reach out on twitter (my handle is [\_lionelhenry](https://twitter.com/_lionelhenry/)) or file an [issue on github](https://github.com/r-lib/rlang) if you have any comments.

