---
output: hugodown::hugo_document

slug: readr-1-4-0
title: readr 1.4.0
date: 2020-09-30
author: Jim Hester
description: >
    The newest release of readr brings improved argument consistentency, better
    messages and more flexible output options.
photo:
  url: https://unsplash.com/photos/XOW1WqrWNKg
  author: Anastasia Zhenina
categories: [package]
tags:
  - readr
  - tidyverse
rmd_hash: 5aa42d81e5945da1

---

[readr](http://readr.tidyverse.org) 1.4.0 is now available on CRAN! Learn more about readr at <a href="https://readr.tidyverse.org" class="uri">https://readr.tidyverse.org</a>. Detailed notes are always in the [change log](https://readr.tidyverse.org/news/index.html#readr-1-4-0).

The readr package makes it easy to get rectangular data out of comma separated (csv), tab separated (tsv) or fixed width files (fwf) and into R. It is designed to flexibly parse many types of data found in the wild, while still cleanly failing when data unexpectedly changes. If you are new to readr, the best place to start is the [data import chapter](https://r4ds.had.co.nz/data-import.html) in R for data science.

The easiest way to install the latest version from CRAN is to install the whole tidyverse.

``` r
install.packages("tidyverse")
```

Alternatively, install just readr from CRAN:

``` r
install.packages("readr")
```

readr is part of the core tidyverse, so load it with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='http://tidyverse.tidyverse.org'>tidyverse</a></span>)

<span class='c'>#&gt; ── <span style='font-weight: bold;'>Attaching packages</span><span> ─────────────────────────────────────── tidyverse 1.3.0 ──</span></span>

<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span><span> </span><span style='color: #0000BB;'>ggplot2</span><span> 3.3.2     </span><span style='color: #00BB00;'>✔</span><span> </span><span style='color: #0000BB;'>purrr  </span><span> 0.3.4</span></span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span><span> </span><span style='color: #0000BB;'>tibble </span><span> 3.0.3     </span><span style='color: #00BB00;'>✔</span><span> </span><span style='color: #0000BB;'>dplyr  </span><span> 1.0.2</span></span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span><span> </span><span style='color: #0000BB;'>tidyr  </span><span> 1.1.2     </span><span style='color: #00BB00;'>✔</span><span> </span><span style='color: #0000BB;'>stringr</span><span> 1.4.0</span></span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span><span> </span><span style='color: #0000BB;'>readr  </span><span> 1.4.0     </span><span style='color: #00BB00;'>✔</span><span> </span><span style='color: #0000BB;'>forcats</span><span> 0.5.0</span></span>

<span class='c'>#&gt; ── <span style='font-weight: bold;'>Conflicts</span><span> ────────────────────────────────────────── tidyverse_conflicts() ──</span></span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span><span> </span><span style='color: #0000BB;'>dplyr</span><span>::</span><span style='color: #00BB00;'>filter()</span><span> masks </span><span style='color: #0000BB;'>stats</span><span>::filter()</span></span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span><span> </span><span style='color: #0000BB;'>dplyr</span><span>::</span><span style='color: #00BB00;'>lag()</span><span>    masks </span><span style='color: #0000BB;'>stats</span><span>::lag()</span></span>
</code></pre>

</div>

Breaking Changes
----------------

### Argument name consistency

The first argument to all of the `write_()` functions, like `write_csv()` had previously been `path`. However the first argument to all of the `read_()` functions is `file`. As of readr 1.4.0 the first argument to both `read_()` and `write_()` functions is `file` and `path` is now deprecated.

### NaN behavior

Some floating point operations can produce a `NaN` value, e.g. `0 / 0`. Previously `write_csv()` would output `NaN` values always as `NaN` and this could not be controlled by the `write_csv(na=)` argument. Now the output value of `NaN` is the same as the `NA` and can be controlled by the argument. This is a breaking change in that the same code would produce different output, but it should be rare in practice.

New features
------------

### Generate column specifications from datasets

Using `as.col_spec()` on any `data.frame` or `tibble` object will now generate a column specification with the column types in the data.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/library.html'>library</a></span>(<span class='k'><a href='https://allisonhorst.github.io/palmerpenguins/'>palmerpenguins</a></span>)
<span class='k'>spec</span> <span class='o'>&lt;-</span> <span class='nf'>as.col_spec</span>(<span class='k'>penguins</span>)
<span class='k'>spec</span>

<span class='c'>#&gt; cols(</span>
<span class='c'>#&gt;   species = <span style='color: #BB0000;'>col_factor(levels = c("Adelie", "Chinstrap", "Gentoo"), ordered = FALSE, include_na = FALSE)</span><span>,</span></span>
<span class='c'>#&gt;   island = <span style='color: #BB0000;'>col_factor(levels = c("Biscoe", "Dream", "Torgersen"), ordered = FALSE, include_na = FALSE)</span><span>,</span></span>
<span class='c'>#&gt;   bill_length_mm = <span style='color: #00BB00;'>col_double()</span><span>,</span></span>
<span class='c'>#&gt;   bill_depth_mm = <span style='color: #00BB00;'>col_double()</span><span>,</span></span>
<span class='c'>#&gt;   flipper_length_mm = <span style='color: #00BB00;'>col_integer()</span><span>,</span></span>
<span class='c'>#&gt;   body_mass_g = <span style='color: #00BB00;'>col_integer()</span><span>,</span></span>
<span class='c'>#&gt;   sex = <span style='color: #BB0000;'>col_factor(levels = c("female", "male"), ordered = FALSE, include_na = FALSE)</span><span>,</span></span>
<span class='c'>#&gt;   year = <span style='color: #00BB00;'>col_integer()</span></span>
<span class='c'>#&gt; )</span>
</code></pre>

</div>

You can also convert the column specifications to a condensed textual representation with [`as.character()`](https://rdrr.io/r/base/character.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/character.html'>as.character</a></span>(<span class='k'>spec</span>)

<span class='c'>#&gt; [1] "ffddiifi"</span>
</code></pre>

</div>

### Writing end of line characters

Write functions now take a `eol` argument to allow control of the end of line characters. Previously readr only supported using a single newline (`\n`) character. You can now specify any number of characters, though windows linefeed newline (`\r\n`) is by far the most common alternative.

### cli package is now used for messages

The cli package is now used for messages. The most prominent place you will notice this is printing the column specifications. Previously these functions used [`message()`](https://rdrr.io/r/base/message.html), which in RStudio prints the text in red.

While cli still uses message objects, they will now be more naturally colored, which hopefully will make them easier to read.

### Rcpp dependency removed

The Rcpp dependency has been removed in favor of [cpp11](https://cpp11.r-lib.org/). Compiling readr should now take less time and use less memory.

Acknowledgements
----------------

As usual, there were many more additional changes and bugfixes included in this release see the [change log](https://readr.tidyverse.org/news/index.html#readr-1-4-0) for details.

Thank you to the 132 contributors who made this release possible by opening issues or submitting pull requests: [@adamroyjones](https://github.com/adamroyjones), [@aetiologicCanada](https://github.com/aetiologicCanada), [@ailich](https://github.com/ailich), [@antoine-sachet](https://github.com/antoine-sachet), [@archenemies](https://github.com/archenemies), [@ashuchawla](https://github.com/ashuchawla), [@Athanasiamo](https://github.com/Athanasiamo), [@bastianilso](https://github.com/bastianilso), [@batpigandme](https://github.com/batpigandme), [@Ben-Cox](https://github.com/Ben-Cox), [@bergen288](https://github.com/bergen288), [@boshek](https://github.com/boshek), [@bovender](https://github.com/bovender), [@bransonf](https://github.com/bransonf), [@brianrice2](https://github.com/brianrice2), [@briatte](https://github.com/briatte), [@c30saux](https://github.com/c30saux), [@cboettig](https://github.com/cboettig), [@cderv](https://github.com/cderv), [@cdhowe](https://github.com/cdhowe), [@ceresek](https://github.com/ceresek), [@charliejhadley](https://github.com/charliejhadley), [@chipkoziara](https://github.com/chipkoziara), [@cwolk](https://github.com/cwolk), [@damianooldoni](https://github.com/damianooldoni), [@dan-reznik](https://github.com/dan-reznik), [@DanielleQuinn](https://github.com/DanielleQuinn), [@DarwinAwardWinner](https://github.com/DarwinAwardWinner), [@dhmontgomery](https://github.com/dhmontgomery), [@djbirke](https://github.com/djbirke), [@dkahle](https://github.com/dkahle), [@dmitrienka](https://github.com/dmitrienka), [@dmurdoch](https://github.com/dmurdoch), [@dpprdan](https://github.com/dpprdan), [@dwachsmuth](https://github.com/dwachsmuth), [@EarlGlynn](https://github.com/EarlGlynn), [@edo91](https://github.com/edo91), [@ellessenne](https://github.com/ellessenne), [@Fernal73](https://github.com/Fernal73), [@firasm](https://github.com/firasm), [@fjuniorr](https://github.com/fjuniorr), [@frahimov](https://github.com/frahimov), [@frousseu](https://github.com/frousseu), [@GegznaV](https://github.com/GegznaV), [@georgevbsantiago](https://github.com/georgevbsantiago), [@geotheory](https://github.com/geotheory), [@greg-minshall](https://github.com/greg-minshall), [@hadley](https://github.com/hadley), [@hidekoji](https://github.com/hidekoji), [@huashan](https://github.com/huashan), [@ifendo](https://github.com/ifendo), [@ijlyttle](https://github.com/ijlyttle), [@isaactpetersen](https://github.com/isaactpetersen), [@jangorecki](https://github.com/jangorecki), [@jdblischak](https://github.com/jdblischak), [@jemunro](https://github.com/jemunro), [@jennahamlin](https://github.com/jennahamlin), [@jesse-ross](https://github.com/jesse-ross), [@jimhester](https://github.com/jimhester), [@jmarshallnz](https://github.com/jmarshallnz), [@jmcloughlin](https://github.com/jmcloughlin), [@jmobrien](https://github.com/jmobrien), [@jnolis](https://github.com/jnolis), [@jokedurnez](https://github.com/jokedurnez), [@jpwhitney](https://github.com/jpwhitney), [@jssa98](https://github.com/jssa98), [@juangomezduaso](https://github.com/juangomezduaso), [@junqi108](https://github.com/junqi108), [@JustGitting](https://github.com/JustGitting), [@jxu](https://github.com/jxu), [@kainhofer](https://github.com/kainhofer), [@katgit](https://github.com/katgit), [@kbzsl](https://github.com/kbzsl), [@keesdeschepper](https://github.com/keesdeschepper), [@kiernann](https://github.com/kiernann), [@knausb](https://github.com/knausb), [@krlmlr](https://github.com/krlmlr), [@kvittingseerup](https://github.com/kvittingseerup), [@lambdamoses](https://github.com/lambdamoses), [@leopoldsw](https://github.com/leopoldsw), [@lsaravia](https://github.com/lsaravia), [@MihaiBabiac](https://github.com/MihaiBabiac), [@mkearney](https://github.com/mkearney), [@mlaunois](https://github.com/mlaunois), [@mmuurr](https://github.com/mmuurr), [@moodymudskipper](https://github.com/moodymudskipper), [@MZellou](https://github.com/MZellou), [@nacnudus](https://github.com/nacnudus), [@natecobb](https://github.com/natecobb), [@NFA](https://github.com/NFA), [@NikKrieger](https://github.com/NikKrieger), [@njtierney](https://github.com/njtierney), [@nogeel](https://github.com/nogeel), [@orderlyquant](https://github.com/orderlyquant), [@oscci](https://github.com/oscci), [@Ozan147](https://github.com/Ozan147), [@pcgreen7](https://github.com/pcgreen7), [@perog](https://github.com/perog), [@phil-grayson](https://github.com/phil-grayson), [@pralitp](https://github.com/pralitp), [@psychelzh](https://github.com/psychelzh), [@QuLogic](https://github.com/QuLogic), [@r2evans](https://github.com/r2evans), [@Rajesh-Ramasamy](https://github.com/Rajesh-Ramasamy), [@ralsouza](https://github.com/ralsouza), [@rcragun](https://github.com/rcragun), [@romainfrancois](https://github.com/romainfrancois), [@salim-b](https://github.com/salim-b), [@sfrenk](https://github.com/sfrenk), [@Shians](https://github.com/Shians), [@shrektan](https://github.com/shrektan), [@skaltman](https://github.com/skaltman), [@sonhan18](https://github.com/sonhan18), [@StevenMMortimer](https://github.com/StevenMMortimer), [@thays42](https://github.com/thays42), [@ThePrez](https://github.com/ThePrez), [@tmalsburg](https://github.com/tmalsburg), [@TrentLobdell](https://github.com/TrentLobdell), [@ttimbers](https://github.com/ttimbers), [@vnijs](https://github.com/vnijs), [@wch](https://github.com/wch), [@we-hop](https://github.com/we-hop), [@wehopkins](https://github.com/wehopkins), [@wibeasley](https://github.com/wibeasley), [@wolski](https://github.com/wolski), [@wwgordon](https://github.com/wwgordon), [@xianwenchen](https://github.com/xianwenchen), [@xiaodaigh](https://github.com/xiaodaigh), [@xinyue-li](https://github.com/xinyue-li), [@yutannihilation](https://github.com/yutannihilation), [@Zack-83](https://github.com/Zack-83), and [@zenggyu](https://github.com/zenggyu).

