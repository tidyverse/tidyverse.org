---
output: hugodown::hugo_document

slug: testthat-3-3-0
title: testthat 3.3.0
date: 2025-11-05
author: Hadley Wickham
description: >
    testthat 3.3.0 brings improved expectations with better error messages,
    new expectations for common testing patterns, and lifecycle changes including the removal of `local_mock()` and `with_mock()`. It also includes
    a write-up of my experience doing package development with Claude Code.
photo:
  url: https://unsplash.com/photos/a-rack-filled-with-lots-of-yellow-hard-hats-wp81DxKUd1Ez
  author: Pop & Zebra

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [testthat, devtools]
rmd_hash: 0ef3010e84b47ab3

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
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're chuffed to announce the release of [testthat](https://testthat.r-lib.org) 3.3.0. testthat is a testing framework for R that makes it easy to turn your existing informal tests into formal, automated tests that you can rerun quickly and easily.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"testthat"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post highlights the most important changes in this release, including lifecycle changes that removed long-deprecated mocking functions, improvements to expectations and their error messages, and a variety of new features that make testing easier and more robust. You can see a full list of changes in the [release notes](https://github.com/r-lib/testthat/releases/tag/v3.3.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://testthat.r-lib.org'>testthat</a></span><span class='o'>)</span></span></code></pre>

</div>

## Claude Code experiences

Before we dive into the changes, I wanted to talk a little bit about some changes to my development process, as I used this release as an opportunity to learn [Claude Code](https://www.claude.com/product/claude-code). This is the first package where I've really used AI to support the development of many features and I thought it might be useful to share my experience.

Overall it was a successful experiment. It helped me close over 100 issues in what felt like less time than usual. I don't have any hard numbers, but my gut feeling is that it was maybe a 10-20% improvement to my development velocity. This is still significant, especially since I'm an experienced R programmer and my workflow has been pretty stable for the last few years. I mostly used Claude for smaller, well-defined tasks where I had a good sense of what was needed. I found it particularly useful for refactoring, where it was easy to say precisely what I wanted, but executing the changes required a bunch of fiddly edits across many files.

I also found it generally useful for getting over the "activation energy hump": there were a few issues that had been stagnating for years because they felt like they were going to be hard to do and with relatively limited payoff. I let Claude Code loose on a few of these and found it super useful. It only produced code I was really happy with a couple of times, but every time it gave me something to react to (often with strong negative feelings!) and that got me started actually engaging with the problem.

If you're interested in using Claude Code yourself, there are a couple of files you might find useful. My [`CLAUDE.md`](https://github.com/r-lib/testthat/blob/main/.claude/CLAUDE.md) tells Claude how to execute a devtools-based workflow, along with a few pointers to resolve common issues. My [`settings.json`](https://github.com/r-lib/testthat/blob/main/.claude/settings.json) allows Claude to run longer without human intervention, doing things that should mostly be safe. One note of caution: these settings do allow Claude to run R code, which does allow it to do practically anything. In my experience, Claude only used R to run tests or documentation.

I also experimented with using Claude Code to review PRs. It was just barely useful enough that I kept it turned on for my own PRs, but I didn't bother trying to get it to work for contributed PRs. Most of the time it either gave a thumbs up or bad advice, but every now and then it would pick up a small error.

(I've also used Claude Code to proofread this blog post!)

## Lifecycle changes

The biggest change in this release is that [`local_mock()`](https://testthat.r-lib.org/reference/with_mock.html) and [`with_mock()`](https://testthat.r-lib.org/reference/with_mock.html) are defunct. They were deprecated in 3.0.0 (2020-10-31) because it was becoming clear that the technique that made them work would be disallowed in a future version of R. This has now happened in R 4.5.0, so the functions have been removed. Removing [`local_mock()`](https://testthat.r-lib.org/reference/with_mock.html) and [`with_mock()`](https://testthat.r-lib.org/reference/with_mock.html) was a fairly disruptive change, affecting ~100 CRAN packages, but it had to be done, and I've been working on notifying package developers since January so everyone had plenty of time to update. Fortunately, the needed changes are generally small, since the newer [`local_mocked_bindings()`](https://testthat.r-lib.org/reference/local_mocked_bindings.html) and [`with_mocked_bindings()`](https://testthat.r-lib.org/reference/local_mocked_bindings.html) can solve most additional needs. (If you haven't heard of mocking before, you can read the new `vignette("mocking")` to learn what it is and why you might want to use it.)

Other lifecycle changes:

-   testthat now requires R 4.1. This follows [our supported version policy](https://tidyverse.org/blog/2019/04/r-version-support/), which documents our commitment to support five versions of R (the current version and four previous versions). We're excited to be able to finally take advantage of the base pipe and compact anonymous functions (i.e. `\(x) x + 1`)!

-   `is_null()`/`matches()`, deprecated in 2.0.0 (2017-12-19), and `is_true()`/`is_false()`, deprecated in 2.1.0 (2019-04-23), have been removed. These conflicted with other tidyverse functions so we pushed their deprecation through, even though we have generally left the old [`test_that()`](https://testthat.r-lib.org/reference/test_that.html) API untouched.

-   `expect_snapshot(binary)`, soft deprecated in 3.0.3 (2021-06-16), is now fully deprecated. `test_files(wrap)`, deprecated in 3.0.0 (2020-10-31), has now been removed.

-   There were a few other changes that broke existing packages. The most impactful change was to start checking the inputs to [`expect()`](https://testthat.r-lib.org/reference/expect.html) which, despite the name, is actually an internal helper. That revealed a surprising number of packages were accidentally using [`expect()`](https://testthat.r-lib.org/reference/expect.html) instead of [`expect_true()`](https://testthat.r-lib.org/reference/logical-expectations.html) or [`expect_equal()`](https://testthat.r-lib.org/reference/equality-expectations.html). We don't technically consider this a breaking change because it revealed off-label function usage: the function API hasn't changed; you just now learn when you're using it incorrectly.

If you're interested in the process we use to manage the release of a package that breaks its reverse dependencies, you might like to read [the issue](https://github.com/r-lib/testthat/issues/2021) where I track all the problems and prepare PRs to fix them.

## Expectations and the interactive testing experience

A lot of work in this release was prompted by an overhaul of `vignette("custom-expectations")`, which describes how to create your own expectations that work just like testthat's. This is a long time coming, and as I was working on it, I realized that I didn't really know how to write new expectations, which had led to a lot of variation in the existing implementations. This kicked off a bunch of experimentation and iterating, leading to a swath of improvements:

-   All expectations have new failure messages: they now state what was expected, what was actually received, and, if possible, they clearly illustrate the difference.

-   Expectations now consistently return the value of the first argument, regardless of whether the expectation succeeds or fails (the only exception is [`expect_error()`](https://testthat.r-lib.org/reference/expect_error.html) and friends which return the captured condition so that you can perform additional checks on the condition object). This is a relatively subtle change that won't affect tests that already pass, but it does improve failures when you pipe together multiple expectations.

-   A new [`pass()`](https://testthat.r-lib.org/reference/fail.html) function makes it clear how to signal when an expectation succeeds. All existing expectations were rewritten to use [`pass()`](https://testthat.r-lib.org/reference/fail.html) and (the existing) [`fail()`](https://testthat.r-lib.org/reference/fail.html) instead of [`expect()`](https://testthat.r-lib.org/reference/expect.html), which I think makes the flow of logic easier to understand.

-   Improved [`expect_success()`](https://testthat.r-lib.org/reference/expect_success.html) and [`expect_failure()`](https://testthat.r-lib.org/reference/expect_success.html) expectations now test that an expectation always returns exactly one success or failure (this ensures that the counts that you see in the reporters are correct).

This new framework helped us write six new expectations:

-   [`expect_all_equal()`](https://testthat.r-lib.org/reference/expect_all_equal.html), [`expect_all_true()`](https://testthat.r-lib.org/reference/expect_all_equal.html), and [`expect_all_false()`](https://testthat.r-lib.org/reference/expect_all_equal.html) check that every element of a vector has the same value, giving better error messages than `expect_true(all(...))`:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"some test"</span>, <span class='o'>&#123;</span></span>
    <span>  <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>0.408</span>, <span class='m'>0.961</span>, <span class='m'>0.883</span>, <span class='m'>0.46</span>, <span class='m'>0.537</span>, <span class='m'>0.961</span>, <span class='m'>0.851</span>, <span class='m'>0.887</span>, <span class='m'>0.023</span><span class='o'>)</span></span>
    <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_all_equal.html'>expect_all_true</a></span><span class='o'>(</span><span class='nv'>x</span> <span class='o'>&lt;</span> <span class='m'>0.95</span><span class='o'>)</span></span>
    <span><span class='o'>&#125;</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; ── <span style='color: #BBBB00; font-weight: bold;'>Failure</span><span style='font-weight: bold;'>: some test</span> ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────</span></span>
    <span><span class='c'>#&gt; Expected every element of `x &lt; 0.95` to equal TRUE.</span></span>
    <span><span class='c'>#&gt; Differences:</span></span>
    <span><span class='c'>#&gt; `actual`:   <span style='color: #555555;'>TRUE</span> <span style='color: #00BB00;'>FALSE</span> <span style='color: #555555;'>TRUE</span> <span style='color: #555555;'>TRUE</span> <span style='color: #555555;'>TRUE</span> <span style='color: #00BB00;'>FALSE</span> <span style='color: #555555;'>TRUE</span> <span style='color: #555555;'>TRUE</span> <span style='color: #555555;'>TRUE</span></span></span>
    <span><span class='c'>#&gt; `expected`: <span style='color: #555555;'>TRUE</span> <span style='color: #00BB00;'>TRUE</span>  <span style='color: #555555;'>TRUE</span> <span style='color: #555555;'>TRUE</span> <span style='color: #555555;'>TRUE</span> <span style='color: #00BB00;'>TRUE</span>  <span style='color: #555555;'>TRUE</span> <span style='color: #555555;'>TRUE</span> <span style='color: #555555;'>TRUE</span></span></span>
    <span></span><span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Test failed with 1 failure and 0 successes.</span></span>
    <span></span></code></pre>

    </div>

-   [`expect_disjoint()`](https://testthat.r-lib.org/reference/expect_setequal.html), by [@stibu81](https://github.com/stibu81), expects values to be absent:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>""</span>, <span class='o'>&#123;</span></span>
    <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_setequal.html'>expect_disjoint</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"c"</span>, <span class='s'>"d"</span>, <span class='s'>"e"</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='o'>&#125;</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; ── <span style='color: #BBBB00; font-weight: bold;'>Failure</span><span style='font-weight: bold;'>: </span> ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────</span></span>
    <span><span class='c'>#&gt; Expected `c("a", "b", "c")` to be disjoint from `c("c", "d", "e")`.</span></span>
    <span><span class='c'>#&gt; Actual: "a", "b", "c"</span></span>
    <span><span class='c'>#&gt; Expected: None of "c", "d", "e"</span></span>
    <span><span class='c'>#&gt; Invalid: "c"</span></span>
    <span></span><span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Test failed with 1 failure and 0 successes.</span></span>
    <span></span></code></pre>

    </div>

-   [`expect_r6_class()`](https://testthat.r-lib.org/reference/inheritance-expectations.html) expects an R6 object:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>""</span>, <span class='o'>&#123;</span></span>
    <span>  <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='m'>10</span></span>
    <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/inheritance-expectations.html'>expect_r6_class</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"foo"</span><span class='o'>)</span></span>
    <span></span>
    <span>  <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'>R6</span><span class='nf'>::</span><span class='kr'><a href='https://r6.r-lib.org/reference/R6Class.html'>R6Class</a></span><span class='o'>(</span><span class='s'>"bar"</span><span class='o'>)</span><span class='o'>$</span><span class='nf'>new</span><span class='o'>(</span><span class='o'>)</span></span>
    <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/inheritance-expectations.html'>expect_r6_class</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='s'>"foo"</span><span class='o'>)</span></span>
    <span><span class='o'>&#125;</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; ── <span style='color: #BBBB00; font-weight: bold;'>Failure</span><span style='font-weight: bold;'>: </span> ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────</span></span>
    <span><span class='c'>#&gt; Expected `x` to be an R6 object.</span></span>
    <span><span class='c'>#&gt; Actual OO type: none.</span></span>
    <span><span class='c'>#&gt; ── <span style='color: #BBBB00; font-weight: bold;'>Failure</span><span style='font-weight: bold;'>: </span> ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────</span></span>
    <span><span class='c'>#&gt; Expected `x` to inherit from "foo".</span></span>
    <span><span class='c'>#&gt; Actual class: "bar"/"R6".</span></span>
    <span></span><span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Test failed with 2 failures and 0 successes.</span></span>
    <span></span></code></pre>

    </div>

-   [`expect_shape()`](https://testthat.r-lib.org/reference/expect_length.html), by [@michaelchirico](https://github.com/michaelchirico), expects a specific shape (i.e., [`nrow()`](https://rdrr.io/r/base/nrow.html), [`ncol()`](https://rdrr.io/r/base/nrow.html), or [`dim()`](https://rdrr.io/r/base/dim.html)):

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"show off expect_shape() failure messages"</span>, <span class='o'>&#123;</span></span>
    <span>  <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/matrix.html'>matrix</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>:</span><span class='m'>9</span>, nrow <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span></span>
    <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_length.html'>expect_shape</a></span><span class='o'>(</span><span class='nv'>x</span>, nrow <span class='o'>=</span> <span class='m'>4</span><span class='o'>)</span></span>
    <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_length.html'>expect_shape</a></span><span class='o'>(</span><span class='nv'>x</span>, dim <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>3</span>, <span class='m'>3</span>, <span class='m'>3</span><span class='o'>)</span><span class='o'>)</span></span>
    <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_length.html'>expect_shape</a></span><span class='o'>(</span><span class='nv'>x</span>, dim <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>3</span>, <span class='m'>4</span><span class='o'>)</span><span class='o'>)</span></span>
    <span><span class='o'>&#125;</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; ── <span style='color: #BBBB00; font-weight: bold;'>Failure</span><span style='font-weight: bold;'>: show off expect_shape() failure messages</span> ──────────────────────────────────────────────────────────────────────────────────────────────────────</span></span>
    <span><span class='c'>#&gt; Expected `x` to have 4 rows.</span></span>
    <span><span class='c'>#&gt; Actual rows: 3.</span></span>
    <span><span class='c'>#&gt; ── <span style='color: #BBBB00; font-weight: bold;'>Failure</span><span style='font-weight: bold;'>: show off expect_shape() failure messages</span> ──────────────────────────────────────────────────────────────────────────────────────────────────────</span></span>
    <span><span class='c'>#&gt; Expected `x` to have 3 dimensions.</span></span>
    <span><span class='c'>#&gt; Actual dimensions: 2.</span></span>
    <span><span class='c'>#&gt; ── <span style='color: #BBBB00; font-weight: bold;'>Failure</span><span style='font-weight: bold;'>: show off expect_shape() failure messages</span> ──────────────────────────────────────────────────────────────────────────────────────────────────────</span></span>
    <span><span class='c'>#&gt; Expected `x` to have dim (3, 4).</span></span>
    <span><span class='c'>#&gt; Actual dim: (3, 3).</span></span>
    <span></span><span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'>:</span></span></span>
    <span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Test failed with 3 failures and 0 successes.</span></span>
    <span></span></code></pre>

    </div>

As you can see from the examples above, when you run a single test interactively (i.e. not as a part of a test suite) you now see exactly how many expectations succeeded and failed.

## Other new features

-   testthat generally does a better job of handling nested tests, aka subtests, where you put a [`test_that()`](https://testthat.r-lib.org/reference/test_that.html) inside another [`test_that()`](https://testthat.r-lib.org/reference/test_that.html), or more typically [`it()`](https://testthat.r-lib.org/reference/describe.html) inside of [`describe()`](https://testthat.r-lib.org/reference/describe.html). Subtests will now generate more informative failure messages, free from duplication, with more informative skips if any subtests don't contain any expectations.

-   The snapshot experience has been significantly improved, with all known bugs fixed and some new helpers added: [`snapshot_reject()`](https://testthat.r-lib.org/reference/snapshot_accept.html) rejects all modified snapshots by deleting the `.new` variants, and [`snapshot_download_gh()`](https://testthat.r-lib.org/reference/snapshot_download_gh.html) makes it easy to get snapshots off GitHub and into your local package. Additionally, [`expect_snapshot()`](https://testthat.r-lib.org/reference/expect_snapshot.html) and friends will now fail when creating a new snapshot on CI, as that's usually a signal that you've forgotten to run the snapshot code locally before committing.

-   On CRAN, [`test_that()`](https://testthat.r-lib.org/reference/test_that.html) will automatically skip if a package is not installed, which means that you no longer need to check if suggested packages are installed in your tests.

-   `vignette("mocking")` explains mocking in detail, and new [`local_mocked_s3_method()`](https://testthat.r-lib.org/reference/local_mocked_s3_method.html), [`local_mocked_s4_method()`](https://testthat.r-lib.org/reference/local_mocked_s3_method.html), and [`local_mocked_r6_class()`](https://testthat.r-lib.org/reference/local_mocked_r6_class.html) make it easier to mock S3 and S4 methods and R6 classes.

-   [`test_dir()`](https://testthat.r-lib.org/reference/test_dir.html), [`test_check()`](https://testthat.r-lib.org/reference/test_package.html), and friends gain a `shuffle` argument that uses [`sample()`](https://rdrr.io/r/base/sample.html) to randomly reorder the top-level expressions in each test file. This random reordering surfaces dependencies between tests and code outside of any test, as well as dependencies between tests, helping you find and eliminate unintentional dependencies.

-   [`try_again()`](https://testthat.r-lib.org/reference/try_again.html) is now publicized, as it's a useful tool for testing flaky code:

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>flaky_function</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
      <span>  <span class='kr'>if</span> <span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/stats/Uniform.html'>runif</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span> <span class='o'>&lt;</span> <span class='m'>0.1</span><span class='o'>)</span> <span class='m'>0</span> <span class='kr'>else</span> <span class='m'>1</span></span>
      <span><span class='o'>&#125;</span></span>
      <span></span>
      <span><span class='c'># 10% chance of failure:</span></span>
      <span><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"my flaky test is ok"</span>, <span class='o'>&#123;</span></span>
      <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/skip.html'>skip_on_cran</a></span><span class='o'>(</span><span class='o'>)</span></span>
      <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nf'>flaky_function</span><span class='o'>(</span><span class='o'>)</span>, <span class='m'>1</span><span class='o'>)</span></span>
      <span><span class='o'>&#125;</span><span class='o'>)</span></span>
      <span></span>
      <span><span class='c'># 1% chance of failure:</span></span>
      <span><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"my flaky test is ok"</span>, <span class='o'>&#123;</span></span>
      <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/skip.html'>skip_on_cran</a></span><span class='o'>(</span><span class='o'>)</span></span>
      <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/try_again.html'>try_again</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nf'>flaky_function</span><span class='o'>(</span><span class='o'>)</span>, <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span></span>
      <span><span class='o'>&#125;</span><span class='o'>)</span></span>
      <span></span>
      <span><span class='c'># 0.1% chance of failure:</span></span>
      <span><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"my flaky test is ok"</span>, <span class='o'>&#123;</span></span>
      <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/skip.html'>skip_on_cran</a></span><span class='o'>(</span><span class='o'>)</span></span>
      <span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/try_again.html'>try_again</a></span><span class='o'>(</span><span class='m'>2</span>, <span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nf'>flaky_function</span><span class='o'>(</span><span class='o'>)</span>, <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span></span>
      <span><span class='o'>&#125;</span><span class='o'>)</span></span></code></pre>

    </div>

    Note that it's still good practice to skip such tests on CRAN.

-   New [`skip_unless_r()`](https://testthat.r-lib.org/reference/skip.html) skips tests on unsuitable versions of R. It has a convenient syntax so you can use, e.g., `skip_unless_r(">= 4.1.0")` to skip tests that require [`...names()`](https://rdrr.io/r/base/dots.html).

-   New `SlowReporter` makes it easier to find the slowest tests in your package. You can run it with `devtools::test(reporter = "slow")`.

-   New `vignette("challenging-functions")` provides an index to other documentation organized by various challenges.

## Acknowledgements

A big thank you to all the folks who helped make this release happen: [@3styleJam](https://github.com/3styleJam), [@afinez](https://github.com/afinez), [@andybeet](https://github.com/andybeet), [@atheriel](https://github.com/atheriel), [@averissimo](https://github.com/averissimo), [@d-morrison](https://github.com/d-morrison), [@DanChaltiel](https://github.com/DanChaltiel), [@DanielHermosilla](https://github.com/DanielHermosilla), [@eitsupi](https://github.com/eitsupi), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@emstruong](https://github.com/emstruong), [@gaborcsardi](https://github.com/gaborcsardi), [@gael-millot](https://github.com/gael-millot), [@hadley](https://github.com/hadley), [@hoeflerb](https://github.com/hoeflerb), [@jamesfowkes](https://github.com/jamesfowkes), [@jan-swissre](https://github.com/jan-swissre), [@jdblischak](https://github.com/jdblischak), [@jennybc](https://github.com/jennybc), [@jeroenjanssens](https://github.com/jeroenjanssens), [@kevinushey](https://github.com/kevinushey), [@krivit](https://github.com/krivit), [@kubajal](https://github.com/kubajal), [@lawalter](https://github.com/lawalter), [@m-muecke](https://github.com/m-muecke), [@maelle](https://github.com/maelle), [@math-mcshane](https://github.com/math-mcshane), [@mcol](https://github.com/mcol), [@metanoid](https://github.com/metanoid), [@MichaelChirico](https://github.com/MichaelChirico), [@moodymudskipper](https://github.com/moodymudskipper), [@njtierney](https://github.com/njtierney), [@nunotexbsd](https://github.com/nunotexbsd), [@pabangan](https://github.com/pabangan), [@pachadotdev](https://github.com/pachadotdev), [@plietar](https://github.com/plietar), [@schloerke](https://github.com/schloerke), [@schuemie](https://github.com/schuemie), [@sebkopf](https://github.com/sebkopf), [@shikokuchuo](https://github.com/shikokuchuo), [@snystrom](https://github.com/snystrom), [@stibu81](https://github.com/stibu81), [@TimTaylor](https://github.com/TimTaylor), and [@tylermorganwall](https://github.com/tylermorganwall).

