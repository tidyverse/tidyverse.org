---
output: hugodown::hugo_document

slug: testthat-3-1
title: testthat 3.1.0
date: 2021-09-22
author: Hadley Wickham
description: >
    testthat 3.1.0 brings improvements to snapshot testing and one breaking
    change.

photo:
  url: https://unsplash.com/photos/vasU4-TlC5I
  author: Ethan Hoover

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [testthat]
rmd_hash: 95af79c81c843a9e

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
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're stoked to announce the release of [testthat](http://testthat.r-lib.org/) 3.1.0. testthat makes it easy to turn your existing informal tests into formal, automated tests that you can rerun quickly and easily. testthat is the most popular unit-testing package for R, and is used by over 6,000 CRAN and Bioconductor packages. You can learn more about unit testing at <https://r-pkgs.org/tests.html>.

You can install testthat from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"&#123;package&#125;"</span><span class='o'>)</span></code></pre>

</div>

This release of testthat includes a bunch of minor improvements to snapshotting as well as one breaking change to the 3rd edition. You can see a full list of changes in the [release notes](https://github.com/r-lib/testthat/blob/master/NEWS.md)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://testthat.r-lib.org'>testthat</a></span><span class='o'>)</span></code></pre>

</div>

## Snapshot tests

While this release includes a bunch of minor improvements (and one breaking change, more on that below), most of the effort has gone in to [`expect_snapshot()`](https://testthat.r-lib.org/reference/expect_snapshot.html) and friends. [`expect_snapshot()`](https://testthat.r-lib.org/reference/expect_snapshot.html) is used to create snapshot tests, a new feature in testthat 3.0.0. Instead of using code to describe expected output, snapshot tests (also known as [golden tests](https://ro-che.info/articles/2017-12-04-golden-tests)) record results in a separate human-readable file. You can learn more about them in `vignette("snapshotting.html", package = "testthat")`.

We have been using snapshot tests across many tidyverse packages and they have been working well. I don't anticipate any major changes (although we may continue to add new features) so the snapshot functions have moved from experimental to stable.

This release also includes two new features that help you use snapshot tests in more places:

-   [`expect_snapshot()`](https://testthat.r-lib.org/reference/expect_snapshot.html) gains a `transform` argument, which should be a function that takes a character vector of lines and returns a modified character vector of lines. This makes it easy to remove sensitive (e.g. API keys) or stochastic (e.g. random temporary directory names) from snapshot output.

-   [`expect_snapshot()`](https://testthat.r-lib.org/reference/expect_snapshot.html) and friends gets an experimental new `variant` argument which causes the snapshot to be saved in `_snaps/{variant}/{test}.md` instead of `_snaps/{test}.md`. This allows you to generate (and compare) unique snapshots for different scenarios where the output is otherwise out of your control, like differences across operating systems or R versions.

By default snapshot tests are not run on CRAN because they require a human to confirm whether or not a change is a breakage, so you shouldn't rely only on snapshot tests (you can set `cran = TRUE`, to run on CRAN, but generally snapshot tests are vulnerable to minor changes that probably don't merit breaking R CMD check on CRAN.)

## Breaking changes

We made one breaking change that affects code that uses [testthat 3e](https://testthat.r-lib.org/articles/third-edition.html). Previously, [`expect_message()`](https://testthat.r-lib.org/reference/expect_error.html), [`expect_warning()`](https://testthat.r-lib.org/reference/expect_error.html) and [`expect_error()`](https://testthat.r-lib.org/reference/expect_error.html) returned the value of the first argument, unless that was `NULL` in which case they returned the condition object. This meant you could write code like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_warning</a></span><span class='o'>(</span><span class='nf'>f</span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>"warning"</span><span class='o'>)</span>, <span class='s'>"value"</span><span class='o'>)</span></code></pre>

</div>

Now you need to flip the order of the expectations:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_warning</a></span><span class='o'>(</span><span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nf'>f</span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>"value"</span><span class='o'>)</span>, <span class='s'>"warning"</span><span class='o'>)</span></code></pre>

</div>

Which (IMO) is a little easier to read with the pipe:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Or use the pipe:</span>
<span class='nf'>f</span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='s'>"value"</span><span class='o'>)</span> <span class='o'><a href='https://magrittr.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_warning</a></span><span class='o'>(</span><span class='s'>"warning"</span><span class='o'>)</span></code></pre>

</div>

Or with an intermediate object:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_warning</a></span><span class='o'>(</span><span class='nv'>value</span> <span class='o'>&lt;-</span> <span class='nf'>f</span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>"warning"</span><span class='o'>)</span>
<span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nv'>value</span>, <span class='s'>"value"</span><span class='o'>)</span></code></pre>

</div>

As with any breaking change, we made this change with great care. Fortunately it only affects the 3rd edition, which relatively few packages use, and we submitted PRs to all affected CRAN packages. We made this change because it makes testthat more consistent and makes it easier to inspect both the value and the warning.

This is important because it makes it easier to test function that produce richer error objects that themselves contain meangingful data:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>err</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_error</a></span><span class='o'>(</span><span class='nf'>my_function</span><span class='o'>(</span><span class='o'>)</span>, class <span class='o'>=</span> <span class='s'>"package_error_class"</span><span class='o'>)</span>
<span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nv'>err</span><span class='o'>$</span><span class='nv'>name</span>, <span class='s'>"foo"</span><span class='o'>)</span>
<span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nv'>err</span><span class='o'>$</span><span class='nv'>bar</span>, <span class='s'>"foo"</span><span class='o'>)</span></code></pre>

</div>

Richer condition objects are mostly of interest to advanced developers, but within the tidyverse they are part of our toolkit to provide more useful error messages in more places.

## Acknowledgements

