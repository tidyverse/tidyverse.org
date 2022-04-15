---
output: hugodown::hugo_document

slug: haven-2-5-0
title: haven 2.5.0
date: 2022-04-15
author: Hadley Wickham
description: >
  haven 2.5.0 adds support for custom character widths, creates FDA compliant
  XPT files, and can use Stata's `strL` variable type.
photo:
  url: https://unsplash.com/photos/VsPsf4F5Pi0
  author: Nathan Jennings

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [haven]
rmd_hash: 78c1c34ab8c75ebc

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
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're chuffed to announce the release of [haven](https://haven.tidyverse.org) 2.5.0. haven allows you to read and write SAS, SPSS, and Stata data formats from R, thanks to the wonderful [ReadStat](https://github.com/WizardMac/ReadStat) C library written by [Evan Miller](https://www.evanmiller.org/).

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"haven"</span><span class='o'>)</span></code></pre>

</div>

The most important news for this release is that [Danny Smith](https://github.com/gorcha) is now a haven author in recognition of his significant and sustained contributions. He contributed the majority of improvements and bug fixes to this release.

Other improvements of note:

-   You can set custom variable widths when writing by setting the the `width` attribute of the variable.

-   You can create FDA compliant SAS transport files with haven thanks to the addition of custom variable width support and some XPT writing related bug fixes.

-   `write_dta()` now supports Stata's `StrL` variables. This means that it's possible to write Stata files containing strings longer than 2045 characters, which was previously a hard upper limit.

You can see a full list of changes in the [release notes](https://github.com/tidyverse/haven/blob/main/NEWS.md).

## Acknowledgements

A big thanks to all 24 folks who contributed to this released by filing issues or creating pull requests: [@aito123](https://github.com/aito123), [@arnaud-feldmann](https://github.com/arnaud-feldmann), [@brianstamper](https://github.com/brianstamper), [@dusadrian](https://github.com/dusadrian), [@elimillera](https://github.com/elimillera), [@etiennebacher](https://github.com/etiennebacher), [@geebioso](https://github.com/geebioso), [@gorcha](https://github.com/gorcha), [@hadley](https://github.com/hadley), [@jakoberr](https://github.com/jakoberr), [@jennybc](https://github.com/jennybc), [@juansebastianl](https://github.com/juansebastianl), [@khanhhtt](https://github.com/khanhhtt), [@Luke791](https://github.com/Luke791), [@manhnguyen48](https://github.com/manhnguyen48), [@maxecharel](https://github.com/maxecharel), [@MokeEire](https://github.com/MokeEire), [@Nate884](https://github.com/Nate884), [@pskoulgi](https://github.com/pskoulgi), [@Sama2than](https://github.com/Sama2than), [@Shaunson26](https://github.com/Shaunson26), [@sjkiss](https://github.com/sjkiss), [@szimmer](https://github.com/szimmer), and [@yangwenghou123](https://github.com/yangwenghou123).

