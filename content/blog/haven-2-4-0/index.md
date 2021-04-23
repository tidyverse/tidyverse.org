---
output: hugodown::hugo_document

slug: haven-2-4-0
title: haven 2.4.0
date: 2021-04-15
author: Hadley Wickham
description: >
    This version provides much improved `labelled_spss()` support, improved
    date-time handling, the latest ReadStat, and a bunch of other small 
    improvements.

photo:
  url: https://unsplash.com/photos/SHA85I0G8K4
  author: Evgeni Tcherkasski

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [haven]
rmd_hash: 36763699ee08e49a

---

We're delighted to announce the release of [haven](https://haven.tidyverse.org) 2.4.0. haven allows you to read and write SAS, SPSS, and Stata data formats from R, thanks to the wonderful [ReadStat](https://github.com/WizardMac/ReadStat) C library written by [Evan Miller](https://www.evanmiller.org/).

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"haven"</span><span class='o'>)</span></code></pre>

</div>

This blog post will show off the most important changes to the package; you can see a full list of changes in the [release notes](https://github.com/tidyverse/haven/releases/tag/v2.4.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://haven.tidyverse.org'>haven</a></span><span class='o'>)</span></code></pre>

</div>

## `labelled_spss()` and `labelled()`

[`labelled_spss()`](https://haven.tidyverse.org/reference/labelled_spss.html) gains full vctrs support thanks to the hard work of [Danny Smith](https://github.com/gorcha). This means that [`labelled_spss()`](https://haven.tidyverse.org/reference/labelled_spss.html) objects should now work seamlessly with dplyr 1.0.0, tidyr 1.0.0.

I've also made [`labelled()`](https://haven.tidyverse.org/reference/labelled.html) vectors are more permissive when concatenating. Now, output labels will be a combination of the left-hand and the right-hand side, and if there are duplicate labels, the left-hand side (first assigned) will win:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>x1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://haven.tidyverse.org/reference/labelled.html'>labelled</a></span><span class='o'>(</span><span class='m'>1</span>, labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>USA <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>x2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://haven.tidyverse.org/reference/labelled.html'>labelled</a></span><span class='o'>(</span><span class='m'>64</span>, labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>NZ <span class='o'>=</span> <span class='m'>64</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='nv'>x2</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;labelled&lt;double&gt;[2]&gt;</span>
<span class='c'>#&gt; [1]  1 64</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Labels:</span>
<span class='c'>#&gt;  value label</span>
<span class='c'>#&gt;      1   USA</span>
<span class='c'>#&gt;     64    NZ</span>

<span class='c'># It's now your responsibility to only combine things that make sense</span>
<span class='nv'>x3</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://haven.tidyverse.org/reference/labelled.html'>labelled</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>5</span>, <span class='m'>3</span>, <span class='m'>2</span><span class='o'>)</span>, labels <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span>Good <span class='o'>=</span> <span class='m'>5</span>, Bad <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='nv'>x3</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;labelled&lt;double&gt;[6]&gt;</span>
<span class='c'>#&gt; [1] 1 1 2 5 3 2</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; Labels:</span>
<span class='c'>#&gt;  value label</span>
<span class='c'>#&gt;      1   USA</span>
<span class='c'>#&gt;      5  Good</span></code></pre>

</div>

## Other improvements

-   Date-times are no longer converted to UTC. This should ensure that you *see* the same date-time in R and in Stata/SPSS/SAS. (But the underlying time point might be different because Stata/SPSS/SAS don't appear to support time zones.)

-   Bundleed ReadStat has been updated to version 1.1.5 from 1.1.3 so includes ReadStat improvements in [v1.1.5](https://github.com/WizardMac/ReadStat/releases/tag/v1.1.5) and [v1.1.4](https://github.com/WizardMac/ReadStat/releases/tag/v1.1.4). Probably the biggest improvement is support for SAS-binary (aka Ross) compression.

-   `write_*()` now validates file and variable metadata with ReadStat, and validation failures now provide more details about the source of the problem (e.g. the column name), making it easier to track down issues.

## Acknowledgements

A big thanks to everyone who helped make this release possible by asking questions, providing reprexes, writing code and more! [@Ales-G](https://github.com/Ales-G), [@atungate](https://github.com/atungate), [@batpigandme](https://github.com/batpigandme), [@bergen288](https://github.com/bergen288), [@bergsmat](https://github.com/bergsmat), [@BernhardClemm](https://github.com/BernhardClemm), [@bhaney22](https://github.com/bhaney22), [@cimentadaj](https://github.com/cimentadaj), [@copernican](https://github.com/copernican), [@DanChaltiel](https://github.com/DanChaltiel), [@DavidLukeThiessen](https://github.com/DavidLukeThiessen), [@deschen1](https://github.com/deschen1), [@drag05](https://github.com/drag05), [@drevanzyl](https://github.com/drevanzyl), [@dsteuer](https://github.com/dsteuer), [@dswpg](https://github.com/dswpg), [@dusadrian](https://github.com/dusadrian), [@elfatherbrown](https://github.com/elfatherbrown), [@gorcha](https://github.com/gorcha), [@gowerc](https://github.com/gowerc), [@hadley](https://github.com/hadley), [@hhchang0210](https://github.com/hhchang0210), [@hjvdwijk](https://github.com/hjvdwijk), [@iamforerunner](https://github.com/iamforerunner), [@j-sirgo](https://github.com/j-sirgo), [@jacciz](https://github.com/jacciz), [@jackobailey](https://github.com/jackobailey), [@jaydennord](https://github.com/jaydennord), [@jimhester](https://github.com/jimhester), [@jkhanson1970](https://github.com/jkhanson1970), [@kambanane](https://github.com/kambanane), [@krlmlr](https://github.com/krlmlr), [@kwainfan](https://github.com/kwainfan), [@larmarange](https://github.com/larmarange), [@lionel-](https://github.com/lionel-), [@MartinLBarron](https://github.com/MartinLBarron), [@oliverbock](https://github.com/oliverbock), [@ookiiwani](https://github.com/ookiiwani), [@peterolejua](https://github.com/peterolejua), [@realrbird](https://github.com/realrbird), [@resuf](https://github.com/resuf), [@rpruim](https://github.com/rpruim), [@rubenarslan](https://github.com/rubenarslan), [@sclewis23](https://github.com/sclewis23), [@shannonpileggi](https://github.com/shannonpileggi), [@sjkiss](https://github.com/sjkiss), [@toerpe](https://github.com/toerpe), [@tslumley](https://github.com/tslumley), [@xlejx-rodsxn](https://github.com/xlejx-rodsxn), [@xmatic](https://github.com/xmatic), and [@zahlenzauber](https://github.com/zahlenzauber).

