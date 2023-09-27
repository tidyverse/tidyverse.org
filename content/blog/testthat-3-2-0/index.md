---
output: hugodown::hugo_document

slug: testthat-3-2-0
title: testthat 3.2.0
date: 2023-09-27
author: Hadley Wickham
description: >
    Catch up on the last two years of testthat development with the latest
    minor release which includes new expectations, improved error snapshots,
    a new way to detect if a test has changed global state, and a handful of
    UI improvements.

photo:
  url: https://unsplash.com/photos/PtabTe6iJ_8
  author: Mika Baumeister

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [testthat, devtools]
rmd_hash: bb6b9048fddce947

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're chuffed to announce the release of [testthat](%7B%20home%20%7D) 3.2.0. testthat makes it easy to turn your existing informal tests into formal, automated tests that you can rerun quickly and easily. testthat is the most popular unit-testing package for R, and is used by almost 9,000 CRAN and Bioconductor packages. You can learn more about unit testing at [https://r-pkgs.org/tests.html](#0).

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"testthat"</span><span class='o'>)</span></span></code></pre>

</div>

testthat 3.2.0 includes relatively few new features but there have been nine patch releases since testthat 3.1.0. These patch releases contained a bunch of experiments that we now believe are ready for the world. So this blog post summarises the changes in [3.1.1](https://github.com/r-lib/testthat/releases/tag/v3.1.1), [3.1.2](https://github.com/r-lib/testthat/releases/tag/v3.1.2), [3.1.3](https://github.com/r-lib/testthat/releases/tag/v3.1.3), [3.1.4](https://github.com/r-lib/testthat/releases/tag/v3.1.4), [3.1.5](https://github.com/r-lib/testthat/releases/tag/v3.1.5), [3.1.6](https://github.com/r-lib/testthat/releases/tag/v3.1.6), [3.1.7](https://github.com/r-lib/testthat/releases/tag/v3.1.7), [3.1.8](https://github.com/r-lib/testthat/releases/tag/v3.1.8), [3.1.9](https://github.com/r-lib/testthat/releases/tag/v3.1.9), and [3.1.10](https://github.com/r-lib/testthat/releases/tag/v3.1.10) over the last two years.

Here we'll focus on the biggest news: new expectations, tweaks to the way that error snapshots are reported, a new way to detect if a test has changed global state, and a handful of UI improvements.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://testthat.r-lib.org'>testthat</a></span><span class='o'>)</span></span></code></pre>

</div>

## New expectations

New [`expect_contains()`](https://testthat.r-lib.org/reference/expect_setequal.html) and [`expect_in()`](https://testthat.r-lib.org/reference/expect_setequal.html) that works similarly to `expect_true(all(expected %in% object))` or `expect_true(all(object %in% expected))` but give more informative failure messages:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>fruits</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"apple"</span>, <span class='s'>"banana"</span>, <span class='s'>"pear"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://testthat.r-lib.org/reference/expect_setequal.html'>expect_contains</a></span><span class='o'>(</span><span class='nv'>fruits</span>, <span class='s'>"apple"</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://testthat.r-lib.org/reference/expect_setequal.html'>expect_contains</a></span><span class='o'>(</span><span class='nv'>fruits</span>, <span class='s'>"pineapple"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Error: `fruits` (`actual`) doesn't fully contain all the values in "pineapple" (`expected`).</span></span>
<span><span class='c'>#&gt; * Missing from `actual`: "pineapple"</span></span>
<span><span class='c'>#&gt; * Present in `actual`:   "apple", "banana", "pear"</span></span>
<span></span><span></span>
<span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>TRUE</span>, <span class='kc'>FALSE</span>, <span class='kc'>TRUE</span>, <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://testthat.r-lib.org/reference/expect_setequal.html'>expect_in</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>TRUE</span>, <span class='kc'>FALSE</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>TRUE</span>, <span class='kc'>FALSE</span>, <span class='kc'>TRUE</span>, <span class='kc'>NA</span>, <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span><span class='nf'><a href='https://testthat.r-lib.org/reference/expect_setequal.html'>expect_in</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='kc'>TRUE</span>, <span class='kc'>FALSE</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Error: `x` (`actual`) isn't fully contained within c(TRUE, FALSE) (`expected`).</span></span>
<span><span class='c'>#&gt; * Missing from `expected`: NA</span></span>
<span><span class='c'>#&gt; * Present in `expected`:   TRUE, FALSE</span></span>
<span></span></code></pre>

</div>

New [`expect_no_error()`](https://testthat.r-lib.org/reference/expect_no_error.html), [`expect_no_warning()`](https://testthat.r-lib.org/reference/expect_no_error.html), and [`expect_no_message()`](https://testthat.r-lib.org/reference/expect_no_error.html) make it easier (and clearer) to expect that code runs with without errors, warnings, or messages. The default fails if there is any error/warning/message. In many cases, particularly when testing warnings and messages, you will want to be more specific about the condition you are hoping **not** to see, i.e. the condition that motivated you to write the test. Similar to [`expect_error()`](https://testthat.r-lib.org/reference/expect_error.html) and friends, you can specify the `message` (a regular expression that the message of the condition must match) and/or the `class` (a class the condition must inherit from). This ensures that the message/warnings you don't want never recur, while allowing new messages/warnings to bubble up for you to deal with.

## Snapshotting changes

`expect_snapshot(error = TRUE)` has a new display of error messages that strives to be closer to what you see interactively. In particular, you'll no longer see the error class and you will now see the error call.

If you have used `expect_snapshot(error = TRUE)` in your package, this means that you will need to re-run and approve your snapshots. We hope this is not too annoying and we believe it is worth it given the more accurate reflection of generated error messages. This will not affect checks on CRAN because, by default, snapshot tests are not run on CRAN.

## State inspector

In times gone by it was very easy to accidentally change the state of the world in a test:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://testthat.r-lib.org/reference/test_that.html'>test_that</a></span><span class='o'>(</span><span class='s'>"side-by-side diffs work"</span>, <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/options.html'>options</a></span><span class='o'>(</span>width <span class='o'>=</span> <span class='m'>20</span><span class='o'>)</span></span>
<span>  <span class='nf'><a href='https://testthat.r-lib.org/reference/expect_snapshot.html'>expect_snapshot</a></span><span class='o'>(</span></span>
<span>    <span class='nf'>waldo</span><span class='nf'>::</span><span class='nf'><a href='https://waldo.r-lib.org/reference/compare.html'>compare</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"X"</span>, <span class='nv'>letters</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>letters</span>, <span class='s'>"X"</span><span class='o'>)</span><span class='o'>)</span></span>
<span>  <span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span></code></pre>

</div>

When you look at a single test it's easy to spot the problem, and switch to a more appropriate way of temporarily changing the options, like [`withr::local_options()`](https://withr.r-lib.org/reference/with_options.html). But sometimes this mistake crept in a long time ago and is now hiding amongst hundreds or thousands of tests.

In earlier versions of testthat, finding tests that accidentally changed the world was painful: the only way was to painstakingly review each test. Now you can use [`set_state_inspector()`](https://testthat.r-lib.org/reference/set_state_inspector.html) to register a function that's called before and after every test. The function returns different values, testthat will let you know.

So, for example, to detect if any of your tests have modified options you could put the following in `tests/testhat/setup.R` or an existing helper file:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://testthat.r-lib.org/reference/set_state_inspector.html'>set_state_inspector</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>options <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/options.html'>options</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span></code></pre>

</div>

Or maybe you've an `R CMD check` warning that you've forgotten to close a connection:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://testthat.r-lib.org/reference/set_state_inspector.html'>set_state_inspector</a></span><span class='o'>(</span><span class='kr'>function</span><span class='o'>(</span><span class='o'>)</span> <span class='o'>&#123;</span></span>
<span>  <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>connections <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/nrow.html'>nrow</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/showConnections.html'>showConnections</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='o'>&#125;</span><span class='o'>)</span></span></code></pre>

</div>

And you can of course combine multiple checks just by returning a more complicated list.

## UI improvements

testthat 3.2.0 includes a bunch of minor user interface improvements that should make day-to-day use of testthat more enjoyable. Some of our favourite highlights are:

-   We use an improved algorithm to find the source reference associated with an expectation/error/warning/skip. We now look for the most recent call (within inside [`test_that()`](https://testthat.r-lib.org/reference/test_that.html) that has known source. This generally gives more specific locations than the previous approach and gives much better locations if an error occurs in an exit handler.

-   Tracebacks are no longer truncated we uses rlang's default tree display; this should make it easier to track down problems when testing in non-interactive contexts.

-   Assuming you have a recent RStudio, test failures are now clickable, taking you to the line where the problem occurred. Similarly, when a snapshot test changes, you can now click that suggested code to run the appropriate [`snapshot_accept()`](https://testthat.r-lib.org/reference/snapshot_accept.html) call.

-   Skips are now only shown at the end of reporter summaries, not as tests are run. This makes them less intrusive in interactive tests while still allowing you to verify that the correct tests are skipped.

## Acknowledgements

A big thanks to all 127 contributors who helped make these last 10 release of testthat happen, whether it be through contributed code or filing issues: [@ALanguillaume](https://github.com/ALanguillaume), [@alessandroaccettulli](https://github.com/alessandroaccettulli), [@ambica-aas](https://github.com/ambica-aas), [@annweideman](https://github.com/annweideman), [@aronatkins](https://github.com/aronatkins), [@ashander](https://github.com/ashander), [@AshesITR](https://github.com/AshesITR), [@astayleraz](https://github.com/astayleraz), [@ateucher](https://github.com/ateucher), [@avraam-inside](https://github.com/avraam-inside), [@b-steve](https://github.com/b-steve), [@bersbersbers](https://github.com/bersbersbers), [@billdenney](https://github.com/billdenney), [@Bisaloo](https://github.com/Bisaloo), [@cboettig](https://github.com/cboettig), [@cderv](https://github.com/cderv), [@chendaniely](https://github.com/chendaniely), [@ChrisBeeley](https://github.com/ChrisBeeley), [@ColinFay](https://github.com/ColinFay), [@CorradoLanera](https://github.com/CorradoLanera), [@daattali](https://github.com/daattali), [@damianooldoni](https://github.com/damianooldoni), [@DanChaltiel](https://github.com/DanChaltiel), [@danielinteractive](https://github.com/danielinteractive), [@DavisVaughan](https://github.com/DavisVaughan), [@daynefiler](https://github.com/daynefiler), [@dbdimitrov](https://github.com/dbdimitrov), [@dcaseykc](https://github.com/dcaseykc), [@dgkf](https://github.com/dgkf), [@dhicks](https://github.com/dhicks), [@dimfalk](https://github.com/dimfalk), [@dougwyu](https://github.com/dougwyu), [@dpprdan](https://github.com/dpprdan), [@dvg-p4](https://github.com/dvg-p4), [@elong0527](https://github.com/elong0527), [@Enchufa2](https://github.com/Enchufa2), [@etiennebacher](https://github.com/etiennebacher), [@FlippieCoetser](https://github.com/FlippieCoetser), [@florisvdh](https://github.com/florisvdh), [@gaborcsardi](https://github.com/gaborcsardi), [@gareth-j](https://github.com/gareth-j), [@gavinsimpson](https://github.com/gavinsimpson), [@ghill-fusion](https://github.com/ghill-fusion), [@hadley](https://github.com/hadley), [@heavywatal](https://github.com/heavywatal), [@hfrick](https://github.com/hfrick), [@hhau](https://github.com/hhau), [@hpages](https://github.com/hpages), [@hsloot](https://github.com/hsloot), [@hughjonesd](https://github.com/hughjonesd), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@jameslairdsmith](https://github.com/jameslairdsmith), [@jamieRowen](https://github.com/jamieRowen), [@jayruffell](https://github.com/jayruffell), [@JBGruber](https://github.com/JBGruber), [@jennybc](https://github.com/jennybc), [@JohnCoene](https://github.com/JohnCoene), [@jonathanvoelkle](https://github.com/jonathanvoelkle), [@jonthegeek](https://github.com/jonthegeek), [@josherrickson](https://github.com/josherrickson), [@kalaschnik](https://github.com/kalaschnik), [@kapsner](https://github.com/kapsner), [@kevinushey](https://github.com/kevinushey), [@kjytay](https://github.com/kjytay), [@krivit](https://github.com/krivit), [@krlmlr](https://github.com/krlmlr), [@larmarange](https://github.com/larmarange), [@lionel-](https://github.com/lionel-), [@llrs](https://github.com/llrs), [@luma-sb](https://github.com/luma-sb), [@machow](https://github.com/machow), [@maciekbanas](https://github.com/maciekbanas), [@maelle](https://github.com/maelle), [@majr-red](https://github.com/majr-red), [@maksymiuks](https://github.com/maksymiuks), [@mardam](https://github.com/mardam), [@MarkMc1089](https://github.com/MarkMc1089), [@markschat](https://github.com/markschat), [@MatthieuStigler](https://github.com/MatthieuStigler), [@maurolepore](https://github.com/maurolepore), [@maxheld83](https://github.com/maxheld83), [@mbojan](https://github.com/mbojan), [@mcol](https://github.com/mcol), [@mgirlich](https://github.com/mgirlich), [@MichaelChirico](https://github.com/MichaelChirico), [@mkb13](https://github.com/mkb13), [@mkoohafkan](https://github.com/mkoohafkan), [@MKyhos](https://github.com/MKyhos), [@moodymudskipper](https://github.com/moodymudskipper), [@Mosk915](https://github.com/Mosk915), [@mpjashby](https://github.com/mpjashby), [@ms609](https://github.com/ms609), [@mtmorgan](https://github.com/mtmorgan), [@musvaage](https://github.com/musvaage), [@nealrichardson](https://github.com/nealrichardson), [@netique](https://github.com/netique), [@njtierney](https://github.com/njtierney), [@olivroy](https://github.com/olivroy), [@osorensen](https://github.com/osorensen), [@pbulsink](https://github.com/pbulsink), [@peterdesmet](https://github.com/peterdesmet), [@r2evans](https://github.com/r2evans), [@radbasa](https://github.com/radbasa), [@remlapmot](https://github.com/remlapmot), [@rfineman](https://github.com/rfineman), [@rgayler](https://github.com/rgayler), [@romainfrancois](https://github.com/romainfrancois), [@s-fleck](https://github.com/s-fleck), [@salim-b](https://github.com/salim-b), [@schloerke](https://github.com/schloerke), [@sorhawell](https://github.com/sorhawell), [@StatisMike](https://github.com/StatisMike), [@StatsMan53](https://github.com/StatsMan53), [@stela2502](https://github.com/stela2502), [@stla](https://github.com/stla), [@t-kalinowski](https://github.com/t-kalinowski), [@tansaku](https://github.com/tansaku), [@tomliptrot](https://github.com/tomliptrot), [@torres-pedro](https://github.com/torres-pedro), [@wes-brooks](https://github.com/wes-brooks), [@wfmueller29](https://github.com/wfmueller29), [@wleoncio](https://github.com/wleoncio), [@wurli](https://github.com/wurli), [@yogat3ch](https://github.com/yogat3ch), [@yuliaUU](https://github.com/yuliaUU), [@yutannihilation](https://github.com/yutannihilation), and [@zsigmas](https://github.com/zsigmas).

