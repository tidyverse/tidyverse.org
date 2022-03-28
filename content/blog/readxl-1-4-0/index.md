---
output: hugodown::hugo_document

slug: readxl-1-4-0
title: readxl 1.4.0
date: 2022-03-28
author: Jenny Bryan
description: >
    readxl 1.4.0 is a maintenance release with practically no user-facing
    changes, but extensive change to package internals.

photo:
  url: https://unsplash.com/photos/tpAyLp9Ro50
  author: Ryan

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [readxl]
rmd_hash: 471be5498ec9ab41

---

We're pleased to announce the release of [readxl](https://readxl.tidyverse.org) 1.4.0. The readxl package makes it easy to get tabular data out of Excel files and into R with code, not mouse clicks. It supports both the legacy `.xls` format and the modern XML-based `.xlsx` format. readxl is designed to be easy to install (so: no external dependencies) and to cope with many of the less savory features of Excel files created by humans and 3rd party applications.

The easiest way to install the latest version from CRAN is to install the whole tidyverse.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"tidyverse"</span><span class='o'>)</span></code></pre>

</div>

Alternatively, install just readxl from CRAN:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"readxl"</span><span class='o'>)</span></code></pre>

</div>

Regardless, you will still need to attach readxl explicitly. It is not a core tidyverse package, i.e. readxl is NOT attached via [`library(tidyverse)`](https://tidyverse.tidyverse.org). Instead, do this in your script:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://readxl.tidyverse.org'>readxl</a></span><span class='o'>)</span></code></pre>

</div>

This release has practically no changes that should be noticeable by the typical user. However, internally, there have been extensive updates that set the stage for future user-facing improvements. Therefore, this post will be quite short and the main point is to encourage readxl users to kick the tires. We set out to upgrade the foundation to support building new features and we'd love to hear about any unintended regressions.

You can see a full list of changes in the [release notes](https://readxl.tidyverse.org/news/index.html).

## Updated libxls

readxl now embeds libxls v1.6.2 (the previous release embedded v1.5.0). The libxls project is maintained by Evan Miller and is hosted at <https://github.com/libxls/libxls>, where you can read more in its [release notes](https://github.com/libxls/libxls/releases).

## Switch from Rcpp to cpp11

Thanks to Shelby Bearrows, readxl now uses [cpp11](https://cpp11.r-lib.org) to manage the interface to the embedded RapidXML and libxls libraries. Shelby is a new member of the tidyverse team and she [blogged about this project](https://www.tidyverse.org/blog/2021/09/updating-to-cpp11/) during her 2021 summer internship.

## Other small improvements and what's next

"Date or Not Date": readxl's understanding of number formats has gotten more sophisticated (thanks [@nacnudus](https://github.com/nacnudus) and [@reviewher](https://github.com/reviewher)!). Non-datetime formats that incorporate colours or currencies should no longer be confused with datetime formats. We anticipate this will result in more accurate guessing of cell and column types.

What's coming next? I won't go so far as to promise that 2022 is the year of readxl 😉. But I can say that top priorities include equipping readxl with better problem reporting and column specification, making its interface feel more similar to that of [readr](https://readr.tidyverse.org) and [vroom](https://vroom.r-lib.org).

## Acknowledgements

Thanks to the 103 people who have contributed to readxl since we last blogged about it (upon the release of version 1.2.0 in December 2018) by reporting bugs and suggesting new features: [@abcdef123ghi](https://github.com/abcdef123ghi), [@acvelozo](https://github.com/acvelozo), [@ahbon123](https://github.com/ahbon123), [@ajit555](https://github.com/ajit555), [@artinmg](https://github.com/artinmg), [@aswansyahputra](https://github.com/aswansyahputra), [@averiperny](https://github.com/averiperny), [@batpigandme](https://github.com/batpigandme), [@ben1787](https://github.com/ben1787), [@benmatthewsed](https://github.com/benmatthewsed), [@benwatsoncpa](https://github.com/benwatsoncpa), [@benzipperer](https://github.com/benzipperer), [@bhive01](https://github.com/bhive01), [@bjorn81](https://github.com/bjorn81), [@boshek](https://github.com/boshek), [@brkbrc](https://github.com/brkbrc), [@Brunox13](https://github.com/Brunox13), [@cderv](https://github.com/cderv), [@DavisVaughan](https://github.com/DavisVaughan), [@ddekadt](https://github.com/ddekadt), [@dkgaraujo](https://github.com/dkgaraujo), [@donnekgit](https://github.com/donnekgit), [@druedin](https://github.com/druedin), [@dxbhans](https://github.com/dxbhans), [@elephann](https://github.com/elephann), [@eringrand](https://github.com/eringrand), [@estern95](https://github.com/estern95), [@fary90](https://github.com/fary90), [@fermumen](https://github.com/fermumen), [@fndemarqui](https://github.com/fndemarqui), [@gaborcsardi](https://github.com/gaborcsardi), [@gbganalyst](https://github.com/gbganalyst), [@ghost](https://github.com/ghost), [@hadley](https://github.com/hadley), [@hammao](https://github.com/hammao), [@hannes101](https://github.com/hannes101), [@hddao](https://github.com/hddao), [@hidekoji](https://github.com/hidekoji), [@HughParsonage](https://github.com/HughParsonage), [@idontgetoutmuch](https://github.com/idontgetoutmuch), [@j-sirgo](https://github.com/j-sirgo), [@jennybc](https://github.com/jennybc), [@jeromyanglim](https://github.com/jeromyanglim), [@jimhester](https://github.com/jimhester), [@jmcurran](https://github.com/jmcurran), [@josh-m-sharpe](https://github.com/josh-m-sharpe), [@jwhendy](https://github.com/jwhendy), [@jzadra](https://github.com/jzadra), [@kfhk](https://github.com/kfhk), [@kiernann](https://github.com/kiernann), [@ksetdekov](https://github.com/ksetdekov), [@kwebihaf-github](https://github.com/kwebihaf-github), [@llrs](https://github.com/llrs), [@loureynolds](https://github.com/loureynolds), [@lucasmation](https://github.com/lucasmation), [@lucifersFall1n1](https://github.com/lucifersFall1n1), [@luisvalenzuelar](https://github.com/luisvalenzuelar), [@matthiasgomolka](https://github.com/matthiasgomolka), [@MeoWoo6](https://github.com/MeoWoo6), [@MichaelChirico](https://github.com/MichaelChirico), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@misea](https://github.com/misea), [@mkoohafkan](https://github.com/mkoohafkan), [@moodymudskipper](https://github.com/moodymudskipper), [@msgoussi](https://github.com/msgoussi), [@nacnudus](https://github.com/nacnudus), [@narayanana](https://github.com/narayanana), [@nfultz](https://github.com/nfultz), [@nickschurch](https://github.com/nickschurch), [@nlneas1](https://github.com/nlneas1), [@nqkhanh2209](https://github.com/nqkhanh2209), [@ntsigilis](https://github.com/ntsigilis), [@pitakakariki](https://github.com/pitakakariki), [@pmallot](https://github.com/pmallot), [@qdread](https://github.com/qdread), [@queleanalytics](https://github.com/queleanalytics), [@ramay](https://github.com/ramay), [@ramiromagno](https://github.com/ramiromagno), [@Rindrics](https://github.com/Rindrics), [@rsbivand](https://github.com/rsbivand), [@rwbaer](https://github.com/rwbaer), [@saanasum](https://github.com/saanasum), [@sbearrows](https://github.com/sbearrows), [@Sbirch556](https://github.com/Sbirch556), [@seanchrismurphy](https://github.com/seanchrismurphy), [@Shicheng-Guo](https://github.com/Shicheng-Guo), [@Sibojang9](https://github.com/Sibojang9), [@simowaves](https://github.com/simowaves), [@smsaladi](https://github.com/smsaladi), [@songc-93](https://github.com/songc-93), [@SteveDeitz](https://github.com/SteveDeitz), [@struckma](https://github.com/struckma), [@sureshvigneshbe](https://github.com/sureshvigneshbe), [@tfulge](https://github.com/tfulge), [@topepo](https://github.com/topepo), [@ucb](https://github.com/ucb), [@vchouraki](https://github.com/vchouraki), [@wanttobenatural](https://github.com/wanttobenatural), [@wgrundlingh](https://github.com/wgrundlingh), [@WilDoane](https://github.com/WilDoane), [@zerogetsamgow](https://github.com/zerogetsamgow), [@zhangbs92](https://github.com/zhangbs92), and [@zx8754](https://github.com/zx8754).

