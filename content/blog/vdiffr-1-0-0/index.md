---
output: hugodown::hugo_document

slug: vdiffr-1-0-0
title: vdiffr 1.0.0
date: 2021-06-21
author: Lionel Henry
description: >
    This major release of vdiffr includes an updated SVG engine and integrates with the snapshot management mechanism of testthat 3.

photo:
  url: https://unsplash.com/photos/e8rfcKAx1Rk
  author: Jakob Owens

categories: [package] 
tags: [ggplot2, testthat]
rmd_hash: a756409c680ac0e0

---

We're delighted to announce the release of [vdiffr](https://vdiffr.r-lib.org/) 1.0.0. vdiffr is a testthat extension that makes it easy to automatically check code that generates R graphics. In particular, vdiffr is used by the ggplot2 team to ensure that changes and contributions do not affect the expected output of plots.

You can install vdiffr from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"vdiffr"</span><span class='o'>)</span></code></pre>

</div>

This blog post briefly introduces the vdiffr workflow and describes the changes in this 1.0 version. In the last section you will learn how to migrate your existing vdiffr snapshots to the new version. You can see a full list of changes in the [release notes](https://vdiffr.r-lib.org/news/index.html#vdiffr-1-0-0-2021-06-08).

Attach these three packages to follow the examples:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://testthat.r-lib.org'>testthat</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://vdiffr.r-lib.org/'>vdiffr</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://ggplot2.tidyverse.org'>ggplot2</a></span><span class='o'>)</span></code></pre>

</div>

## Regression testing for R graphics

vdiffr is a [testthat](https://testthat.r-lib.org/) extension for monitoring the appearance of R plots and graphics over time. Its goals are to make it easy to test graphics, make it easy to review changes, and to be reproducible across platforms.

The only vdiffr function you will need to use is [`expect_doppelganger()`](https://vdiffr.r-lib.org/reference/expect_doppelganger.html). It takes a plot title and a plot object.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"ggplot2 histogram works"</span>, <span class='o'>&#123;</span>
  <span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>)</span> <span class='o'>+</span> <span class='nf'><a href='https://ggplot2.tidyverse.org/reference/geom_histogram.html'>geom_histogram</a></span><span class='o'>(</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/aes.html'>aes</a></span><span class='o'>(</span><span class='nv'>disp</span><span class='o'>)</span><span class='o'>)</span>
  <span class='nf'><a href='https://vdiffr.r-lib.org/reference/expect_doppelganger.html'>expect_doppelganger</a></span><span class='o'>(</span><span class='s'>"default histogram"</span>, <span class='nv'>p</span><span class='o'>)</span>
<span class='o'>&#125;</span><span class='o'>)</span></code></pre>

</div>

With base graphics you will need to use a slightly different syntax because base plots are created by side effects rather than a plot object as in ggplot2. In this case you can supply a function that generates the plot:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"base histogram works"</span>, <span class='o'>&#123;</span>
  <span class='nv'>p</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/graphics/hist.html'>hist</a></span><span class='o'>(</span><span class='nv'>mtcars</span><span class='o'>$</span><span class='nv'>disp</span><span class='o'>)</span>
  <span class='nf'><a href='https://vdiffr.r-lib.org/reference/expect_doppelganger.html'>expect_doppelganger</a></span><span class='o'>(</span><span class='s'>"base histogram"</span>, <span class='nv'>p</span><span class='o'>)</span>
<span class='o'>&#125;</span><span class='o'>)</span></code></pre>

</div>

Then run [`devtools::test()`](https://devtools.r-lib.org//reference/test.html) as usual. The first time it is run, [`expect_doppelganger()`](https://vdiffr.r-lib.org/reference/expect_doppelganger.html) generates a reproducible SVG file that represents the expected appearance of your plot and saves it inside your test folder. After that, the generated SVG is compared to the saved version and any mismatch is reported as a failure in the testthat output.

Note that, by default, mismatches do not cause failures on CRAN machines. That's because testing the appearance of a plot is inherently fragile. Small upstream changes (e.g. in the R graphics device or in the ggplot2 package) might cause subtle differences in the appearance of a plot that are not real failures. If every such change caused a CRAN failure this would be distracting for both you and the CRAN maintainers. This is why vdiffr expectations only report failures when they are ran locally or in your CI platform. This allows you to monitor the appearance of your plots over time without causing distracting and time-consuming failures on CRAN.

## New snapshot management system via testthat 3

The main user visible change in vdiffr 1.0.0 is the replacement of the case management system and the accompanying Shiny app by the [snapshot system introduced in testthat 3](https://testthat.r-lib.org/articles/snapshotting.html). Following this change, a lot of vdiffr code has been removed and the package is now a simple generator of reproducible SVGs.

Snapshot management in testthat 3 is much more straightforward than the mechanism in previous versions of vdiffr.

-   New cases are automatically recorded in the snapshot folder. They no longer need to be validated via the Shiny app.

-   Orphaned cases are automatically deleted from the snapshot folder.

-   Failures are reviewed with [`testthat::snapshot_review()`](https://testthat.r-lib.org/reference/snapshot_accept.html), a minimalist Shiny app powered by the [diffviewer](https://github.com/r-lib/diffviewer/) package.

This workflow integrates nicely with other kinds of testthat snapshots such as error, warning, or output snapshots.

## A simpler SVG engine

To generate reproducible snapshots, vdiffr embeds an SVG generation engine based on svglite. This engine has been updated and simplified.

-   The main user-visible change from this update is that points now look smaller in the new SVGs. In the old snapshots they were too large.

-   The computation of character sizes is now hardcoded which allowed us to simplify the dependencies of vdiffr. It should also be less maintenance work for us in the long term.

## Migrating existing vdiffr snapshots

Because of the switch to testthat 3 snapshots and the update to the SVG engine, you will need to regenerate all of your figures if you are an existing vdiffr user. Thankfully the process is straightforward and only includes two steps.

1.  This step is optional. Since the update to the SVG engine alters the appearance of your plots, you might want to review the changes. To do so, install the github-only 0.4.0 version of vdiffr with [`remotes::install_github("r-lib/vdiffr@v0.4.0")`](https://remotes.r-lib.org/reference/install_github.html). This release only contains the new SVG engine. You can then review the snapshot changes as usual with `vdiffr::manage_cases()`.

2.  Install vdiffr 1.0.0 from CRAN. Delete the `tests/figs` directory where the old snapshots were saved (they will now be saved in `tests/testthat/_snaps`) and run [`devtools::test()`](https://devtools.r-lib.org//reference/test.html) to generate the new snapshots.

Please let us know of any trouble during migration, we're here to help!

## Acknowledgements

vdiffr 1.0.0 wouldn't be possible without my colleague Thomas Lin Pedersen. His experience with R graphics device ([raggs](https://github.com/r-lib/ragg), [textshaping](https://github.com/r-lib/textshaping), ...) was crucial to the update and simplification of the SVG engine. Thanks Thomas!

We also would like to thank all the issues and code contributors for this release: [@aghaynes](https://github.com/aghaynes), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@JauntyJJS](https://github.com/JauntyJJS), [@jgabry](https://github.com/jgabry), [@krassowski](https://github.com/krassowski), [@mtalluto](https://github.com/mtalluto), [@pat-s](https://github.com/pat-s), [@rfaelens](https://github.com/rfaelens), and [@Sumidu](https://github.com/Sumidu).

