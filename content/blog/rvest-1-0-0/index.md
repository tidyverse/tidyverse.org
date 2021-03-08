---
output: hugodown::hugo_document

slug: rvest-1-0-0
title: rvest 1.0.0
date: 2021-03-08
author: Hadley Wickham
description: >
    The latest version of rvest brings new tools for extracting text,
    a radically improved `html_table()`, and a bunch of interface changes
    to better align rvest with the rest of the tidyverse.

photo:
  url: https://unsplash.com/photos/b1FS5jQrsLo
  author: Bence Balla-Schottner

categories: [package] 
tags: [rvest]
rmd_hash: badfb4325bedd097

---

We're tickled pink to announce the release of [rvest](https://rvest.tidyverse.org) 1.0.0. rvest is designed to make it easy to scrape (i.e. harvest) data from HTML web pages.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"rvest"</span><span class='o'>)</span></code></pre>

</div>

This release includes two major improvements that make it easier to extract text and tables. I also took this opportunity to tidy up the interface to be better match the tidyverse standards that have emerged since rvest was created in 2012. This is a major release that marks rvest as [stable](https://lifecycle.r-lib.org/articles/stages.html#stable). That means we promise to avoid breaking changes as much as possible, and where they are needed, we will provided a significant deprecation cycle.

You can see a full list of changes in the [release notes](%7B%20github_release%20%7D).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rvest.tidyverse.org/'>rvest</a></span><span class='o'>)</span></code></pre>

</div>

## New features

It's been a while since I took a good look at rvest, and the GitHub issues suggested that there were two sources of long-standing frustration with rvest: [`html_text()`](https://rvest.tidyverse.org/reference/html_text.html) and [`html_table()`](https://rvest.tidyverse.org/reference/html_table.html).

[`html_text()`](https://rvest.tidyverse.org/reference/html_text.html) was a source of frustration because it extracts raw text from underlying HTML. It ignores HTML's line breaks (i.e. `<br>`) but preserves non-significant whitespace, making it a pain to use:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>html</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rvest.tidyverse.org/reference/minimal_html.html'>minimal_html</a></span><span class='o'>(</span>
  <span class='s'>"&lt;p&gt;  
    This is a paragraph.
    This another sentence.&lt;br&gt;This should start on a new line
  &lt;/p&gt;"</span>
<span class='o'>)</span>
<span class='nv'>html</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rvest.tidyverse.org/reference/html_text.html'>html_text</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt;   </span>
<span class='c'>#&gt;     This is a paragraph.</span>
<span class='c'>#&gt;     This another sentence.This should start on a new line</span>
<span class='c'>#&gt; </span></code></pre>

</div>

The new [`html_text2()`](https://rvest.tidyverse.org/reference/html_text.html) is inspired by Javascript's `innerText()` function and uses a handful of heuristics to generate more useful output:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>html</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rvest.tidyverse.org/reference/html_text.html'>html_text2</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>%&gt;%</span> <span class='nf'><a href='https://rdrr.io/r/base/writeLines.html'>writeLines</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; This is a paragraph. This another sentence.</span>
<span class='c'>#&gt; This should start on a new line</span></code></pre>

</div>

[`html_table()`](https://rvest.tidyverse.org/reference/html_table.html) was frustrating because it failed on many tables that used row or column spans. I've now re-written it from scratch, closely following the algorithm that browsers use. This means that there are far fewer tables for which it fails to produce useful output, and I have deprecated the `fill` argument because it's no longer needed.

Here's a little example with row span, column span, and a missing cell:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>html</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rvest.tidyverse.org/reference/minimal_html.html'>minimal_html</a></span><span class='o'>(</span><span class='s'>"&lt;table&gt;
  &lt;tr&gt;&lt;th&gt;A&lt;/th&gt;&lt;th&gt;B&lt;/th&gt;&lt;th&gt;C&lt;/th&gt;&lt;/tr&gt;
  &lt;tr&gt;&lt;td colspan='2' rowspan='2'&gt;1&lt;/td&gt;&lt;td&gt;2&lt;/td&gt;&lt;/tr&gt;
  &lt;tr&gt;&lt;td rowspan='2'&gt;3&lt;/td&gt;&lt;/tr&gt;
  &lt;tr&gt;&lt;td&gt;4&lt;/td&gt;&lt;/tr&gt;
&lt;/table&gt;"</span><span class='o'>)</span>

<span class='nv'>html</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rvest.tidyverse.org/reference/html_element.html'>html_element</a></span><span class='o'>(</span><span class='s'>"table"</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rvest.tidyverse.org/reference/html_table.html'>html_table</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 3</span></span>
<span class='c'>#&gt;       <span style='font-weight: bold;'>A</span><span>     </span><span style='font-weight: bold;'>B</span><span>     </span><span style='font-weight: bold;'>C</span></span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span>     1     1     2</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span>     1     1     3</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span>     4    </span><span style='color: #BB0000;'>NA</span><span>     3</span></span></code></pre>

</div>

[`html_table()`](https://rvest.tidyverse.org/reference/html_table.html) now returns a tibble rather than a data frame (to be more compatible with the rest of the tidyverse) and its performance has been considerably improved (10x for the [motivating example](https://github.com/tidyverse/rvest/issues/237)). It also gains new `na.strings` and `convert` arguments to better control how `NA`s and strings are processed. See the docs for more details.

While it's not a major feature, its worth noting that rvest is now much smaller (\~100 Kb vs \~1 Mb) thanks to a rewrite of `vignette("rvest")` and making the [SelectorGadget article](https://rvest.tidyverse.org/articles/articles/selectorgadget.html) web-only.

## API changes

Since this is the 1.0.0 release, I included a large number of API changes to make rvest more compatible with current tidyverse conventions. Older functions have been deprecated, so existing code will continue to work (albeit with a few new warnings).

-   rvest now imports xml2 rather than depending on it. This is cleaner because it avoids attaching all the xml2 functions that you're probably not going to use. To reduce the change of breakages, rvest re-exports xml2 functions [`read_html()`](http://xml2.r-lib.org/reference/read_xml.html) and [`url_absolute()`](http://xml2.r-lib.org/reference/url_absolute.html); if you use other functions, your code will now need an explicit [`library(xml2)`](https://xml2.r-lib.org/).

-   [`html_form()`](https://rvest.tidyverse.org/reference/html_form.html) now returns an object with class `rvest_form`. Fields within a form now have class `rvest_field`, instead of a variety of classes that were lacking the `rvest_` prefix. All functions for working with forms have a common `html_form_` prefix, e.g. [`set_values()`](https://rvest.tidyverse.org/reference/rename.html) became [`html_form_set()`](https://rvest.tidyverse.org/reference/html_form.html).

-   [`html_node()`](https://rvest.tidyverse.org/reference/rename.html) and [`html_nodes()`](https://rvest.tidyverse.org/reference/rename.html) have been superseded in favor of [`html_element()`](https://rvest.tidyverse.org/reference/html_element.html) and [`html_elements()`](https://rvest.tidyverse.org/reference/html_element.html) since they (almost) always return elements, not nodes. This vocabulary will better match what you're likely to see when learning about HTML.

-   [`html_session()`](https://rvest.tidyverse.org/reference/rename.html) is now [`session()`](https://rvest.tidyverse.org/reference/session.html) and returns an object of class `rvest_session`. All functions that work with session objects now have a common `session_` prefix.

-   Long deprecated `html()`, `html_tag()`, `xml()` functions have been removed.

-   [`minimal_html()`](https://rvest.tidyverse.org/reference/minimal_html.html) (which doesn't appear to be used by any other package) has had its arguments flipped to make it more intuitive.

-   [`guess_encoding()`](https://rvest.tidyverse.org/reference/html_encoding_guess.html) has been renamed to [`html_encoding_guess()`](https://rvest.tidyverse.org/reference/html_encoding_guess.html) to avoid a clash with `stringr::guess_encoding()`. [`repair_encoding()`](https://rvest.tidyverse.org/reference/repair_encoding.html) was deprecated because it doesn't appear to have ever worked.

-   `pluck()` is no longer exported to avoid a clash with [`purrr::pluck()`](https://purrr.tidyverse.org/reference/pluck.html); if you need it use [`purrr::map_chr()`](https://purrr.tidyverse.org/reference/map.html) and friends instead.

-   [`xml_tag()`](https://rvest.tidyverse.org/reference/rename.html), [`xml_node()`](https://rvest.tidyverse.org/reference/rename.html), and [`xml_nodes()`](https://rvest.tidyverse.org/reference/rename.html) have been formally deprecated in favour of their `html_` equivalents.

## Acknowledgements

A big thanks to all the folks who helped make this release possible through their issues, comments, and pull requests 😄

[@13kay](https://github.com/13kay), [@adam52](https://github.com/adam52), [@AgnieszkaTomczyk](https://github.com/AgnieszkaTomczyk), [@ahaseemkunjucl](https://github.com/ahaseemkunjucl), [@akshaynagpal](https://github.com/akshaynagpal), [@AlanMex1990](https://github.com/AlanMex1990), [@alex23lemm](https://github.com/alex23lemm), [@amjiuzi](https://github.com/amjiuzi), [@antoine-lizee](https://github.com/antoine-lizee), [@arilamstein](https://github.com/arilamstein), [@artemklevtsov](https://github.com/artemklevtsov), [@batpigandme](https://github.com/batpigandme), [@bbrewington](https://github.com/bbrewington), [@bedantaguru](https://github.com/bedantaguru), [@bramtayl](https://github.com/bramtayl), [@brshallo](https://github.com/brshallo), [@charleswg](https://github.com/charleswg), [@christopherhastings](https://github.com/christopherhastings), [@chuchu89](https://github.com/chuchu89), [@conjugateprior](https://github.com/conjugateprior), [@cpsievert](https://github.com/cpsievert), [@craigcitro](https://github.com/craigcitro), [@cranknasty](https://github.com/cranknasty), [@cungbac](https://github.com/cungbac), [@curtisalexander](https://github.com/curtisalexander), [@cwickham](https://github.com/cwickham), [@data-steve](https://github.com/data-steve), [@dbuijs](https://github.com/dbuijs), [@Deleetdk](https://github.com/Deleetdk), [@dholstius](https://github.com/dholstius), [@DiegoKoz](https://github.com/DiegoKoz), [@dmi3kno](https://github.com/dmi3kno), [@dpprdan](https://github.com/dpprdan), [@englianhu](https://github.com/englianhu), [@etabeta78](https://github.com/etabeta78), [@ethanbsmith](https://github.com/ethanbsmith), [@flpezet](https://github.com/flpezet), [@garrettgman](https://github.com/garrettgman), [@georgevbsantiago](https://github.com/georgevbsantiago), [@geotheory](https://github.com/geotheory), [@ghost](https://github.com/ghost), [@gokceneraslan](https://github.com/gokceneraslan), [@gunawebs](https://github.com/gunawebs), [@hadley](https://github.com/hadley), [@happyshows](https://github.com/happyshows), [@hauj12123](https://github.com/hauj12123), [@HBossier](https://github.com/HBossier), [@hemans](https://github.com/hemans), [@higgi13425](https://github.com/higgi13425), [@himanshudhingra](https://github.com/himanshudhingra), [@hsancen](https://github.com/hsancen), [@ignotus0001](https://github.com/ignotus0001), [@ilarischeinin](https://github.com/ilarischeinin), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@iProcrastinate](https://github.com/iProcrastinate), [@jaanos](https://github.com/jaanos), [@JackWilb](https://github.com/JackWilb), [@JakeRuss](https://github.com/JakeRuss), [@jamjaemin](https://github.com/jamjaemin), [@javrucebo](https://github.com/javrucebo), [@jeffisabelle](https://github.com/jeffisabelle), [@jeroen](https://github.com/jeroen), [@jeroenjanssens](https://github.com/jeroenjanssens), [@jgilfillan](https://github.com/jgilfillan), [@jimhester](https://github.com/jimhester), [@jjchern](https://github.com/jjchern), [@jl5000](https://github.com/jl5000), [@jlewis91](https://github.com/jlewis91), [@jmgirard](https://github.com/jmgirard), [@johncollins](https://github.com/johncollins), [@JohnMount](https://github.com/JohnMount), [@jonathan-g](https://github.com/jonathan-g), [@Jonathanyni](https://github.com/Jonathanyni), [@joranE](https://github.com/joranE), [@joshualeond](https://github.com/joshualeond), [@jpmarindiaz](https://github.com/jpmarindiaz), [@jrnold](https://github.com/jrnold), [@jrosen48](https://github.com/jrosen48), [@juba](https://github.com/juba), [@jubjubbc](https://github.com/jubjubbc), [@jullybobble](https://github.com/jullybobble), [@kendonB](https://github.com/kendonB), [@kevin199011](https://github.com/kevin199011), [@kevinrue](https://github.com/kevinrue), [@kiernann](https://github.com/kiernann), [@kjschaudt](https://github.com/kjschaudt), [@ktaylora](https://github.com/ktaylora), [@ktmud](https://github.com/ktmud), [@kurtis14](https://github.com/kurtis14), [@leoluyi](https://github.com/leoluyi), [@LeslieTse](https://github.com/LeslieTse), [@lifan0127](https://github.com/lifan0127), [@litao1105](https://github.com/litao1105), [@magic-lantern](https://github.com/magic-lantern), [@MarcinKosinski](https://github.com/MarcinKosinski), [@markdanese](https://github.com/markdanese), [@MichaelChirico](https://github.com/MichaelChirico), [@mikegros](https://github.com/mikegros), [@mikemc](https://github.com/mikemc), [@MislavSag](https://github.com/MislavSag), [@mitchelloharawild](https://github.com/mitchelloharawild), [@mobcdi](https://github.com/mobcdi), [@Monduiz](https://github.com/Monduiz), [@moodymudskipper](https://github.com/moodymudskipper), [@mrchypark](https://github.com/mrchypark), [@MrFlick](https://github.com/MrFlick), [@msberends](https://github.com/msberends), [@msgoussi](https://github.com/msgoussi), [@myliserta](https://github.com/myliserta), [@mzorgdrager](https://github.com/mzorgdrager), [@nalimilan](https://github.com/nalimilan), [@neilfws](https://github.com/neilfws), [@NicolasRuth](https://github.com/NicolasRuth), [@nitishgupta4291](https://github.com/nitishgupta4291), [@noamross](https://github.com/noamross), [@np2201](https://github.com/np2201), [@npjc](https://github.com/npjc), [@oguzhanogreden](https://github.com/oguzhanogreden), [@OmarGonD](https://github.com/OmarGonD), [@oNIenSis](https://github.com/oNIenSis), [@oriolmirosa](https://github.com/oriolmirosa), [@Osc2wall](https://github.com/Osc2wall), [@petermeissner](https://github.com/petermeissner), [@petrbouchal](https://github.com/petrbouchal), [@PritishDsouza](https://github.com/PritishDsouza), [@PriyaShaji](https://github.com/PriyaShaji), [@pssguy](https://github.com/pssguy), [@qpmnguyen](https://github.com/qpmnguyen), [@r2evans](https://github.com/r2evans), [@rafaminos](https://github.com/rafaminos), [@ramnathv](https://github.com/ramnathv), [@renkun-ken](https://github.com/renkun-ken), [@rentrop](https://github.com/rentrop), [@richierocks](https://github.com/richierocks), [@rjpat](https://github.com/rjpat), [@romainfrancois](https://github.com/romainfrancois), [@rpalsaxena](https://github.com/rpalsaxena), [@salauer](https://github.com/salauer), [@SamoPP](https://github.com/SamoPP), [@san1289](https://github.com/san1289), [@sco-lo-digital](https://github.com/sco-lo-digital), [@seasmith](https://github.com/seasmith), [@sfirke](https://github.com/sfirke), [@sillasgonzaga](https://github.com/sillasgonzaga), [@slowkow](https://github.com/slowkow), [@smach](https://github.com/smach), [@smbache](https://github.com/smbache), [@stenevang](https://github.com/stenevang), [@StephaneKazmierczak](https://github.com/StephaneKazmierczak), [@stevecondylios](https://github.com/stevecondylios), [@swiftsam](https://github.com/swiftsam), [@swishderzy](https://github.com/swishderzy), [@targeteer](https://github.com/targeteer), [@tbates](https://github.com/tbates), [@The-Janitor](https://github.com/The-Janitor), [@thomasd2](https://github.com/thomasd2), [@tomasbarcellos](https://github.com/tomasbarcellos), [@TyGu1](https://github.com/TyGu1), [@wbuchanan](https://github.com/wbuchanan), [@WHardyPL](https://github.com/WHardyPL), [@WilDoane](https://github.com/WilDoane), [@wldnjs](https://github.com/wldnjs), [@yogesh1612](https://github.com/yogesh1612), [@yrochat](https://github.com/yrochat), [@yutannihilation](https://github.com/yutannihilation), and [@zheguzai100](https://github.com/zheguzai100).

