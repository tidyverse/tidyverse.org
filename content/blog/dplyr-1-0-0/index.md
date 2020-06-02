---
title: dplyr 1.0.0 available now!
output: hugodown::hugo_document

description: > 
  dplyr 1.0.0 is now available from CRAN!
author: Hadley Wickham
date: '2020-06-01'
slug: dplyr-1-0-0

photo:
  url: https://unsplash.com/photos/W8BNwvOvW4M
  author: Helinton Fantin

categories:
  - package
tags:
  - dplyr
  - dplyr-1-0-0
rmd_hash: c8c1616035516090

---

I'm very excited to announce the ninth and final blog post in the [dplyr 1.0.0 series](/tags/dplyr-1-0-0): [dplyr 1.0.0](http://dplyr.tidyverse.org/) is now available from CRAN! Install it by running:

<pre class='chroma'><span class='nf'>install.packages</span>(<span class='s'>"dplyr"</span>)
</pre>

Then load it with:

<pre class='chroma'><span class='nf'>library</span>(<span class='k'><a href='https://dplyr.tidyverse.org/reference'>dplyr</a></span>)
</pre>

New features
------------

dplyr 1.0.0 is chock-a-block with new features; so many, in fact, that we can't fit them all into one post. So if you want to learn more about what's new, we recommend reading our existing series of posts:

-   [Major lifecycle changes](/blog/2020/03/dplyr-1-0-0-is-coming-soon/). This post focusses on the idea of the "function lifecycle" which helps you understand where functions in dplyr are going. Particularly important is the idea of a "superseded" function. A superseded function is not going away, but we no longer recommend using it in new code.

-   [New `summarise()` features](/blog/2020/03/dplyr-1-0-0-summarise/). In `summarise()`, a single summary expression can now create both multiple rows and multiple columns. This significantly increases its power and flexibility.

-   [`select()`, `rename()`, and (new) `relocate()`](/blog/2020/03/dplyr-1-0-0-select-rename-relocate/). `select()` and `rename()` can now select by position, name, function of name, type, and any combination thereof. A new `relocate()` function makes it easy to change the position of columns.

-   [Working `across()` columns](/blog/2020/04/dplyr-1-0-0-colwise/). A new `across()` function makes it much easier to apply the same operation to multiple columns. It supersedes the `_if()`, `_at()`, and `_all()` function variants.

-   [Working within rows](/blog/2020/04/dplyr-1-0-0-rowwise/). `rowwise()` has been renewed and revamped to make it easier to perform operations row-by-row. This makes it much easier to solve problems that previously required `base::lapply()`, `purrr::map()`, or friends.

-   [The role of the vctrs package](/blog/2020/04/dplyr-1-0-0-and-vctrs/). dplyr now makes heavy use of [vctrs](http://vctrs.r-lib.org/) behind the scenes. This brings with it greater consistency and (hopefully!) more useful error messages.

-   [Last minute additions](/blog/2020/05/dplyr-1-0-0-last-minute-additions/) `summarise()` now allows you to control how its results are grouped, and there's a new family of functions designed for modifying rows.

You can see the full list of changes in the [release notes](https://github.com/tidyverse/dplyr/releases/tag/v1.0.0).

New logo
--------

dplyr has a new logo thanks to the talented [Allison Horst](https://allisonhorst.github.io)!

<img src="dplyr.png" width="250" alt="New dplyr logo" /> 

(Stay tuned for details about how to get this sticker on to your laptop. We have some exciting news coming up!)

A small teaser
--------------

The best way to find out about all the cool new features dplyr has to offer is to read through the blog posts linked to above. But thanks to inspiration from [Daniel Anderson](https://twitter.com/datalorax_/status/1258208502960422914) here's one example of fitting two different models by subgroup that shows off a bunch of cool features:

<pre class='chroma'><span class='nf'>library</span>(<span class='k'><a href='https://dplyr.tidyverse.org/reference'>dplyr</a></span>, warn.conflicts = <span class='m'>FALSE</span>)

<span class='k'>models</span> <span class='o'>&lt;-</span> <span class='k'>tibble</span>::<span class='nf'><a href='https://tibble.tidyverse.org/reference/tribble.html'>tribble</a></span>(
  <span class='o'>~</span><span class='k'>model_name</span>,    <span class='o'>~</span> <span class='k'>formula</span>,
  <span class='s'>"length-width"</span>, <span class='k'>Sepal.Length</span> <span class='o'>~</span> <span class='k'>Petal.Width</span> <span class='o'>+</span> <span class='k'>Petal.Length</span>,
  <span class='s'>"interaction"</span>,  <span class='k'>Sepal.Length</span> <span class='o'>~</span> <span class='k'>Petal.Width</span> <span class='o'>*</span> <span class='k'>Petal.Length</span>
)

<span class='k'>iris</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/nest_by.html'>nest_by</a></span>(<span class='k'>Species</span>) <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate-joins.html'>left_join</a></span>(<span class='k'>models</span>, by = <span class='nf'>character</span>()) <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/rowwise.html'>rowwise</a></span>(<span class='k'>Species</span>, <span class='k'>model_name</span>) <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span>(model = <span class='nf'>list</span>(<span class='nf'>lm</span>(<span class='k'>formula</span>, data = <span class='k'>data</span>))) <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/summarise.html'>summarise</a></span>(<span class='k'>broom</span>::<span class='nf'><a href='https://rdrr.io/pkg/broom/man/reexports.html'>glance</a></span>(<span class='k'>model</span>))
<span class='c'>#&gt; `summarise()` regrouping output by 'Species', 'model_name' (override with `.groups` argument)</span>
<span class='c'>#&gt; # A tibble: 6 x 13</span>
<span class='c'>#&gt; # Groups:   Species, model_name [6]</span>
<span class='c'>#&gt;   Species model_name r.squared adj.r.squared sigma statistic  p.value    df</span>
<span class='c'>#&gt;   &lt;fct&gt;   &lt;chr&gt;          &lt;dbl&gt;         &lt;dbl&gt; &lt;dbl&gt;     &lt;dbl&gt;    &lt;dbl&gt; &lt;int&gt;</span>
<span class='c'>#&gt; 1 setosa  length-wi…     0.112        0.0739 0.339      2.96 6.18e- 2     3</span>
<span class='c'>#&gt; 2 setosa  interacti…     0.133        0.0760 0.339      2.34 8.54e- 2     4</span>
<span class='c'>#&gt; 3 versic… length-wi…     0.574        0.556  0.344     31.7  1.92e- 9     3</span>
<span class='c'>#&gt; 4 versic… interacti…     0.577        0.549  0.347     20.9  1.11e- 8     4</span>
<span class='c'>#&gt; 5 virgin… length-wi…     0.747        0.736  0.327     69.3  9.50e-15     3</span>
<span class='c'>#&gt; 6 virgin… interacti…     0.757        0.741  0.323     47.8  3.54e-14     4</span>
<span class='c'>#&gt; # … with 5 more variables: logLik &lt;dbl&gt;, AIC &lt;dbl&gt;, BIC &lt;dbl&gt;, deviance &lt;dbl&gt;,</span>
<span class='c'>#&gt; #   df.residual &lt;int&gt;</span>
</pre>

Note the use of:

-   The new `nest_by()`, which generates a nested data frame where each row represents one subgroup.

-   In `left_join()`, `by = character()` which now performs a Cartesian product, generating every combination of subgroup and model.

-   `rowwise()` and `mutate()` which fit a model to each row.

-   The newly powerful `summarise()` which summarises each model with the model fit statistics computed by `broom::glance()`.

Acknowledgements
----------------

dplyr 1.0.0 has been one of the biggest projects that we, as a team, have ever tackled. Almost everyone in the tidyverse team has been involved in some capacity. Special thanks go to Romain François, who in his role as primary developer has been working on this release for over six months, and to Lionel Henry and Davis Vaughn for all their work on the vctrs package. Jim Hester's work on running revdep checks in the cloud also made a big impact on our ability to understand failure modes.

A big thanks to all 137 members of the dplyr community who helped make this release possible by finding bugs, discussing issues, and writing code: [@AdaemmerP](https://github.com/AdaemmerP), [@adelarue](https://github.com/adelarue), [@ahernnelson](https://github.com/ahernnelson), [@alaataleb111](https://github.com/alaataleb111), [@antoine-sachet](https://github.com/antoine-sachet), [@atusy](https://github.com/atusy), [@Auld-Greg](https://github.com/Auld-Greg), [@b-rodrigues](https://github.com/b-rodrigues), [@batpigandme](https://github.com/batpigandme), [@bedantaguru](https://github.com/bedantaguru), [@benjaminschlegel](https://github.com/benjaminschlegel), [@benjbuch](https://github.com/benjbuch), [@bergsmat](https://github.com/bergsmat), [@billdenney](https://github.com/billdenney), [@brianmsm](https://github.com/brianmsm), [@bwiernik](https://github.com/bwiernik), [@caldwellst](https://github.com/caldwellst), [@cat-zeppelin](https://github.com/cat-zeppelin), [@chillywings](https://github.com/chillywings), [@clauswilke](https://github.com/clauswilke), [@colearendt](https://github.com/colearendt), [@DanChaltiel](https://github.com/DanChaltiel), [@danoreper](https://github.com/danoreper), [@danzafar](https://github.com/danzafar), [@davidbaniadam](https://github.com/davidbaniadam), [@DavisVaughan](https://github.com/DavisVaughan), [@dblodgett-usgs](https://github.com/dblodgett-usgs), [@ddsjoberg](https://github.com/ddsjoberg), [@deschen1](https://github.com/deschen1), [@dfrankow](https://github.com/dfrankow), [@DiegoKoz](https://github.com/DiegoKoz), [@dkahle](https://github.com/dkahle), [@DzimitryM](https://github.com/DzimitryM), [@earowang](https://github.com/earowang), [@echasnovski](https://github.com/echasnovski), [@edwindj](https://github.com/edwindj), [@elbersb](https://github.com/elbersb), [@elcega](https://github.com/elcega), [@ericemc3](https://github.com/ericemc3), [@espinielli](https://github.com/espinielli), [@FedericoConcas](https://github.com/FedericoConcas), [@FlukeAndFeather](https://github.com/FlukeAndFeather), [@GegznaV](https://github.com/GegznaV), [@gergness](https://github.com/gergness), [@ggrothendieck](https://github.com/ggrothendieck), [@glennmschultz](https://github.com/glennmschultz), [@gowerc](https://github.com/gowerc), [@greg-minshall](https://github.com/greg-minshall), [@gregorp](https://github.com/gregorp), [@ha0ye](https://github.com/ha0ye), [@hadley](https://github.com/hadley), [@Harrison4192](https://github.com/Harrison4192), [@henry090](https://github.com/henry090), [@hughjonesd](https://github.com/hughjonesd), [@ianmcook](https://github.com/ianmcook), [@ismailmuller](https://github.com/ismailmuller), [@isteves](https://github.com/isteves), [@its-gazza](https://github.com/its-gazza), [@j450h1](https://github.com/j450h1), [@Jagadeeshkb](https://github.com/Jagadeeshkb), [@jarauh](https://github.com/jarauh), [@jason-liu-cs](https://github.com/jason-liu-cs), [@jayqi](https://github.com/jayqi), [@JBGruber](https://github.com/JBGruber), [@jemus42](https://github.com/jemus42), [@jennybc](https://github.com/jennybc), [@jflournoy](https://github.com/jflournoy), [@jhuntergit](https://github.com/jhuntergit), [@JohannesNE](https://github.com/JohannesNE), [@jzadra](https://github.com/jzadra), [@karldw](https://github.com/karldw), [@kassambara](https://github.com/kassambara), [@klin333](https://github.com/klin333), [@knausb](https://github.com/knausb), [@kriemo](https://github.com/kriemo), [@krispiepage](https://github.com/krispiepage), [@krlmlr](https://github.com/krlmlr), [@kvasilopoulos](https://github.com/kvasilopoulos), [@larry77](https://github.com/larry77), [@leonawicz](https://github.com/leonawicz), [@lionel-](https://github.com/lionel-), [@lorenzwalthert](https://github.com/lorenzwalthert), [@LudvigOlsen](https://github.com/LudvigOlsen), [@madlogos](https://github.com/madlogos), [@markdly](https://github.com/markdly), [@markfairbanks](https://github.com/markfairbanks), [@meghapsimatrix](https://github.com/meghapsimatrix), [@meixiaba](https://github.com/meixiaba), [@melissagwolf](https://github.com/melissagwolf), [@mgirlich](https://github.com/mgirlich), [@Michael-Sheppard](https://github.com/Michael-Sheppard), [@mikmart](https://github.com/mikmart), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mir-cat](https://github.com/mir-cat), [@mjsmith037](https://github.com/mjsmith037), [@mlane3](https://github.com/mlane3), [@msberends](https://github.com/msberends), [@msgoussi](https://github.com/msgoussi), [@nefissakhd](https://github.com/nefissakhd), [@nick-youngblut](https://github.com/nick-youngblut), [@nzbart](https://github.com/nzbart), [@pavel-shliaha](https://github.com/pavel-shliaha), [@pdbailey0](https://github.com/pdbailey0), [@pnacht](https://github.com/pnacht), [@ponnet](https://github.com/ponnet), [@r2evans](https://github.com/r2evans), [@ramnathv](https://github.com/ramnathv), [@randy3k](https://github.com/randy3k), [@richardjtelford](https://github.com/richardjtelford), [@romainfrancois](https://github.com/romainfrancois), [@rorynolan](https://github.com/rorynolan), [@ryanvoyack](https://github.com/ryanvoyack), [@selesnow](https://github.com/selesnow), [@selin1st](https://github.com/selin1st), [@sewouter](https://github.com/sewouter), [@sfirke](https://github.com/sfirke), [@SimonDedman](https://github.com/SimonDedman), [@sjmgarnier](https://github.com/sjmgarnier), [@smingerson](https://github.com/smingerson), [@stefanocoretta](https://github.com/stefanocoretta), [@strengejacke](https://github.com/strengejacke), [@tfkillian](https://github.com/tfkillian), [@tilltnet](https://github.com/tilltnet), [@tonyvibe](https://github.com/tonyvibe), [@topepo](https://github.com/topepo), [@torockel](https://github.com/torockel), [@trinker](https://github.com/trinker), [@tungmilan](https://github.com/tungmilan), [@tzakharko](https://github.com/tzakharko), [@uasolo](https://github.com/uasolo), [@werkstattcodes](https://github.com/werkstattcodes), [@wlandau](https://github.com/wlandau), [@xiaoa6435](https://github.com/xiaoa6435), [@yiluheihei](https://github.com/yiluheihei), [@yutannihilation](https://github.com/yutannihilation), [@zenggyu](https://github.com/zenggyu), and [@zkamvar](https://github.com/zkamvar).

