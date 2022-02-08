---
output: hugodown::hugo_document

slug: upkeep-testthat-3
title: Upkeep - Upgrading to testthat edition 3
date: 2022-02-08
author: Hannah Frick
description: >
    Guidance for keeping your package up to date with tidyverse standards, in 
    particular upgrading to testthat edition 3.

photo:
  url: https://unsplash.com/photos/46juD4zY1XA
  author: David Pisnoy

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn] 
tags: [usethis, devtools]
rmd_hash: e3aefd83b0ef8334

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
* [ ] ~Add intro sentence, e.g. the standard tagline for the package~
* [ ] ~[`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)~
-->

On the tidymodels team, I split time between new things like the [censored package for survival analysis](https://www.tidyverse.org/blog/2021/11/survival-analysis-parsnip-adjacent/) and keeping the existing packages in good shape.

## Upkeep of tidy packages

As the collection of packages grows, maintenance becomes increasingly important. Hadley Wickham made it the topic of his [keynote at rstudio::global 2021](https://www.rstudio.com/resources/rstudioglobal-2021/maintaining-the-house-the-tidyverse-built/). The [usethis](https://usethis.r-lib.org/) package provides tools for the workflows when working on tidyverse, r-lib, or tidymodels packages and as such contains the set of labels used to categorize GitHub issues. Day-to-day maintenance is captured via the `"upkeep"` label for "maintenance, infrastructure, and similar". For bigger efforts, `use_tidy_upkeep_issue()` creates an issue containing a checklist of actions to bring a package up to current tidyverse standards.

![A GitHub issue with a checklist of upkeep tasks](upkeep-issue.png)

## testthat 3e

One of the items on this checklist is to use testthat edition 3. The testthat package introduced the idea of an "edition" in version 3.0.0:

> An edition is a bundle of behaviours that you have to explicitly choose to use, allowing us to make otherwise backward incompatible changes.

While you can continue to use testthat's previous behaviour, it is recommended to upgrade so that you can make use of handy new features. As some of the changes may break your tests, you might have been putting that off though? You would not be alone in that! Several tidymodels packages still have to make the jump but I recently upgraded [dials](https://github.com/tidymodels/dials/) and [censored](https://github.com/tidymodels/censored/) to testthat edition 3. Here is what I did and learned along the way.

### Workflow to upgrade

First off, the [testthat article introducing the 3rd edition](https://testthat.r-lib.org/articles/third-edition.html) is very helpful. I'd recommend reading that if you haven't yet!

It tells you how you can opt in to the new edition, and about major changes: deprecations, how comparisons are made, and how messages and warnings are handled.

This already gives you the main guidance for a workflow:

1.  Activate edition 3.
2.  Remove or replace deprecated functions.
3.  If your output got noisy, quiet things down as needed.
4.  The harder part: think about what it means if things are not "all equal" anymore.

### Activation 🚀

To activate you need to do two things in the DESCRIPTION - or you can let `usethis::use_testthat(3)` do it for you: - Increase the testthat version to `>= 3.0.0`. - Set the `Config/testthat/edition` field to `3`.

### Moving on from deprecations ✨

The article on testthat 3e contains a [list of deprecated functions](https://testthat.r-lib.org/articles/third-edition.html#deprecations) together with their successors. You can work your way through it, searching for the deprecated function and then replacing it with the most suitable alternative.

### Warnings and messages 🤫

Edition 3 handles warnings and messages differently than edition 2: `expect_warning()` captures at most one warning so if your code generates multiple warnings, they will bubble up now. Messages were previously silently ignored, now they also bubble up. That means the output may be a lot noisier after switching to edition 3. If the warnings or messages are important, you should explicitly capture them. Otherwise you can suppress them to clean up the output and make it easier to focus on what's important. Again, the testthat article has good examples for how to do either.

As an illustration of that workflow, my first commits when upgrading censored looked like this

![A list of commits starting with "require testthat 3e"](commits.png)

### Comparing things 🍎 🍊

The last big change from edition 2 to edition 3 that I want to mention is what is happening under the hood of `expect_equal()` and `expect_identical()`. Edition 3 uses [`waldo::compare()`](https://waldo.r-lib.org/reference/compare.html) while edition 2 uses [`all.equal()`](https://rdrr.io/r/base/all.equal.html). For the most part that meant changing the argument name from `tol` to `tolerance`, like in my third commit above.

I did however run into the situation where a test newly failed. Those are the situations where general advise is hard because it depends so much on the context. In my case, I made use of the `ignore_function_env` and `ignore_formula_env` arguments to [`waldo::compare()`](https://waldo.r-lib.org/reference/compare.html) to exclude those environments from the comparison. Those are probably really neat to know about if you are upgrading a modelling package but not particularly important otherwise. For dials and censored, that solved most of the cases. In one instance, I ended up tweaking the reference value based on theoretical considerations of the model I was dealing with rather than increasing the tolerance.

Those instances may be the most work when upgrading to edition 3 but I did not encounter many of them - and when I did it was valuable to know about the differences (well, those which I didn't choose to ignore).

## More testing made easier

While I was going over all the test files, I also decided to cover a few other aspects.

### Nested expectations

When [Davis Vaughan](https://github.com/DavisVaughan) moved other tidymodels packages to testthat 3e, I saw him disentangle nested expectations. For example, patterns like

``` r
expect_warning(expect_equal(one_call, another_call))
```

or

``` r
expect_equal(expect_warning(one_call), expect_warning(another_call))
```

can be re-written as

``` r
expect_snapshot({
    object_from_one_call <- one_call()
    object_from_another_call <- another_call()
})
expect_equal(object_from_one_call, object_from_another_call)
```

which separates an expectation about the warnings from the expectation about the value, making it easier to see which part(s) fail. Snapshots can also be particularly helpful in situations where you are trying to test for a combination of warnings, messages, and/or errors because they cover them all.

### Self-contained tests

I wanted to make the tests more self-contained so that a test could run with a single call to `test_that()`. Specifically, I didn't want to have to scroll back up to the top of the file to load any necessary package or find the code that creates helper objects.

Namespacing functions helps with the former, i.e. using [`dplyr::mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) instead of [`library(dplyr)`](https://dplyr.tidyverse.org) at the top of the file and later `mutate()` inside of the expression for `test_that()`.

If creating a helper object is short, I might move the code inside of `test_that()`. If you create the same helper objects multiple times and don't want to see the code repeatedly, you can move it into a helper function. Files inside the `testthat` folder of your source code with file names starting with `helper` are executed before tests are run. You could put your helper code there but it is [recommended](https://testthat.r-lib.org/reference/test_file.html#special-files) to put the helper code in your `R/` folder, for example as [`test-helpers.R`](https://testthat.r-lib.org/articles/custom-expectation.html).

An example helper function is called `make_test_model()` and returns a list with training and testing data as well as the fitted model. A test on the prediction method could then look like this

``` r
test_that("prediction returns the correct number of records", {
    helper_objects <- make_test_model()
    pred <- predict(helper_objects$model, helper_objects$test_data)
    expect_equal(nrow(pred), nrow(helper_objects$test_data))
})
```

Any other data objects needed for testing I moved into `tests/testthat/data/`.

### Corresponding files in `R/` and `tests/testthat/`

If a file in `R/` had a corresponding file in `testthat/`, I made sure the names matched up, e.g., `monstera.R` and `test-monstera.R`.

This gives you access to some convenient features of usethis and devtools:

-   When you have the R file open, it's easy to open the corresponding test file with [`usethis::use_test()`](https://usethis.r-lib.org/reference/use_r.html) - and vice versa with [`usethis::use_r()`](https://usethis.r-lib.org/reference/use_r.html). No clicking around needed!
-   When you have either file open, you can run the tests with [`devtools:::test_active_file()`](http://devtools.r-lib.org/reference/test.html) and see the test coverage report with `test_coverage_active_file()` (which also shows you which lines are actually being tested). Both also have an RStudio addin which means you can add a [keyboard shortcut](https://rstudio.github.io/rstudioaddins/#keyboard-shorcuts) for them!

And with that dials and censored were ready for more snapshot tests in the future!

