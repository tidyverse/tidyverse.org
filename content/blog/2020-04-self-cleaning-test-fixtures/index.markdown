---
title: Self-cleaning test fixtures
author: Jenny Bryan
date: '2020-04-23'
slug: self-cleaning-test-fixtures
categories:
  - programming
  - learn
tags:
  - r-lib
description: |
  A 2-3 sentence description of the post that appears on the articles page.
photo:
  url: https://
  author: Jenny Bryan
---



TODO: write an intro

##  Don't be a slob

> Take nothing but memories, leave nothing but footprints.

― Chief Si ahl

Ideally a test should leave the world exactly as it found it. Examples of things you might do inside a test and, therefore, need to undo:

* Create a file or directory
* Create a resource on an external system
* Set an R option
* Set an environment variable
* Change working directory
* Change an aspect of the tested package's state

Scrupulous attention to cleanup is more than just courtesy or being fastidious. It is also self-serving. The state of the world after test `i` is the starting state for test `i + 1`. Tests that change state willy-nilly eventually end up interfering with each other in ways that can be very difficult to debug. Most tests are written with an **implicit** assumption about the starting state, usually whatever *tabula rasa* means for the target domain of your package. If you accumulate enough sloppy tests, I promise you that eventually some leftover piece of litter will cause (something something something).

> Using Microsoft word *moves picture 3mm left* All text shifts, four new pages appear, paragraph breaks form a union, in the distance, sirens.

— Amy Schwartz (schwartzanegger) February 11, 2016

<http://ctrlq.org/first/102402-word-moves-distance-sirens/>

##  The `on.exit()` mentality

If you want to clean up after yourself, how should you actually do it?

The first function to know about is base R's [`on.exit()`](https://rdrr.io/r/base/on.exit.html). You use it inside a function. In the function body, every time you do something that should be undone "on exit", you immediately register the cleanup code with `on.exit(expr, add = TRUE)`. *It's too bad `add = TRUE` isn't the default, but you almost always want this. Without it, each call to `on.exit()` clobbers the effect of previous calls.*

Here's a `sloppy()` function that changes the `digits` option.




```r
sloppy <- function(x) {
  options(digits = 2)
  print(x)
}

pi
#> [1] 3.141593

sloppy(pi)
#> [1] 3.1

pi
#> [1] 3.1
```



Notice how `pi` prints differently before and after the call to `sloppy()`. Calling `sloppy()` has a side effect: it changes the `digits` option.

*Don't worry, I'm restoring global state behind the scenes here.*

Here's how to do better with `on.exit()`.


```r
neat <- function(x) {
  op <- options(digits = 2)
  on.exit(options(op), add = TRUE)
  print(x)
}

pi
#> [1] 3.141593

neat(pi)
#> [1] 3.1

pi
#> [1] 3.141593
```

The use of `on.exit()` ensures that `neat()` leaves `digits` the way that it found it. `on.exit()` also works when you exit the function abnormally, i.e. due to error. This is why it's a better choice than any do-it-yourself solution.

But this post is about tests! Never fear, `on.exit()` also works inside a test.


```r
exp(1)
#> [1] 2.718282

testthat::test_that("on.exit() works in a test", {
  op <- options(digits = 2)
  on.exit(options(op), add = TRUE)
  print(exp(1))
})
#> [1] 2.7

exp(1)
#> [1] 2.718282
```

<https://adv-r.hadley.nz/functions.html#on-exit>

`on.exit()` is a very useful function and provides enough inspiration for an entire package: withr ([withr.r-lib.org](http://withr.r-lib.org)), which is a Swiss army knife for managing state in very flexible ways. It's what I usually use, in functions and tests, for situations like that above.

##  Test fixtures

Testing is often demonstrated with cute little tests and functions where all the inputs and expected results can be inlined. But in real packages, things aren't always so simple. The main functions in your package probably aren't "1 number in, 1 number out". They might require more exotic objects or very specific circumstances. Their entire purpose might be to change state! Now what?

Obligatory caveat: If you find it hard to write tests, this may indicate that your package has some design problems. Maybe you've somehow ended up with a small number of monster functions, with oodles of arguments, that can do everything from scrambling eggs to changing a lightbulb. The best move in this case may be to break things up into smaller and simpler functions. And those will be easier to test. End caveat.

Tricky test situations can't always be eliminated by better package design. ?Something about [essential complexity](https://en.wikipedia.org/wiki/Essential_complexity)? Let's assume you've got a reasonable design and you're still stuck with some tricky test dilemmas. Unless you find a way to make writing tests as pleasant as possible, you won't write nearly enough.

One technique I've found useful is what I'll call a "scoped temporary test fixture".

### usethis and temporary packages/projects

The usethis package ([usethis.r-lib.org](https://usethis.r-lib.org)) provides many functions for looking after the files and folders in R projects, especially R packages. The self-explanatory function names suggest what usethis does: `create_package()`, `use_vignette()`, `use_testthat()`, `use_github()`. Many of these functions only make sense in the context of an R package. That means in order to test them, we have to be working inside an R package.

We need a way to quickly spin up a basic package, in the session temp directory. Test some functions against it. Then destroy it. We need a **scoped temporary package**. "Scoped" here refers to the fact that the package lives only for the span of a test.

I give you `scoped_temporary_package()` (simplified for exposition):


```r
scoped_temporary_package <- function(dir = file_temp(), env = parent.frame()) {
  old_project <- proj_get_()            # --- Defer The Undoing ---
  withr::defer({                        # restore original ...
    proj_set(old_project, force = TRUE) #   * active usethis project    (-C)
    setwd(old_project)                  #   * working directory         (-B)
    fs::dir_delete(dir)                 # delete the package's folder   (-A)
  }, envir = env)
                                        # --- Do The Doing ---      
  create_package(dir, open = FALSE)     # create new folder and package (A)
  setwd(dir)                            # change working directory      (B)
  proj_set(dir)                         # switch to new usethis project (C)
  invisible(dir)
}
```

Here's how `scoped_temporary_package()` looks in actual use:


```r
# TODO: write this chunk
```

A few things are worth noting:

  * `scoped_temporary_package()` is a test helper, defined in
    `tests/testthat/helper.R`. It is available universally within usethis's
    testthat tests.
  * It would be aggravating and repetitive to inline this setup and teardown in
    each individual test. The tests would be dominated by this code, making them
    less readable. If we need to tweak something, we'll need to do that in
    177 different places (that's the actual count!). This sort of friction has a
    real chilling effect on one's enthusiasm for writing and maintaining tests.
  * `withr::defer()` plays the role of `on.exit()`. It's how we schedule
    expressions for evaluation when the calling frame (the one associated with
    the test) goes out of scope.
  * Every action has an equal and opposite reaction. Each individual "doing"
    action (A, B, C) has a deferred, companion "undoing" reaction (-A, -B, -C).
  * The undoing is put in place before the doing and usually unfolds in the
    opposite order. If you make separate calls to `withr::defer()`, use the
    `priority` argument to indicate where to place the new `expr` relative to
    the existing list. The `after` argument of `on.exit()` has a similar
    purpose. Both `withr::defer()` and `on.exit()` default to the most common case, which is "last in first out" stack behaviour.

## TODOs

Pick a real photo

`scoped_temporary_ss()` from googlesheets

Do I have other examples of `scoped_temporary_WHATEVER()`? I certainly use withr a lot in tests. Any general observations?

Why withr instead of `on.exit()`?

  * Default `add = TRUE` behaviour.
  * Works on any env, not just (whatever `on.exit()` actually works on, which we need to state precisely but approachably).
  * The `local_*()` variants.
  * The `with_*()` variants.
  * Ability to defer on global env facilitates development.
  
Other thoughts:

  * Same mentality makes sense in other contexts, like examples. But hard to implement within CRAN guidelines.
  * Gee Paw has some interesting ?tweets? or ?posts? about creating test fixtures.
