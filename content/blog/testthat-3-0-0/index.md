---
output: hugodown::hugo_document

slug: testthat-3-0-0
title: testthat 3.0.0
date: 2020-10-08
author: Hadley Wickham
description: >
    testhat 3.0.0 brings a raft of major improvements including snapshot 
    testing and parallel testing. It also includes a new "edition" that
    allows you opt-in to a set of substantial improvements that are
    not backward compatible.

photo:
  url: https://unsplash.com/photos/209FvE_57H8
  author: NeONBRAND

categories: [package] 
tags: [testthat]
rmd_hash: 029750c8dccd37d4

---

We're tickled pink to announce the release of [testthat](http://testthat.r-lib.org/) 3.0.0. testthat makes it easy to turn your existing informal tests into formal automated tests that you can rerun quickly and easily. testthat is the most popular unit-testing package for R, and is used by over 5,000 CRAN and Bioconductor packages. You can learn more about unit testing at <a href="https://r-pkgs.org/tests.html" class="uri">https://r-pkgs.org/tests.html</a>.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"testthat"</span><span class='o'>)</span>
</code></pre>

</div>

In this blog post, I want to discuss the two biggest changes: the introduction of the edition, which allows us to make breaking changes that you have to specifically opt-in to, and a new family of "snapshot" tests. I'll also give a quick round of the other major changes, but you might also want to look at the [release notes](%7B%20github_release%20%7D) for the full details.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://testthat.r-lib.org'>testthat</a></span><span class='o'>)</span>
</code></pre>

</div>

3rd edition
-----------

testthat 3.0.0 introduces the idea of an **edition**. An edition is a bundle of behaviours that you have to explicitly choose to use, allowing us to make backward incompatible changes. This is particularly important for testthat since it's used by a very large number of packages, and it includes a few design infelicities that we want to fix. Choosing to use the 3rd edition allows you to use our latest recommendations for ongoing and new work, while historical packages continue to use the old behaviour. To use it, and this line to your `DESCRIPTION`:

    Config/testthat/edition: 3

The second edition will never go away, but new features will only appear in the 3rd edition. We don't anticipate creating new editions very often (maybe once every 5 years at most), and they'll always be paired with a new major version of testthat, i.e. if there's another edition, it'll be the 4th edition and will come with testthat 4.0.0.

The full details of the 3rd edition are described in [`vignette("third-edition", package = "testthat")`](https://testthat.r-lib.org/articles/third-edition.html). If you're a heavy testthat user, I strongly recommend reading the vignette. Here are the most important changes:

-   [`context()`](https://testthat.r-lib.org/reference/context.html) is now deprecated. It hasn't been recommended for some time since it usually duplicates data also present in the file name.

-   [`expect_identical()`](https://testthat.r-lib.org/reference/equality-expectations.html) and [`expect_equal()`](https://testthat.r-lib.org/reference/equality-expectations.html) use [`waldo::compare()`](https://rdrr.io/pkg/waldo/man/compare.html) to compare actual and expected results. This should give considerably more informative output for test failures, but [`waldo::compare()`](https://rdrr.io/pkg/waldo/man/compare.html) is not 100% compatible with [`all.equal()`](https://rdrr.io/r/base/all.equal.html) (which previously powered [`expect_equal()`](https://testthat.r-lib.org/reference/equality-expectations.html)). There are a few differences due a bug in testthat's comparison of floating point values and subtle differences when comparing environments stored in attributes (common in modelling functions); see the vignette for full details.

    [`expect_equivalent()`](https://testthat.r-lib.org/reference/expect_equivalent.html) is now deprecated because it's equivalent to [`expect_equal(ignore_attr = TRUE)`](https://testthat.r-lib.org/reference/equality-expectations.html) (which is generally not recommended, anyway, because it's such a blunt tool).

-   [`expect_error()`](https://testthat.r-lib.org/reference/expect_error.html), [`expect_warning()`](https://testthat.r-lib.org/reference/expect_error.html), [`expect_message()`](https://testthat.r-lib.org/reference/expect_error.html), and [`expect_condition()`](https://testthat.r-lib.org/reference/expect_error.html) now all use the same underlying logic: they capture the first condition that matches `class`/`regexp` and allow anything else to bubble up. This behaviour pairs particularly well with upcoming changes to the pipe in [magrittr 2.0.0](/blog/2020/08/magrittr-2-0/).

-   Messages are no longer automatically silenced. You'll now need to use [`suppressMessages()`](https://rdrr.io/r/base/message.html) to hide unimportant messages or `expect_messsage()` to catch important messages.

-   [`test_that()`](https://testthat.r-lib.org/reference/test_that.html) now sets a number of options and env vars to make output as reproducible as possible. Many of these options were previously set in various places (including [`devtools::test()`](https://devtools.r-lib.org//reference/test.html), [`test_dir()`](https://testthat.r-lib.org/reference/test_dir.html), [`test_file()`](https://testthat.r-lib.org/reference/test_file.html), and [`verify_output()`](https://testthat.r-lib.org/reference/verify_output.html)) but they now been centralised in to [`local_test_context()`](https://testthat.r-lib.org/reference/local_test_context.html).

Snapshot testing
----------------

The goal of a unit test is to record the expected output of a function using code. This is a powerful technique because because not only does it ensure that code doesn't change unexpectedly, it also expresses the desired behaviour in a way that a human can understand. However, it's not always convenient to record the expected behaviour with code. Some challenges include:

-   Text output that includes many characters like quotes and newlines that require special handling in a string.

-   Output that is large, making it painful to define the reference output, and bloating the size of the test file and making it hard to navigate.

-   Cases where you want to record a mix of printed output, messages, warnings, or errors.

-   Binary formats like plots or images, which are very difficult to describe in code: i.e. the plot looks right, the error message is useful to a human, the print method uses colour effectively.

For these situations, testthat provides an alternative mechanism: snapshot tests. Instead of using code to describe expected output, snapshot tests (also known as [golden tests](https://ro-che.info/articles/2017-12-04-golden-tests)) record results in a separate human readable file. Snapshot tests in testthat are inspired primarily by [Jest](https://jestjs.io/docs/en/snapshot-testing), thanks to a number of very useful discussions with Joe Cheng.

If snapshot tests sound intriguing to you, please read the details in `vignette("snapshotting", package = "testthat").`

Other improvements
------------------

-   testthat has preliminary support for running tests in parallel. See details in [`vignette("parallel", package = "testthat")`](https://testthat.r-lib.org/articles/parallel.html)

-   We now recommend using test fixtures rather than [`setup()`](https://testthat.r-lib.org/reference/teardown.html) and [`teardown()`](https://testthat.r-lib.org/reference/teardown.html) code. See details in [`vignette("test-fixtures", package = "testthat")`](https://testthat.r-lib.org/articles/test-fixtures.html).

-   We have revamped non-interactive reporter to a better job of displaying skipped tests and written a vignette, [`vignette("skipping", package = "testthat")`](https://testthat.r-lib.org/articles/skipping.html), describing best practices (including how to test your own skip functions).

-   Made a number of tweaks to the various reporters that testthat uses in different places. Most importantly the reporter used by [`devtools::test()`](https://devtools.r-lib.org//reference/test.html) now display stack traces of warnings and errors that occur outside of tests making these problems substantially easier to track down. (It also gets a number of new random praise options that use emoji). There's also a new reporter for use by [`devtools::test_file()`](https://devtools.r-lib.org//reference/test.html) which displays results more compactly.

Acknowledgements
----------------

A big thanks to all 64 contributors who helped with this release by discussing problems, proposing features and contributing code: [@aalucaci](https://github.com/aalucaci), [@andrewmarx](https://github.com/andrewmarx), [@Anirban166](https://github.com/Anirban166), [@benxiahu](https://github.com/benxiahu), [@Bisaloo](https://github.com/Bisaloo), [@boerjames](https://github.com/boerjames), [@brodieG](https://github.com/brodieG), [@c0k3b0y](https://github.com/c0k3b0y), [@Christoph999](https://github.com/Christoph999), [@daattali](https://github.com/daattali), [@damianooldoni](https://github.com/damianooldoni), [@DanChaltiel](https://github.com/DanChaltiel), [@davidchall](https://github.com/davidchall), [@DavisVaughan](https://github.com/DavisVaughan), [@EdwardJGillian](https://github.com/EdwardJGillian), [@emiliesecherre](https://github.com/emiliesecherre), [@gaborcsardi](https://github.com/gaborcsardi), [@gavinsimpson](https://github.com/gavinsimpson), [@gergness](https://github.com/gergness), [@hadley](https://github.com/hadley), [@hbaniecki](https://github.com/hbaniecki), [@hongooi73](https://github.com/hongooi73), [@HughParsonage](https://github.com/HughParsonage), [@jarauh](https://github.com/jarauh), [@jcheng5](https://github.com/jcheng5), [@jennybc](https://github.com/jennybc), [@jimhester](https://github.com/jimhester), [@jonkeane](https://github.com/jonkeane), [@kevinushey](https://github.com/kevinushey), [@khaeru](https://github.com/khaeru), [@kjytay](https://github.com/kjytay), [@kos59125](https://github.com/kos59125), [@krlmlr](https://github.com/krlmlr), [@ksvanhorn](https://github.com/ksvanhorn), [@lionel-](https://github.com/lionel-), [@maelle](https://github.com/maelle), [@manumart](https://github.com/manumart), [@mardam](https://github.com/mardam), [@md0u80c9](https://github.com/md0u80c9), [@melvidoni](https://github.com/melvidoni), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@msberends](https://github.com/msberends), [@mtkerbeR](https://github.com/mtkerbeR), [@MyKo101](https://github.com/MyKo101), [@nbenn](https://github.com/nbenn), [@Nelson-Gon](https://github.com/Nelson-Gon), [@njtierney](https://github.com/njtierney), [@noeliarico](https://github.com/noeliarico), [@omsai](https://github.com/omsai), [@pat-s](https://github.com/pat-s), [@psteinb](https://github.com/psteinb), [@salim-b](https://github.com/salim-b), [@SKalt](https://github.com/SKalt), [@stefanoborini](https://github.com/stefanoborini), [@stufield](https://github.com/stufield), [@sumedh10](https://github.com/sumedh10), [@tanho63](https://github.com/tanho63), [@tbrown122387](https://github.com/tbrown122387), [@torfason](https://github.com/torfason), [@torockel](https://github.com/torockel), [@xiaodaigh](https://github.com/xiaodaigh), [@yitao-li](https://github.com/yitao-li), and [@yutannihilation](https://github.com/yutannihilation).

