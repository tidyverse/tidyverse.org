---
output: hugodown::hugo_document

slug: testthat-3-1
title: testthat 3.1.0
date: 2021-10-01
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
rmd_hash: ff8b01ebb22a1a51

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

We're stoked to announce the release of [testthat](http://testthat.r-lib.org/) 3.1.0. testthat makes it easy to turn your existing informal tests into formal, automated tests that you can rerun quickly and easily. testthat is the most popular unit-testing package for R, and is used by over 6,000 CRAN and Bioconductor packages. You can learn more about unit testing at <https://r-pkgs.org/tests.html>.

You can install testthat from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"&#123;package&#125;"</span><span class='o'>)</span></code></pre>

</div>

This release of testthat includes a bunch of minor improvements to snapshotting as well as one breaking change (which only applies if you're using the 3rd edition). You can see a full list of changes in the [release notes](https://github.com/r-lib/testthat/blob/master/NEWS.md).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://testthat.r-lib.org'>testthat</a></span><span class='o'>)</span></code></pre>

</div>

## Snapshot tests

Most of the effort in this release has gone in [snapshot tests](https://testthat.r-lib.org/articles/snapshotting.html), a new feature in testthat 3.0.0. snapshot tests (also known as [golden tests](https://ro-che.info/articles/2017-12-04-golden-tests)) record expect output in a separate human-readable file Instead of using code to describe expected output. Since the release of testthat 3.0.0, we've started using snapshot tests across a bunch of tidyverse packages and they've been working out really well. I don't anticipate any major changes (although we may continue to add new features) so the snapshot functions have changed lifecycle stages from experimental to **stable**.

This release also includes two new features that help you use snapshot tests in more places:

-   [`expect_snapshot()`](https://testthat.r-lib.org/reference/expect_snapshot.html) gains a `transform` argument, which should be a function that takes a character vector of lines and returns a modified character vector of lines. This makes it easy to remove sensitive (e.g. API keys) or stochastic (e.g. random temporary directory names) data from snapshot output.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>get_info</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
      <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>
        name <span class='o'>=</span> <span class='s'>"Hadley"</span>, 
        password <span class='o'>=</span> <span class='s'>"sssh-its-a-secret"</span>
      <span class='o'>)</span>
    <span class='o'>&#125;</span>

    <span class='nv'>hide_password</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
      <span class='nv'>is_password</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/grep.html'>grepl</a></span><span class='o'>(</span><span class='s'>"password"</span>, <span class='nv'>x</span><span class='o'>)</span>
      <span class='nf'><a href='https://rdrr.io/r/base/ifelse.html'>ifelse</a></span><span class='o'>(</span><span class='nv'>is_password</span>, <span class='s'>"&lt;REDACTED&gt;"</span>, <span class='nv'>x</span><span class='o'>)</span>
    <span class='o'>&#125;</span>

    <span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"info retruns name and password"</span>, <span class='o'>&#123;</span>
      <span class='nf'><a href='https://testthat.r-lib.org/reference/local_edition.html'>local_edition</a></span><span class='o'>(</span><span class='m'>3</span><span class='o'>)</span>
      <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_snapshot.html'>expect_snapshot</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nf'>get_info</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>, transform <span class='o'>=</span> <span class='nv'>hide_password</span><span class='o'>)</span>
    <span class='o'>&#125;</span><span class='o'>)</span>
    <span class='c'>#&gt; <span style='font-weight: bold;'>Can't compare snapshot to reference when testing interactively</span></span>
    <span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> Run `devtools::test()` or `testthat::test_file()` to see changes</span>
    <span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span> Current value:</span>
    <span class='c'>#&gt; Code</span>
    <span class='c'>#&gt;   str(get_info())</span>
    <span class='c'>#&gt; Output</span>
    <span class='c'>#&gt;   List of 2</span>
    <span class='c'>#&gt;    $ name    : chr "Hadley"</span>
    <span class='c'>#&gt;   &lt;REDACTED&gt;</span>
    <span class='c'>#&gt; ── <span style='color: #0000BB; font-weight: bold;'>Skip</span><span style='font-weight: bold;'> (test-that.R:50:3): info retruns name and password</span> ─────────────────────</span>
    <span class='c'>#&gt; Reason: empty test</span></code></pre>

    </div>

    If you need `transform`, I recommend designing your printing methods so the output can be easily manipulated with regexps.

-   [`expect_snapshot()`](https://testthat.r-lib.org/reference/expect_snapshot.html) and friends gets an experimental new `variant` argument which causes the snapshot to be saved in `_snaps/{variant}/{test}.md` instead of `_snaps/{test}.md`. This allows you to generate (and compare) unique snapshots for different scenarios where the output is otherwise out of your control, like differences across operating systems or R versions.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>r_version</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='s'>"R"</span>, <span class='nf'><a href='https://rdrr.io/r/base/numeric_version.html'>getRversion</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>[</span>, <span class='m'>1</span><span class='o'>:</span><span class='m'>2</span><span class='o'>]</span><span class='o'>)</span>

    <span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"can capture version nickname"</span>, <span class='o'>&#123;</span>
      <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_snapshot.html'>expect_snapshot</a></span><span class='o'>(</span><span class='nv'>version</span><span class='o'>$</span><span class='nv'>nickname</span>, variant <span class='o'>=</span> <span class='nf'>r_version</span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
    <span class='o'>&#125;</span><span class='o'>)</span></code></pre>

    </div>

Remember that snapshot tests are not run on CRAN by default because they require a human to confirm whether or not a change is a breakage, so you shouldn't rely only on snapshot tests to ensure that your code is correct. While it is possible to set `cran = TRUE`, to force snapshot tests to run on CRAN, I don't generally recommend it as snapshots are often vulnerable to minor changes that don't merit breaking your released package.

## Breaking changes

We made one breaking change that affects the [third edition](https://testthat.r-lib.org/articles/third-edition.html). Previously, [`expect_message()`](https://testthat.r-lib.org/reference/expect_error.html), [`expect_warning()`](https://testthat.r-lib.org/reference/expect_error.html) and [`expect_error()`](https://testthat.r-lib.org/reference/expect_error.html) returned the value of the first argument, unless that was `NULL`, when they instead returned the condition object. This meant you could write code like this:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_warning</a></span><span class='o'>(</span><span class='nf'>f</span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>"warning"</span><span class='o'>)</span>, <span class='s'>"value"</span><span class='o'>)</span></code></pre>

</div>

Now [`expect_message()`](https://testthat.r-lib.org/reference/expect_error.html), [`expect_warning()`](https://testthat.r-lib.org/reference/expect_error.html) and [`expect_error()`](https://testthat.r-lib.org/reference/expect_error.html) always return the condition object so you need to flip the order of the expectations:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_warning</a></span><span class='o'>(</span><span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nf'>f</span><span class='o'>(</span><span class='o'>)</span>, <span class='s'>"value"</span><span class='o'>)</span>, <span class='s'>"warning"</span><span class='o'>)</span></code></pre>

</div>

This (IMO) is a little easier to read with the pipe:

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

As with any breaking change, we made this change with great care. Fortunately it only affects the 3rd edition, which relatively few packages use, and we submitted PRs to all affected packages on CRAN.

We made this change because it makes testthat more consistent and makes it easier to inspect both the value and the warning. This is important because it makes it easier to test functions that produce [custom error objects](https://adv-r.hadley.nz/conditions.html#custom-conditions) that themselves contain meaningful data:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rlang.r-lib.org'>rlang</a></span><span class='o'>)</span>
<span class='nv'>informative_error</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rlang.r-lib.org/reference/abort.html'>abort</a></span><span class='o'>(</span>
    <span class='s'>"An error with extra info"</span>,
    name <span class='o'>=</span> <span class='s'>"patrice"</span>,
    number <span class='o'>=</span> <span class='m'>17</span>
  <span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nv'>err</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_error.html'>expect_error</a></span><span class='o'>(</span><span class='nf'>my_function</span><span class='o'>(</span><span class='o'>)</span>, class <span class='o'>=</span> <span class='s'>"package_error_class"</span><span class='o'>)</span>
<span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nv'>err</span><span class='o'>$</span><span class='nv'>name</span>, <span class='s'>"patrice"</span><span class='o'>)</span>
<span class='nf'><a href='https://testthat.r-lib.org/reference/equality-expectations.html'>expect_equal</a></span><span class='o'>(</span><span class='nv'>err</span><span class='o'>$</span><span class='nv'>number</span>, <span class='m'>17</span><span class='o'>)</span></code></pre>

</div>

Richer conditions are tool that we use within the tidyverse to provide more context in error message. You're unlikely to see them directly, but we're using them as part of a general effort to make more actionable error messages.

## Acknowledgements

A big thanks to all 104 contributors who filed issues and contributed code to this and the last few patch releases: [@Aariq](https://github.com/Aariq), [@Aehmlo](https://github.com/Aehmlo), [@aguynamedryan](https://github.com/aguynamedryan), [@ahjota](https://github.com/ahjota), [@akersting](https://github.com/akersting), [@Akirathan](https://github.com/Akirathan), [@arnaud-feldmann](https://github.com/arnaud-feldmann), [@aronatkins](https://github.com/aronatkins), [@Bisaloo](https://github.com/Bisaloo), [@boennecd](https://github.com/boennecd), [@BS1125](https://github.com/BS1125), [@byoung](https://github.com/byoung), [@cboettig](https://github.com/cboettig), [@clauswilke](https://github.com/clauswilke), [@ColinFay](https://github.com/ColinFay), [@CorradoLanera](https://github.com/CorradoLanera), [@dagola](https://github.com/dagola), [@DanChaltiel](https://github.com/DanChaltiel), [@david-barnett](https://github.com/david-barnett), [@david-cortes](https://github.com/david-cortes), [@DavisVaughan](https://github.com/DavisVaughan), [@dmenne](https://github.com/dmenne), [@dpprdan](https://github.com/dpprdan), [@egonulates](https://github.com/egonulates), [@espinielli](https://github.com/espinielli), [@eveyp](https://github.com/eveyp), [@FBartos](https://github.com/FBartos), [@federicomarini](https://github.com/federicomarini), [@flying-sheep](https://github.com/flying-sheep), [@franzbischoff](https://github.com/franzbischoff), [@gaborcsardi](https://github.com/gaborcsardi), [@hadley](https://github.com/hadley), [@hamstr147](https://github.com/hamstr147), [@harell](https://github.com/harell), [@harsh9898](https://github.com/harsh9898), [@helix123](https://github.com/helix123), [@hongooi73](https://github.com/hongooi73), [@hsloot](https://github.com/hsloot), [@jeffreyhanson](https://github.com/jeffreyhanson), [@jennybc](https://github.com/jennybc), [@jeroen](https://github.com/jeroen), [@jesterxd](https://github.com/jesterxd), [@jimhester](https://github.com/jimhester), [@kevinushey](https://github.com/kevinushey), [@krlmlr](https://github.com/krlmlr), [@lcougnaud](https://github.com/lcougnaud), [@linusheinz](https://github.com/linusheinz), [@lionel-](https://github.com/lionel-), [@llrs](https://github.com/llrs), [@lutzgruber-quantco](https://github.com/lutzgruber-quantco), [@maelle](https://github.com/maelle), [@maia-sh](https://github.com/maia-sh), [@malcolmbarrett](https://github.com/malcolmbarrett), [@MarkEdmondson1234](https://github.com/MarkEdmondson1234), [@marko-stojovic](https://github.com/marko-stojovic), [@mattfidler](https://github.com/mattfidler), [@maxachis](https://github.com/maxachis), [@maxheld83](https://github.com/maxheld83), [@mbojan](https://github.com/mbojan), [@mcol](https://github.com/mcol), [@MechantRouquin](https://github.com/MechantRouquin), [@mem48](https://github.com/mem48), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@michaelquinn32](https://github.com/michaelquinn32), [@mihaiconstantin](https://github.com/mihaiconstantin), [@mikemahoney218](https://github.com/mikemahoney218), [@MilesMcBain](https://github.com/MilesMcBain), [@mjskay](https://github.com/mjskay), [@mllg](https://github.com/mllg), [@Mosk915](https://github.com/Mosk915), [@ms609](https://github.com/ms609), [@multimeric](https://github.com/multimeric), [@nbenn](https://github.com/nbenn), [@neonira](https://github.com/neonira), [@nicholasproietti](https://github.com/nicholasproietti), [@njtierney](https://github.com/njtierney), [@nkehrein](https://github.com/nkehrein), [@pat-s](https://github.com/pat-s), [@pbarber](https://github.com/pbarber), [@pkrog](https://github.com/pkrog), [@przmv](https://github.com/przmv), [@r2evans](https://github.com/r2evans), [@raphael-lorenzdelaigue](https://github.com/raphael-lorenzdelaigue), [@rfaelens](https://github.com/rfaelens), [@rjnb50](https://github.com/rjnb50), [@romainfrancois](https://github.com/romainfrancois), [@rwhetten](https://github.com/rwhetten), [@salim-b](https://github.com/salim-b), [@schloerke](https://github.com/schloerke), [@sigmafelix](https://github.com/sigmafelix), [@srfall](https://github.com/srfall), [@strengejacke](https://github.com/strengejacke), [@SubieG](https://github.com/SubieG), [@thebioengineer](https://github.com/thebioengineer), [@thisisnic](https://github.com/thisisnic), [@tiQu](https://github.com/tiQu), [@torbjorn](https://github.com/torbjorn), [@ttimbers](https://github.com/ttimbers), [@tzakharko](https://github.com/tzakharko), [@vspinu](https://github.com/vspinu), [@wch](https://github.com/wch), [@weiyaw](https://github.com/weiyaw), and [@yasushm](https://github.com/yasushm).

