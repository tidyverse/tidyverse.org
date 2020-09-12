---
output: hugodown::hugo_document

slug: pkgdown-1-6-0
title: pkgdown 1.6.0
date: 2020-09-12
author: Hadley Wickham
description: >
    This release mostly contains bug fixes and minor improvements, but
    it now uses the downlit and ragg packages for syntax highlighting and
    graphical output, respectively.

photo:
  url: https://unsplash.com/photos/GOQ32dlahDk
  author: Vitor Santos

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [pkgdown]
rmd_hash: 8ee9fc933bcbf8ef

---

We're stoked to announce the release of [pkgdown](%7B%20home%20%7D) 1.6.0. pkgdown is designed to make it quick and easy to build a website for your package. Install it with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span>(<span class='s'>"pkgdown"</span>)
</code></pre>

</div>

This release mostly contains a bunch of minor improvements and bug fixes that you can read about in the [release notes](https://pkgdown.r-lib.org/news/index.html#pkgdown-1-6-0-2020-09-07). But there are two major changes:

-   The syntax highlighing and autolinking is now powered by the new [downlit](https://downlit.r-lib.org) package. There should be very little change in behaviour because the code in downlit was extracted from pkgdown, but this will make it easier to use pkgdown's nice linking/highlighting in more places.

-   pkgdown now uses the [ragg](https://ragg.r-lib.org) package for graphical output in examples. This should be a little faster and will produce higher quality output that's the same on every operating systems.

Thanks!
-------

A big thanks to all 55 contributors who helped make this release possible with their bug reports, thoughtful discussion, and code contributions: [@Anirban166](https://github.com/Anirban166), [@batpigandme](https://github.com/batpigandme), [@bblodfon](https://github.com/bblodfon), [@benjaminleroy](https://github.com/benjaminleroy), [@cderv](https://github.com/cderv), [@chuxinyuan](https://github.com/chuxinyuan), [@DanChaltiel](https://github.com/DanChaltiel), [@dankelley](https://github.com/dankelley), [@davidchall](https://github.com/davidchall), [@davidhodge931](https://github.com/davidhodge931), [@DavisVaughan](https://github.com/DavisVaughan), [@dfsnow](https://github.com/dfsnow), [@donaldRwilliams](https://github.com/donaldRwilliams), [@Eluvias](https://github.com/Eluvias), [@erhla](https://github.com/erhla), [@fmmattioni](https://github.com/fmmattioni), [@GegznaV](https://github.com/GegznaV), [@GregorDeCillia](https://github.com/GregorDeCillia), [@gustavdelius](https://github.com/gustavdelius), [@hadley](https://github.com/hadley), [@hbaniecki](https://github.com/hbaniecki), [@jameslamb](https://github.com/jameslamb), [@jayhesselberth](https://github.com/jayhesselberth), [@jeffwong-nflx](https://github.com/jeffwong-nflx), [@jennybc](https://github.com/jennybc), [@jonkeane](https://github.com/jonkeane), [@jranke](https://github.com/jranke), [@kevinushey](https://github.com/kevinushey), [@klmr](https://github.com/klmr), [@krlmlr](https://github.com/krlmlr), [@lcolladotor](https://github.com/lcolladotor), [@maelle](https://github.com/maelle), [@maxheld83](https://github.com/maxheld83), [@mladenjovanovic](https://github.com/mladenjovanovic), [@ms609](https://github.com/ms609), [@mstr3336](https://github.com/mstr3336), [@ngreifer](https://github.com/ngreifer), [@OceaneCsn](https://github.com/OceaneCsn), [@padpadpadpad](https://github.com/padpadpadpad), [@pat-s](https://github.com/pat-s), [@paulponcet](https://github.com/paulponcet), [@ramiromagno](https://github.com/ramiromagno), [@randy3k](https://github.com/randy3k), [@rickhelmus](https://github.com/rickhelmus), [@royfrancis](https://github.com/royfrancis), [@schloerke](https://github.com/schloerke), [@statnmap](https://github.com/statnmap), [@stefanoborini](https://github.com/stefanoborini), [@tanho63](https://github.com/tanho63), [@ThierryO](https://github.com/ThierryO), [@thomas-neitmann](https://github.com/thomas-neitmann), [@ttimbers](https://github.com/ttimbers), [@wkmor1](https://github.com/wkmor1), [@zeileis](https://github.com/zeileis), and [@zkamvar](https://github.com/zkamvar).

