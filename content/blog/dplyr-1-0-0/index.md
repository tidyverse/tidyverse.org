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
rmd_hash: 559fbd0f03cc34c7

---

I'm very excited to announce the ninth and final blog post in the dplyr 1.0.0 series: dplyr 1.0.0 is now available from CRAN!

New features
------------

You can learn about the new features in dplyr 1.0.0 by reading the

-   special thanks to Romain, Davis, Lionel. Mention Jim's work on revdeps
-   highlight main features

<!-- -->

``` r
library(dplyr, warn.conflicts = FALSE)
```

New logo
--------

dplyr has a new logo thanks to the talented [Allison Horst](https://allisonhorst.github.io)!

<img src="dplyr.png" width="250" alt="New dplyr logo" /> 

(Stay tuned for details about how to get this sticker on to your laptop. We have some exciting news coming up!)

A small teaser
--------------

The best way to find out all the cool new features dplyr has to offer is to read through the blog posts linked to above. But thanks to inspiration from [Daniel Anderson](https://twitter.com/datalorax_/status/1258208502960422914) here are bunch of cool features in one single example:

``` r
by_species <- iris %>% nest_by(Species)

models <- tibble::tribble(
  ~model_name,    ~ formula,
  "length-width", Sepal.Length ~ Petal.Width + Petal.Length,
  "interaction",  Sepal.Length ~ Petal.Width * Petal.Length
)

by_species %>% 
  left_join(models, by = character()) %>% 
  rowwise(Species, model_name) %>% 
  mutate(model = list(lm(formula, data = data))) %>% 
  summarise(broom::glance(model))
#> `summarise()` regrouping output by 'Species', 'model_name' (override with `.groups` argument)
#> # A tibble: 6 x 13
#> # Groups:   Species, model_name [6]
#>   Species model_name r.squared adj.r.squared sigma statistic  p.value    df
#>   <fct>   <chr>          <dbl>         <dbl> <dbl>     <dbl>    <dbl> <int>
#> 1 setosa  length-wi…     0.112        0.0739 0.339      2.96 6.18e- 2     3
#> 2 setosa  interacti…     0.133        0.0760 0.339      2.34 8.54e- 2     4
#> 3 versic… length-wi…     0.574        0.556  0.344     31.7  1.92e- 9     3
#> 4 versic… interacti…     0.577        0.549  0.347     20.9  1.11e- 8     4
#> 5 virgin… length-wi…     0.747        0.736  0.327     69.3  9.50e-15     3
#> 6 virgin… interacti…     0.757        0.741  0.323     47.8  3.54e-14     4
#> # … with 5 more variables: logLik <dbl>, AIC <dbl>, BIC <dbl>, deviance <dbl>,
#> #   df.residual <int>
```

Note the use of:

-   `nest_by()` to generate a nested data frame where each row contains all the data for a single group.

-   `by = character()` to perform a Cartesian product of two data frames, generating every possible combination. Here, this generates every combination of subgroup and model.

-   `rowwise()` and `mutate()` to fit a model to each row.

-   The newly powerful `summarise()` to summarise each model with the model fit statistics computed by `broom::glance()`.

Acknowledgements
----------------

A big thanks to all 137 members of the dplyr community who helped make this release possible by finding bugs, discussing issues, and writing code! [@AdaemmerP](https://github.com/AdaemmerP), [@adelarue](https://github.com/adelarue), [@ahernnelson](https://github.com/ahernnelson), [@alaataleb111](https://github.com/alaataleb111), [@antoine-sachet](https://github.com/antoine-sachet), [@atusy](https://github.com/atusy), [@Auld-Greg](https://github.com/Auld-Greg), [@b-rodrigues](https://github.com/b-rodrigues), [@batpigandme](https://github.com/batpigandme), [@bedantaguru](https://github.com/bedantaguru), [@benjaminschlegel](https://github.com/benjaminschlegel), [@benjbuch](https://github.com/benjbuch), [@bergsmat](https://github.com/bergsmat), [@billdenney](https://github.com/billdenney), [@brianmsm](https://github.com/brianmsm), [@bwiernik](https://github.com/bwiernik), [@caldwellst](https://github.com/caldwellst), [@cat-zeppelin](https://github.com/cat-zeppelin), [@chillywings](https://github.com/chillywings), [@clauswilke](https://github.com/clauswilke), [@colearendt](https://github.com/colearendt), [@DanChaltiel](https://github.com/DanChaltiel), [@danoreper](https://github.com/danoreper), [@danzafar](https://github.com/danzafar), [@davidbaniadam](https://github.com/davidbaniadam), [@DavisVaughan](https://github.com/DavisVaughan), [@dblodgett-usgs](https://github.com/dblodgett-usgs), [@ddsjoberg](https://github.com/ddsjoberg), [@deschen1](https://github.com/deschen1), [@dfrankow](https://github.com/dfrankow), [@DiegoKoz](https://github.com/DiegoKoz), [@dkahle](https://github.com/dkahle), [@DzimitryM](https://github.com/DzimitryM), [@earowang](https://github.com/earowang), [@echasnovski](https://github.com/echasnovski), [@edwindj](https://github.com/edwindj), [@elbersb](https://github.com/elbersb), [@elcega](https://github.com/elcega), [@ericemc3](https://github.com/ericemc3), [@espinielli](https://github.com/espinielli), [@FedericoConcas](https://github.com/FedericoConcas), [@FlukeAndFeather](https://github.com/FlukeAndFeather), [@GegznaV](https://github.com/GegznaV), [@gergness](https://github.com/gergness), [@ggrothendieck](https://github.com/ggrothendieck), [@glennmschultz](https://github.com/glennmschultz), [@gowerc](https://github.com/gowerc), [@greg-minshall](https://github.com/greg-minshall), [@gregorp](https://github.com/gregorp), [@ha0ye](https://github.com/ha0ye), [@hadley](https://github.com/hadley), [@Harrison4192](https://github.com/Harrison4192), [@henry090](https://github.com/henry090), [@hughjonesd](https://github.com/hughjonesd), [@ianmcook](https://github.com/ianmcook), [@ismailmuller](https://github.com/ismailmuller), [@isteves](https://github.com/isteves), [@its-gazza](https://github.com/its-gazza), [@j450h1](https://github.com/j450h1), [@Jagadeeshkb](https://github.com/Jagadeeshkb), [@jarauh](https://github.com/jarauh), [@jason-liu-cs](https://github.com/jason-liu-cs), [@jayqi](https://github.com/jayqi), [@JBGruber](https://github.com/JBGruber), [@jemus42](https://github.com/jemus42), [@jennybc](https://github.com/jennybc), [@jflournoy](https://github.com/jflournoy), [@jhuntergit](https://github.com/jhuntergit), [@JohannesNE](https://github.com/JohannesNE), [@jzadra](https://github.com/jzadra), [@karldw](https://github.com/karldw), [@kassambara](https://github.com/kassambara), [@klin333](https://github.com/klin333), [@knausb](https://github.com/knausb), [@kriemo](https://github.com/kriemo), [@krispiepage](https://github.com/krispiepage), [@krlmlr](https://github.com/krlmlr), [@kvasilopoulos](https://github.com/kvasilopoulos), [@larry77](https://github.com/larry77), [@leonawicz](https://github.com/leonawicz), [@lionel-](https://github.com/lionel-), [@lorenzwalthert](https://github.com/lorenzwalthert), [@LudvigOlsen](https://github.com/LudvigOlsen), [@madlogos](https://github.com/madlogos), [@markdly](https://github.com/markdly), [@markfairbanks](https://github.com/markfairbanks), [@meghapsimatrix](https://github.com/meghapsimatrix), [@meixiaba](https://github.com/meixiaba), [@melissagwolf](https://github.com/melissagwolf), [@mgirlich](https://github.com/mgirlich), [@Michael-Sheppard](https://github.com/Michael-Sheppard), [@mikmart](https://github.com/mikmart), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mir-cat](https://github.com/mir-cat), [@mjsmith037](https://github.com/mjsmith037), [@mlane3](https://github.com/mlane3), [@msberends](https://github.com/msberends), [@msgoussi](https://github.com/msgoussi), [@nefissakhd](https://github.com/nefissakhd), [@nick-youngblut](https://github.com/nick-youngblut), [@nzbart](https://github.com/nzbart), [@pavel-shliaha](https://github.com/pavel-shliaha), [@pdbailey0](https://github.com/pdbailey0), [@pnacht](https://github.com/pnacht), [@ponnet](https://github.com/ponnet), [@r2evans](https://github.com/r2evans), [@ramnathv](https://github.com/ramnathv), [@randy3k](https://github.com/randy3k), [@richardjtelford](https://github.com/richardjtelford), [@romainfrancois](https://github.com/romainfrancois), [@rorynolan](https://github.com/rorynolan), [@ryanvoyack](https://github.com/ryanvoyack), [@selesnow](https://github.com/selesnow), [@selin1st](https://github.com/selin1st), [@sewouter](https://github.com/sewouter), [@sfirke](https://github.com/sfirke), [@SimonDedman](https://github.com/SimonDedman), [@sjmgarnier](https://github.com/sjmgarnier), [@smingerson](https://github.com/smingerson), [@stefanocoretta](https://github.com/stefanocoretta), [@strengejacke](https://github.com/strengejacke), [@tfkillian](https://github.com/tfkillian), [@tilltnet](https://github.com/tilltnet), [@tonyvibe](https://github.com/tonyvibe), [@topepo](https://github.com/topepo), [@torockel](https://github.com/torockel), [@trinker](https://github.com/trinker), [@tungmilan](https://github.com/tungmilan), [@tzakharko](https://github.com/tzakharko), [@uasolo](https://github.com/uasolo), [@werkstattcodes](https://github.com/werkstattcodes), [@wlandau](https://github.com/wlandau), [@xiaoa6435](https://github.com/xiaoa6435), [@yiluheihei](https://github.com/yiluheihei), [@yutannihilation](https://github.com/yutannihilation), [@zenggyu](https://github.com/zenggyu), and [@zkamvar](https://github.com/zkamvar).
