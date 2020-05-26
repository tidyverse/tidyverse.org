---
title: ggplot2 3.0.0
author: Mara Averick
date: '2018-07-05'
slug: ggplot2-3-0-0
description: > 
  ggplot2 3.0.0 is on CRAN.
categories:
  - package
tags:
  - ggplot2
  - tidyverse
photo:
  url: https://unsplash.com/photos/wEL2zPX3jDg
  author: Fabio Ballasina
---



We're extremely pleased to announce the release of [ggplot2](https://ggplot2.tidyverse.org/) 3.0.0. This is a major release: it was previously announced as ggplot2 2.3.0, but we decided to increment the version number because there are some big changes under the hood. Most importantly ggplot2 now supports tidy evaluation, which makes it easier to programmatically build plots with ggplot2 in the same way you can programmatically build data manipulation pipelines with dplyr.

Install ggplot2 with:


```r
install.packages("ggplot2")
```

## Breaking changes

In stable, long-standing packages like ggplot2, we put in a lot of effort to make sure that we don't introduce backward incompatible changes. For this release, that involved testing on five versions of R (3.1 - 3.5) writing a new visual testing package ([vdiffr](https://github.com/lionel-/vdiffr)), running R CMD check on downstream packages (over [6,000 times!](https://www.tidyverse.org/articles/2018/05/ggplot2-2-3-0/#our-process)), and [widely advertising](https://www.tidyverse.org/articles/2018/05/ggplot2-2-3-0/) the release to get the community's help. However, sometimes we do decide that it's worth breaking a small amount of existing code in the interests of improving future code. 

The changes should affect relatively little user code, but have required developers to make changes. A separate post will address developer-facing changes in further detail, however, common errors and ways to work around them can be found 
in the [Breaking changes](https://github.com/tidyverse/ggplot2/blob/master/NEWS.md#breaking-changes) section of ggplot2's [NEWS](https://github.com/tidyverse/ggplot2/blob/master/NEWS.md). If you discover something missing, please let us know so we can add it. 

## Tidy evaluation

You can now use [quasiquotation](https://adv-r.hadley.nz/quasiquotation.html) in `aes()`, `facet_wrap()`, and `facet_grid()`. 
To support quasiquotation in facetting we've added a new helper that works 
similarly to `aes()`: `vars()`, short for variables, so instead of 
`facet_grid(x + y ~ a + b)` you can now write `facet_grid(vars(x, y), vars(a, b))`. 
The formula interface won't go away; but the new `vars()` interface is 
much easier to program with.


```r
x_var <- quo(wt)
y_var <- quo(mpg)
group_var <- quo(cyl)

ggplot(mtcars, aes(!!x_var, !!y_var)) + 
  geom_point() + 
  facet_wrap(vars(!!group_var))
```

<img src="/articles/2018-07-ggplot2-3-0-0_files/figure-html/label-both-1.png" width="700px" style="display: block; margin: auto;" />

## New features

We only touch on a few of the new features in ggplot2 — there are many many more. For a full account of these improvements, please see [NEWS](https://github.com/tidyverse/ggplot2/blob/master/NEWS.md). If there's a feature you particularly like, and you write a blog post about, please share it with us using [this form](https://goo.gl/forms/elGvrlIXgTZVtCap1), and we'll include in a round up post in a month's time.

### sf

Thanks to the help of [Edzer Pebesma](https://github.com/edzer) and the [r-spatial](https://github.com/r-spatial) team, ggplot2 now has full support for simple features through 
[sf](https://r-spatial.github.io/sf/) using `geom_sf()` and `coord_sf()`; it now 
automatically aligns CRS across layers, sets up the correct aspect ratio, and 
draws a graticule.


```r
nc <- sf::st_read(system.file("shape/nc.shp", package = "sf"))
#> Reading layer `nc' from data source `/Users/hadley/R/sf/shape/nc.shp' using driver `ESRI Shapefile'
#> Simple feature collection with 100 features and 14 fields
#> geometry type:  MULTIPOLYGON
#> dimension:      XY
#> bbox:           xmin: -84.32385 ymin: 33.88199 xmax: -75.45698 ymax: 36.58965
#> epsg (SRID):    4267
#> proj4string:    +proj=longlat +datum=NAD27 +no_defs
ggplot(nc) +
  geom_sf() +
  annotate("point", x = -80, y = 35, colour = "red", size = 4)
```

<img src="/articles/2018-07-ggplot2-3-0-0_files/figure-html/sf-1.png" width="700px" style="display: block; margin: auto;" />

### Calculated aesthetics

The new `stat()` function offers a cleaner, and better-documented syntax for 
calculated-aesthetic variables. This replaces the older approach of surrounding 
the variable name with `..`. Instead of using `aes(y = ..count..)`, you can use 
`aes(y = stat(count))`. 

This is particularly nice for more complex calculations, as `stat()` only needs 
to be specified once; e.g. `aes(y = stat(count / max(count)))` rather than 
`aes(y = ..count.. / max(..count..))`.

### Tag

In addition to title, subtitle, and caption, a new tag label has been added, for identifying plots. Add a tag with `labs(tag = "A")`, style it with the `plot.tag` theme element, and control position with the `plot.tag.position` theme.


```r
ggplot(mtcars) +
  geom_point(aes(disp, mpg)) + 
  labs(tag = 'A', title = 'Title of this plot')
```

<img src="/articles/2018-07-ggplot2-3-0-0_files/figure-html/tag-1.png" width="700px" style="display: block; margin: auto;" />

### Layers: geoms, stats, and position adjustments

The new [`position_dodge2()`](https://ggplot2.tidyverse.org/reference/position_dodge.html) allows you to arrange the horizontal position of plots with variable widths (i.e. bars and rectangles, in addition to box plots). By default, `position_dodge2()` preserves the width of each element. You can choose to preserve the total width by setting the `preserve` argument to `"total"`. Thank you to [Kara Woo](https://github.com/karawoo) for all of her work on this.


```r
ggplot(mtcars, aes(factor(cyl), fill = factor(vs))) +
  geom_bar(position = position_dodge2(preserve = "single"))

ggplot(mtcars, aes(factor(cyl), fill = factor(vs))) +
  geom_bar(position = position_dodge2(preserve = "total"))
```

<img src="/articles/2018-07-ggplot2-3-0-0_files/figure-html/dodge-st-1.png" width="50%" /><img src="/articles/2018-07-ggplot2-3-0-0_files/figure-html/dodge-st-2.png" width="50%" />

### Scales and guides

Several new functions have been added to make it easy to use Viridis colour 
scales: `scale_colour_viridis_c()` and `scale_fill_viridis_c()` for continuous, 
and `scale_colour_viridis_d()` and `scale_fill_viridis_d()` for discrete. 
Viridis is also now used as the default colour and fill scale for ordered 
factors.


```r
dsamp <- diamonds[sample(nrow(diamonds), 1000), ]
d <- ggplot(dsamp, aes(carat, price)) +
  geom_point(aes(colour = clarity))
d + scale_colour_viridis_d()
```

<img src="/articles/2018-07-ggplot2-3-0-0_files/figure-html/viridis-1.png" width="700px" style="display: block; margin: auto;" />

`scale_colour_continuous()` and `scale_colour_gradient()` are now controlled  by global options `ggplot2.continuous.colour` and `ggplot2.continuous.fill`. You can set them to `"viridis"` to use the viridis colour scale by default:


```r
options(
  ggplot2.continuous.colour = "viridis",
  ggplot2.continuous.fill = "viridis"
)
```


```r
v <- ggplot(faithfuld) +
  geom_tile(aes(waiting, eruptions, fill = density))
v + scale_fill_continuous()
```

<img src="/articles/2018-07-ggplot2-3-0-0_files/figure-html/viridis-c-1.png" width="700px" style="display: block; margin: auto;" />

`guide_colorbar()` is more configurable: tick marks and color bar frame can now by styled with arguments `ticks.colour`, `ticks.linewidth`, `frame.colour`, `frame.linewidth`, and `frame.linetype`.


```r
p <- ggplot(mtcars, aes(wt, mpg))

p + geom_point(aes(colour = cyl)) +
  scale_colour_gradient(
    low = "white", high = "red",
    guide = guide_colorbar(
      frame.colour = "black",
      ticks.colour = "black"
    )
  )
```

<img src="/articles/2018-07-ggplot2-3-0-0_files/figure-html/guide-colorbar-1.png" width="700px" style="display: block; margin: auto;" />

### Nonstandard aesthetics

Thanks to [Claus Wilke](https://github.com/tidyverse/ggplot2/pull/2555), there is significantly improved support for nonstandard aesthetics.

Aesthetics can now be specified independent of the scale name.


```r
ggplot(iris, aes(x = Sepal.Length, fill = Species)) +
  geom_density(alpha = 0.7) +
  scale_colour_brewer(type = "qual", aesthetics = "fill")
```

<img src="/articles/2018-07-ggplot2-3-0-0_files/figure-html/nsa-independent-scale-1.png" width="700px" style="display: block; margin: auto;" />

## Acknowledgements

This release includes a change to the ggplot2 authors, which now includes Claus Wilke (new), and Lionel Henry, Kara Woo, Thomas Lin Pedersen, and Kohske Takahashi in recognition of their past contributions. 

We're grateful to the *391* people who contributed issues, code and comments: [@achalaacharya](https://github.com/achalaacharya), [@adambajguz](https://github.com/adambajguz), [@AdeelH](https://github.com/AdeelH), [@adrfantini](https://github.com/adrfantini), [@aelwan](https://github.com/aelwan), [@aetiologicCanada](https://github.com/aetiologicCanada), [@ajay-d](https://github.com/ajay-d), [@alberthkcheng](https://github.com/alberthkcheng), [@alchenist](https://github.com/alchenist), [@alexconingham](https://github.com/alexconingham), [@alexgenin](https://github.com/alexgenin), [@alistaire47](https://github.com/alistaire47), [@andbarker](https://github.com/andbarker), [@andrewdolman](https://github.com/andrewdolman), [@andrewjpfeiffer](https://github.com/andrewjpfeiffer), [@andzandz11](https://github.com/andzandz11), [@aornugent](https://github.com/aornugent), [@aosmith16](https://github.com/aosmith16), [@aphalo](https://github.com/aphalo), [@arthur-st](https://github.com/arthur-st), [@aschersleben](https://github.com/aschersleben), [@awgymer](https://github.com/awgymer), [@Ax3man](https://github.com/Ax3man), [@baderstine](https://github.com/baderstine), [@baffelli](https://github.com/baffelli), [@baptiste](https://github.com/baptiste), [@BarkleyBG](https://github.com/BarkleyBG), [@basille](https://github.com/basille), [@batpigandme](https://github.com/batpigandme), [@batuff](https://github.com/batuff), [@bbolker](https://github.com/bbolker), [@bbrewington](https://github.com/bbrewington), [@beansprout88](https://github.com/beansprout88), [@behrman](https://github.com/behrman), [@ben519](https://github.com/ben519), [@benediktclaus](https://github.com/benediktclaus), [@berkorbay](https://github.com/berkorbay), [@bfgray3](https://github.com/bfgray3), [@bhaskarvk](https://github.com/bhaskarvk), [@billdenney](https://github.com/billdenney), [@bjreisman](https://github.com/bjreisman), [@boshek](https://github.com/boshek), [@botanize](https://github.com/botanize), [@botaspablo](https://github.com/botaspablo), [@bouch-ra](https://github.com/bouch-ra), [@brianwdavis](https://github.com/brianwdavis), [@briencj](https://github.com/briencj), [@brodieG](https://github.com/brodieG), [@bsaul](https://github.com/bsaul), [@bschneidr](https://github.com/bschneidr), [@burchill](https://github.com/burchill), [@buyske](https://github.com/buyske), [@byapparov](https://github.com/byapparov), [@caijun](https://github.com/caijun), [@cankutcubuk](https://github.com/cankutcubuk), [@CharlesCara](https://github.com/CharlesCara), [@Chavelior](https://github.com/Chavelior), [@christianhomberg](https://github.com/christianhomberg), [@cinkova](https://github.com/cinkova), [@ckuenne](https://github.com/ckuenne), [@clauswilke](https://github.com/clauswilke), [@cooknl](https://github.com/cooknl), [@corytu](https://github.com/corytu), [@cpsievert](https://github.com/cpsievert), [@cregouby](https://github.com/cregouby), [@crsh](https://github.com/crsh), [@cryanking](https://github.com/cryanking), [@cseveren](https://github.com/cseveren), [@daattali](https://github.com/daattali), [@danfulop](https://github.com/danfulop), [@daniel-barnett](https://github.com/daniel-barnett), [@dantonnoriega](https://github.com/dantonnoriega), [@DarioBoh](https://github.com/DarioBoh), [@DarioS](https://github.com/DarioS), [@darrkj](https://github.com/darrkj), [@DarwinAwardWinner](https://github.com/DarwinAwardWinner), [@DasHammett](https://github.com/DasHammett), [@datalorax](https://github.com/datalorax), [@davharris](https://github.com/davharris), [@DavidNash1](https://github.com/DavidNash1), [@DavyLandman](https://github.com/DavyLandman), [@dbo99](https://github.com/dbo99), [@ddiez](https://github.com/ddiez), [@delferts](https://github.com/delferts), [@Demetrio92](https://github.com/Demetrio92), [@DesiQuintans](https://github.com/DesiQuintans), [@dietrichson](https://github.com/dietrichson), [@Dilini-Sewwandi-Rajapaksha](https://github.com/Dilini-Sewwandi-Rajapaksha), [@dipenpatel235](https://github.com/dipenpatel235), [@diplodata](https://github.com/diplodata), [@dirkschumacher](https://github.com/dirkschumacher), [@djrajdev](https://github.com/djrajdev), [@dl7631](https://github.com/dl7631), [@dmenne](https://github.com/dmenne), [@DocOfi](https://github.com/DocOfi), [@domiden](https://github.com/domiden), [@dongzhuoer](https://github.com/dongzhuoer), [@dpastoor](https://github.com/dpastoor), [@dpmcsuss](https://github.com/dpmcsuss), [@dpprdan](https://github.com/dpprdan), [@dpseidel](https://github.com/dpseidel), [@DSLituiev](https://github.com/DSLituiev), [@dvcv](https://github.com/dvcv), [@dylan-stark](https://github.com/dylan-stark), [@eamoncaddigan](https://github.com/eamoncaddigan), [@econandrew](https://github.com/econandrew), [@edgararuiz](https://github.com/edgararuiz), [@edmundesterbauer](https://github.com/edmundesterbauer), [@EdwinTh](https://github.com/EdwinTh), [@edzer](https://github.com/edzer), [@eeenilsson](https://github.com/eeenilsson), [@ekatko1](https://github.com/ekatko1), [@elbamos](https://github.com/elbamos), [@elina800](https://github.com/elina800), [@elinw](https://github.com/elinw), [@eliocamp](https://github.com/eliocamp), [@Emaasit](https://github.com/Emaasit), [@emilelatour](https://github.com/emilelatour), [@Enchufa2](https://github.com/Enchufa2), [@erocoar](https://github.com/erocoar), [@espinielli](https://github.com/espinielli), [@everydayduffy](https://github.com/everydayduffy), [@ewallace](https://github.com/ewallace), [@FabianRoger](https://github.com/FabianRoger), [@FelixMailoa](https://github.com/FelixMailoa), [@FlordeAzahar](https://github.com/FlordeAzahar), [@flying-sheep](https://github.com/flying-sheep), [@fmassicano](https://github.com/fmassicano), [@foldager](https://github.com/foldager), [@foo-bar-baz-qux](https://github.com/foo-bar-baz-qux), [@francoisturcot](https://github.com/francoisturcot), [@Freguglia](https://github.com/Freguglia), [@frostell](https://github.com/frostell), [@gfiumara](https://github.com/gfiumara), [@GG786](https://github.com/GG786), [@ggrothendieck](https://github.com/ggrothendieck), [@ghost](https://github.com/ghost), [@gilleschapron](https://github.com/gilleschapron), [@GillesSanMartin](https://github.com/GillesSanMartin), [@gjabel](https://github.com/gjabel), [@glennstone](https://github.com/glennstone), [@gmbecker](https://github.com/gmbecker), [@GoodluckH](https://github.com/GoodluckH), [@gordocabron](https://github.com/gordocabron), [@goyalmunish](https://github.com/goyalmunish), [@grantmcdermott](https://github.com/grantmcdermott), [@GreenStat](https://github.com/GreenStat), [@gregmacfarlane](https://github.com/gregmacfarlane), [@gregrs-uk](https://github.com/gregrs-uk), [@GuangchuangYu](https://github.com/GuangchuangYu), [@gwarnes-mdsol](https://github.com/gwarnes-mdsol), [@ha0ye](https://github.com/ha0ye), [@hadley](https://github.com/hadley), [@hannes101](https://github.com/hannes101), [@hansvancalster](https://github.com/hansvancalster), [@hardeepsjohar](https://github.com/hardeepsjohar), [@has2k1](https://github.com/has2k1), [@heckendorfc](https://github.com/heckendorfc), [@hedjour](https://github.com/hedjour), [@Henrik-P](https://github.com/Henrik-P), [@henrikmidtiby](https://github.com/henrikmidtiby), [@hrabel](https://github.com/hrabel), [@hrbrmstr](https://github.com/hrbrmstr), [@huangl07](https://github.com/huangl07), [@HughParsonage](https://github.com/HughParsonage), [@ibiris](https://github.com/ibiris), [@idavydov](https://github.com/idavydov), [@idemockle](https://github.com/idemockle), [@igordot](https://github.com/igordot), [@Ilia-Kosenkov](https://github.com/Ilia-Kosenkov), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@irudnyts](https://github.com/irudnyts), [@izahn](https://github.com/izahn), [@jan-glx](https://github.com/jan-glx), [@janvanoeveren](https://github.com/janvanoeveren), [@jarrod-dalton](https://github.com/jarrod-dalton), [@jcrada](https://github.com/jcrada), [@jdagilliland](https://github.com/jdagilliland), [@jemus42](https://github.com/jemus42), [@jenitivecase](https://github.com/jenitivecase), [@jennybc](https://github.com/jennybc), [@jentjr](https://github.com/jentjr), [@jflycn](https://github.com/jflycn), [@jgoad](https://github.com/jgoad), [@jimdholland](https://github.com/jimdholland), [@jimhester](https://github.com/jimhester), [@jnaber](https://github.com/jnaber), [@jnolis](https://github.com/jnolis), [@joacorapela](https://github.com/joacorapela), [@joergtrojan](https://github.com/joergtrojan), [@JoFAM](https://github.com/JoFAM), [@johngoldin](https://github.com/johngoldin), [@JohnMount](https://github.com/JohnMount), [@jonocarroll](https://github.com/jonocarroll), [@joojala](https://github.com/joojala), [@jorgher](https://github.com/jorgher), [@josephuses](https://github.com/josephuses), [@joshkehn](https://github.com/joshkehn), [@jpilorget](https://github.com/jpilorget), [@jrnold](https://github.com/jrnold), [@jrvianna](https://github.com/jrvianna), [@jsams](https://github.com/jsams), [@jsta](https://github.com/jsta), [@JTapper](https://github.com/JTapper), [@juliasilge](https://github.com/juliasilge), [@jvcasillas](https://github.com/jvcasillas), [@jwdink](https://github.com/jwdink), [@jwhendy](https://github.com/jwhendy), [@JWilb](https://github.com/JWilb), [@jzadra](https://github.com/jzadra), [@kamilsi](https://github.com/kamilsi), [@karawoo](https://github.com/karawoo), [@karldw](https://github.com/karldw), [@katrinleinweber](https://github.com/katrinleinweber), [@kaybenleroll](https://github.com/kaybenleroll), [@kenbeek](https://github.com/kenbeek), [@kent37](https://github.com/kent37), [@kevinushey](https://github.com/kevinushey), [@kimchpekr](https://github.com/kimchpekr), [@klmr](https://github.com/klmr), [@kmace](https://github.com/kmace), [@krlmlr](https://github.com/krlmlr), [@kylebmetrum](https://github.com/kylebmetrum), [@landesbergn](https://github.com/landesbergn), [@laurareads](https://github.com/laurareads), [@ldecicco-USGS](https://github.com/ldecicco-USGS), [@Leoloh](https://github.com/Leoloh), [@likanzhan](https://github.com/likanzhan), [@lindeloev](https://github.com/lindeloev), [@lionel-](https://github.com/lionel-), [@liuwell](https://github.com/liuwell), [@llrs](https://github.com/llrs), [@LSanselme](https://github.com/LSanselme), [@luisDVA](https://github.com/luisDVA), [@luwei0917](https://github.com/luwei0917), [@MagicForrest](https://github.com/MagicForrest), [@malcolmbarrett](https://github.com/malcolmbarrett), [@mallerhand](https://github.com/mallerhand), [@ManuelNeumann](https://github.com/ManuelNeumann), [@manuelreif](https://github.com/manuelreif), [@MarauderPixie](https://github.com/MarauderPixie), [@mariellep](https://github.com/mariellep), [@Maschette](https://github.com/Maschette), [@mattwilliamson13](https://github.com/mattwilliamson13), [@mbergins](https://github.com/mbergins), [@mcol](https://github.com/mcol), [@mdsumner](https://github.com/mdsumner), [@melohr](https://github.com/melohr), [@mentalplex](https://github.com/mentalplex), [@mfoos](https://github.com/mfoos), [@mgacc0](https://github.com/mgacc0), [@mgruebsch](https://github.com/mgruebsch), [@MichaelChirico](https://github.com/MichaelChirico), [@MichaelRatajczak](https://github.com/MichaelRatajczak), [@mikgh](https://github.com/mikgh), [@mikmart](https://github.com/mikmart), [@MilesMcBain](https://github.com/MilesMcBain), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mitchelloharawild](https://github.com/mitchelloharawild), [@mjbock](https://github.com/mjbock), [@mkoohafkan](https://github.com/mkoohafkan), [@mkuhn](https://github.com/mkuhn), [@monikav](https://github.com/monikav), [@mpancia](https://github.com/mpancia), [@mrtns](https://github.com/mrtns), [@mruessler](https://github.com/mruessler), [@mundl](https://github.com/mundl), [@mvkorpel](https://github.com/mvkorpel), [@mwaldstein](https://github.com/mwaldstein), [@ndphillips](https://github.com/ndphillips), [@Nekochef](https://github.com/Nekochef), [@nhamilton1980](https://github.com/nhamilton1980), [@nicksolomon](https://github.com/nicksolomon), [@nipunbatra](https://github.com/nipunbatra), [@noamross](https://github.com/noamross), [@Nowosad](https://github.com/Nowosad), [@nteetor](https://github.com/nteetor), [@nzxwang](https://github.com/nzxwang), [@oneilsh](https://github.com/oneilsh), [@ozgen92](https://github.com/ozgen92), [@patr1ckm](https://github.com/patr1ckm), [@pbreheny](https://github.com/pbreheny), [@pelotom](https://github.com/pelotom), [@petersorensen](https://github.com/petersorensen), [@philstraforelli](https://github.com/philstraforelli), [@pkq](https://github.com/pkq), [@pnolain](https://github.com/pnolain), [@Pomido](https://github.com/Pomido), [@powestermark](https://github.com/powestermark), [@pscheid92](https://github.com/pscheid92), [@pschloss](https://github.com/pschloss), [@ptoche](https://github.com/ptoche), [@qinzhu](https://github.com/qinzhu), [@QuentinRoy](https://github.com/QuentinRoy), [@R180](https://github.com/R180), [@ractingmatrix](https://github.com/ractingmatrix), [@RafaRafa](https://github.com/RafaRafa), [@randomgambit](https://github.com/randomgambit), [@raubreywhite](https://github.com/raubreywhite), [@RawanRadi](https://github.com/RawanRadi), [@ray-p144](https://github.com/ray-p144), [@RegalPlatypus](https://github.com/RegalPlatypus), [@Rekyt](https://github.com/Rekyt), [@RemmyGuo](https://github.com/RemmyGuo), [@ReneMalenfant](https://github.com/ReneMalenfant), [@renozao](https://github.com/renozao), [@restonslacker](https://github.com/restonslacker), [@rlionheart92](https://github.com/rlionheart92), [@rmatev](https://github.com/rmatev), [@rmatkins](https://github.com/rmatkins), [@rmheiberger](https://github.com/rmheiberger), [@RMHogervorst](https://github.com/RMHogervorst), [@Robinlovelace](https://github.com/Robinlovelace), [@RoelVerbelen](https://github.com/RoelVerbelen), [@rohan-shah](https://github.com/rohan-shah), [@rpruim](https://github.com/rpruim), [@ruaridhw](https://github.com/ruaridhw), [@Ryo-N7](https://github.com/Ryo-N7), [@sabinfos](https://github.com/sabinfos), [@sachinbanugariya](https://github.com/sachinbanugariya), [@sahirbhatnagar](https://github.com/sahirbhatnagar), [@salauer](https://github.com/salauer), [@sathishsrinivasank](https://github.com/sathishsrinivasank), [@saudiwin](https://github.com/saudiwin), [@schloerke](https://github.com/schloerke), [@seancaodo](https://github.com/seancaodo), [@setempler](https://github.com/setempler), [@sfirke](https://github.com/sfirke), [@sgoodm8](https://github.com/sgoodm8), [@shippy](https://github.com/shippy), [@skanskan](https://github.com/skanskan), [@slowkow](https://github.com/slowkow), [@smouksassi](https://github.com/smouksassi), [@SomeUser999](https://github.com/SomeUser999), [@space-echo](https://github.com/space-echo), [@statkclee](https://github.com/statkclee), [@statsandthings](https://github.com/statsandthings), [@statsccpr](https://github.com/statsccpr), [@sTeamTraen](https://github.com/sTeamTraen), [@stefanedwards](https://github.com/stefanedwards), [@stephankraut](https://github.com/stephankraut), [@SteveMillard](https://github.com/SteveMillard), [@stla](https://github.com/stla), [@svannoy](https://github.com/svannoy), [@swimmingsand](https://github.com/swimmingsand), [@taraskaduk](https://github.com/taraskaduk), [@tbradley1013](https://github.com/tbradley1013), [@tdhock](https://github.com/tdhock), [@Thieffen](https://github.com/Thieffen), [@ThierryO](https://github.com/ThierryO), [@thjwong](https://github.com/thjwong), [@thk686](https://github.com/thk686), [@thomashauner](https://github.com/thomashauner), [@thomaskvalnes](https://github.com/thomaskvalnes), [@thomasp85](https://github.com/thomasp85), [@thvasilo](https://github.com/thvasilo), [@tiernanmartin](https://github.com/tiernanmartin), [@timgoodman](https://github.com/timgoodman), [@timothyslau](https://github.com/timothyslau), [@tingtingben](https://github.com/tingtingben), [@tjmahr](https://github.com/tjmahr), [@toouggy](https://github.com/toouggy), [@topepo](https://github.com/topepo), [@traversc](https://github.com/traversc), [@truemoid](https://github.com/truemoid), [@tungmilan](https://github.com/tungmilan), [@Tutuchan](https://github.com/Tutuchan), [@tzoltak](https://github.com/tzoltak), [@ulo](https://github.com/ulo), [@UweBlock](https://github.com/UweBlock), [@vadimus202](https://github.com/vadimus202), [@VectorPosse](https://github.com/VectorPosse), [@VikrantDogra](https://github.com/VikrantDogra), [@vnijs](https://github.com/vnijs), [@wch](https://github.com/wch), [@wdsteck](https://github.com/wdsteck), [@WHMan](https://github.com/WHMan), [@wibeasley](https://github.com/wibeasley), [@wkristan](https://github.com/wkristan), [@woodwards](https://github.com/woodwards), [@wpetry](https://github.com/wpetry), [@wxlu718](https://github.com/wxlu718), [@xhdong-umd](https://github.com/xhdong-umd), [@yeedle](https://github.com/yeedle), [@yonicd](https://github.com/yonicd), [@yutannihilation](https://github.com/yutannihilation), [@zeehio](https://github.com/zeehio), [@zhenglei-gao](https://github.com/zhenglei-gao), [@zlskidmore](https://github.com/zlskidmore), [@ZoidbergIII](https://github.com/ZoidbergIII), and [@zz77zz](https://github.com/zz77zz).
