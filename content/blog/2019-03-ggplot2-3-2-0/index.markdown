---
title: 'ggplot2 3.2.0'
author: Thomas Lin Pedersen
date: '2019-06-16'
slug: ggplot2-3-2-0
description: >
  ggplot2 3.2.0 is now on CRAN!
categories:
  - package
tags:
  - ggplot2
  - tidyverse
photo:
  url: https://unsplash.com/photos/eH_ftJYhaTY
  author: chuttersnap
---



We're thrilled to announce the release of [ggplot2 3.2.0](https://ggplot2.tidyverse.org) on CRAN. ggplot2 is a system for declaratively creating graphics, based on The Grammar of Graphics. You provide the data, tell ggplot2 how to map variables to aesthetics, what graphical primitives to use, and it takes care of the details.

The 3.2.0 release is a minor release which focuses on performance improvements, but also includes a few new features and a range of bug fixes. There are no breaking changes in this release, though a few changes may affect the visual appearance of plots in minor ways, noted below. Further, there are a few changes that developers of extension packages may need to take into account, but which won't affect regular users. For a full overview of the changes, please see the [release notes](https://ggplot2.tidyverse.org/news/index.html).

This release also includes a range of contributions made during our tidyverse developer day in Austin, many from first-time contributors. We hope these contributors have been inspired to continue taking part in the development of ggplot2.

Lastly, this release also sees the entrance of Hiroaki Yutani (*yutannihilation* on both [Github](https://github.com/yutannihilation) and [Twitter](https://twitter.com/yutannihilat_en)) into the core developer team. Hiroaki has been amazing in tackling large and small issues, and we are very lucky to have him.

## Performance
A large part of this release relates to internal changes intended to speed up ggplot2. Most of these are general and will affect the rendering speed of all the plots you make, but there has also been a specific focus on [`geom_sf()`](https://ggplot2.tidyverse.org/reference/ggsf.html). This is all part of a larger effort to make plotting in R more performant, and also includes changes in [gtable](https://gtable.r-lib.org), [sf](http://r-spatial.github.io/sf/), and R itself. Make sure to use the latest version of all of these packages to get the full benefit of the improvements.

### geom_sf
While most changes are general, `geom_sf()` has received special attention. Most of this comes down to how `geom_sf()` converted its input to grobs, which was done row by row. This meant that plotting 10,000 `ST_POINT` objects would create 10,000 point grobs instead of a single grob containing 10,000 points. The same was true for all other data types. With the new release, ggplot2 will try to pack all objects into a single grob, which is possible when all objects are of the same type (`MULTI*` types can be mixed with scalar types). Packing polygons into a single grob is only possible with R 3.6.0 and upwards, but all other types are backwards compatible with older versions of R. If the data contains a mix of types, ggplot2 will fall back to creating a grob for each row, but this is a much less frequent situation, and can usually be remedied by creating multiple sf layers instead. The other big performance bottleneck in plotting sf data was the normalization of the coordinates. As sf stores its data in nested lists, the standard vectorization in R doesn't apply, which led to much worse performance compared to normalizing data stored in standard data frame format. The latest release of sf includes optimized functions for these operations implemented in C which ggplot2 now uses, so plotting performance has improved immensely.

## New features
With this release, ggplot2 gains the ability to plot polygons with holes (only in R 3.6 and later). Rather than providing a new geom, the functionality is built into [`geom_polygon()`](https://ggplot2.tidyverse.org/reference/geom_polygon.html) through a new `subgroup` aesthetic. Much as the `group` aesthetic separates polygons in the data, the `subgroup` aesthetic separates parts of each polygon. The first occurring subgroup should always be the outer ring of the polygon and any subsequent subgroup will describe holes in this (or, potentially, polygons within the holes and so on). There will not be any checks performed on the position of the subgroups, so it is the responsibility of the user to make sure they are inside the outer ring.


```r
library(ggplot2)
library(tibble)
radians <- seq(0, 2 * pi, length.out = 101)[-1]
circle <- tibble(
  x = c(cos(radians), cos(radians) * 0.5),
  y = c(sin(radians), sin(radians) * 0.5),
  subgroup = rep(c(1, 2), each = 100)
)
ggplot(circle) +
  geom_polygon(
    aes(x = x, y = y, subgroup = subgroup),
    fill = "firebrick",
    colour = "black"
  )
```

<img src="/articles/2019-03-ggplot2-3-2-0_files/figure-html/unnamed-chunk-1-1.png" width="700px" style="display: block; margin: auto;" />

The other bigger new feature is the ability to modify the guide representation
of a layer through a new `key_glyph` argument in all geoms. While the defaults
are often fine, there are situations where a different look serves the
visualisation:


```r
ggplot(economics, aes(date, psavert, color = "savings rate")) +
  geom_line(key_glyph = "timeseries")
```

<img src="/articles/2019-03-ggplot2-3-2-0_files/figure-html/unnamed-chunk-2-1.png" width="700px" style="display: block; margin: auto;" />

`geom_rug` has seen a range of improvements to give users more control over the appearance of the rug lines. The length of the rug lines can now be controlled and it is further possible to specify that they should be placed outside of the plotting region:


```r
ggplot(mtcars, aes(x = wt, y = mpg)) +
  geom_point() +
  geom_rug(sides = "tr", length = unit(1, "mm"), outside = TRUE) +
  # Need to turn clipping off if rug is outside plot area
  coord_cartesian(clip = "off")
```

<img src="/articles/2019-03-ggplot2-3-2-0_files/figure-html/unnamed-chunk-3-1.png" width="700px" style="display: block; margin: auto;" />

Aesthetics will now accept a function returning `NULL`, and treat it as setting the aesthetic to `NULL`. This can make it easier to program with ggplot2 e.g. by catching errors from non-existing variables:


```r
df <- data.frame(x = 1:10, y = 1:10)
wrap <- function(...) tryCatch(..., error = function(e) NULL)

ggplot(df, aes(x, y, colour = wrap(no_such_column))) +
  geom_point()
```

<img src="/articles/2019-03-ggplot2-3-2-0_files/figure-html/unnamed-chunk-4-1.png" width="700px" style="display: block; margin: auto;" />

Lastly, [`stat_function()`](https://ggplot2.tidyverse.org/reference/stat_function.html) gains the ability to accept purrr-style lambda functions. The use of the formula notation for creating lambda functions has become widespread, and it is only natural that ggplot2 accepts it as well:


```r
df <- data.frame(x = 1:10, y = (1:10)^2)
ggplot(df, aes(x, y)) +
  geom_point() +
  stat_function(fun = ~ .x^2)
```

<img src="/articles/2019-03-ggplot2-3-2-0_files/figure-html/unnamed-chunk-5-1.png" width="700px" style="display: block; margin: auto;" />

## Minor fixes and improvements
[`coord_sf`](https://ggplot2.tidyverse.org/reference/ggsf.html) now behaves the same as the other coords in relation to how it draws grid lines. This means that the aesthetics of the grid matches that of the other coordinate systems, and that it can be turned off through the theming system. You may see slight visual changes when using `geom_sf()` as the default grid lines were slightly thicker in `coord_sf()` prior to this change.


```r
library(sf)
#> Linking to GEOS 3.6.1, GDAL 2.1.3, PROJ 4.9.3

nc <- st_read(system.file("gpkg/nc.gpkg", package = "sf"), quiet = TRUE)

ggplot(nc) +
  geom_sf(data = nc, aes(fill = AREA)) +
  theme_void()
```

<img src="/articles/2019-03-ggplot2-3-2-0_files/figure-html/unnamed-chunk-6-1.png" width="700px" style="display: block; margin: auto;" />

The automatic naming of scales has been refined and no longer contains back-ticks when the scale name is based on a complex aesthetic expression (e.g. `aes(x = a + b)`). Again, this may result in slight changes to the visual appearance of plots, but only on a very superficial level.

## Acknowledgements

Thank you to the 171 people who who contributed issues, code and comments to this release:
[&#x0040;abl0719](https://github.com/abl0719), [&#x0040;agila5](https://github.com/agila5), [&#x0040;ahmohamed](https://github.com/ahmohamed), [&#x0040;amysheep](https://github.com/amysheep), [&#x0040;andhamel](https://github.com/andhamel), [&#x0040;anthonytw](https://github.com/anthonytw), [&#x0040;Atomizer15](https://github.com/Atomizer15), [&#x0040;atusy](https://github.com/atusy), [&#x0040;baderstine](https://github.com/baderstine), [&#x0040;bakaburg1](https://github.com/bakaburg1), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;bdschwartzkopf](https://github.com/bdschwartzkopf), [&#x0040;beckymaust](https://github.com/beckymaust), [&#x0040;behrman](https://github.com/behrman), [&#x0040;bfgray3](https://github.com/bfgray3), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;Bisaloo](https://github.com/Bisaloo), [&#x0040;bjreisman](https://github.com/bjreisman), [&#x0040;blueskypie](https://github.com/blueskypie), [&#x0040;brfitzpatrick](https://github.com/brfitzpatrick), [&#x0040;brianwdavis](https://github.com/brianwdavis), [&#x0040;brodieG](https://github.com/brodieG), [&#x0040;caayala](https://github.com/caayala), [&#x0040;cderv](https://github.com/cderv), [&#x0040;chambox](https://github.com/chambox), [&#x0040;clairemcwhite](https://github.com/clairemcwhite), [&#x0040;clauswilke](https://github.com/clauswilke), [&#x0040;codetrainee](https://github.com/codetrainee), [&#x0040;ColinFay](https://github.com/ColinFay), [&#x0040;connorlewis](https://github.com/connorlewis), [&#x0040;coolbutuseless](https://github.com/coolbutuseless), [&#x0040;courtiol](https://github.com/courtiol), [&#x0040;cschwarz-stat-sfu-ca](https://github.com/cschwarz-stat-sfu-ca), [&#x0040;cystein](https://github.com/cystein), [&#x0040;dan-booth](https://github.com/dan-booth), [&#x0040;daniel-wells](https://github.com/daniel-wells), [&#x0040;DanielReedOcean](https://github.com/DanielReedOcean), [&#x0040;danielsjf](https://github.com/danielsjf), [&#x0040;daranzolin](https://github.com/daranzolin), [&#x0040;dariyasydykova](https://github.com/dariyasydykova), [&#x0040;dempseynoel](https://github.com/dempseynoel), [&#x0040;dipterix](https://github.com/dipterix), [&#x0040;dirkschumacher](https://github.com/dirkschumacher), [&#x0040;dkahle](https://github.com/dkahle), [&#x0040;dominicroye](https://github.com/dominicroye), [&#x0040;dongzhuoer](https://github.com/dongzhuoer), [&#x0040;dpseidel](https://github.com/dpseidel), [&#x0040;dvcv](https://github.com/dvcv), [&#x0040;efehandanisman](https://github.com/efehandanisman), [&#x0040;Eisit](https://github.com/Eisit), [&#x0040;Eli-Berkow](https://github.com/Eli-Berkow), [&#x0040;eliocamp](https://github.com/eliocamp), [&#x0040;ellessenne](https://github.com/ellessenne), [&#x0040;eoppe1022](https://github.com/eoppe1022), [&#x0040;felipegerard](https://github.com/felipegerard), [&#x0040;fereshtehizadi](https://github.com/fereshtehizadi), [&#x0040;flying-sheep](https://github.com/flying-sheep), [&#x0040;fmmattioni](https://github.com/fmmattioni), [&#x0040;foehnwind](https://github.com/foehnwind), [&#x0040;fostvedt](https://github.com/fostvedt), [&#x0040;gagnagaman](https://github.com/gagnagaman), [&#x0040;gangstertiny](https://github.com/gangstertiny), [&#x0040;GBuchanon](https://github.com/GBuchanon), [&#x0040;gdkrmr](https://github.com/gdkrmr), [&#x0040;gdmcdonald](https://github.com/gdmcdonald), [&#x0040;ghost](https://github.com/ghost), [&#x0040;gibran-ali](https://github.com/gibran-ali), [&#x0040;hadley](https://github.com/hadley), [&#x0040;HaoLi111](https://github.com/HaoLi111), [&#x0040;has2k1](https://github.com/has2k1), [&#x0040;heavywatal](https://github.com/heavywatal), [&#x0040;Henrik-P](https://github.com/Henrik-P), [&#x0040;HenrikBengtsson](https://github.com/HenrikBengtsson), [&#x0040;hlendway](https://github.com/hlendway), [&#x0040;hoasxyz](https://github.com/hoasxyz), [&#x0040;hwt](https://github.com/hwt), [&#x0040;hyiltiz](https://github.com/hyiltiz), [&#x0040;idavydov](https://github.com/idavydov), [&#x0040;Ilia-Kosenkov](https://github.com/Ilia-Kosenkov), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;ismayc](https://github.com/ismayc), [&#x0040;JamesCuster](https://github.com/JamesCuster), [&#x0040;jarauh](https://github.com/jarauh), [&#x0040;JayVii](https://github.com/JayVii), [&#x0040;jmarshallnz](https://github.com/jmarshallnz), [&#x0040;JohnMount](https://github.com/JohnMount), [&#x0040;jonoyuan](https://github.com/jonoyuan), [&#x0040;jprice80](https://github.com/jprice80), [&#x0040;jpritikin](https://github.com/jpritikin), [&#x0040;jrnold](https://github.com/jrnold), [&#x0040;jsekamane](https://github.com/jsekamane), [&#x0040;jtelleria](https://github.com/jtelleria), [&#x0040;jugularvein](https://github.com/jugularvein), [&#x0040;karawoo](https://github.com/karawoo), [&#x0040;Katiedaisey](https://github.com/Katiedaisey), [&#x0040;katossky](https://github.com/katossky), [&#x0040;kdarras](https://github.com/kdarras), [&#x0040;kendonB](https://github.com/kendonB), [&#x0040;kilterwind](https://github.com/kilterwind), [&#x0040;LDalby](https://github.com/LDalby), [&#x0040;linzi-sg](https://github.com/linzi-sg), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;llendway](https://github.com/llendway), [&#x0040;llrs](https://github.com/llrs), [&#x0040;lpantano](https://github.com/lpantano), [&#x0040;LuffyLuffy](https://github.com/LuffyLuffy), [&#x0040;lwjohnst86](https://github.com/lwjohnst86), [&#x0040;lz1nwm](https://github.com/lz1nwm), [&#x0040;m-macaskill](https://github.com/m-macaskill), [&#x0040;malcolmbarrett](https://github.com/malcolmbarrett), [&#x0040;martin-ueding](https://github.com/martin-ueding), [&#x0040;matthewParksViome](https://github.com/matthewParksViome), [&#x0040;maxheld83](https://github.com/maxheld83), [&#x0040;MaximOtt](https://github.com/MaximOtt), [&#x0040;mbertolacci](https://github.com/mbertolacci), [&#x0040;mcguinlu](https://github.com/mcguinlu), [&#x0040;MCM-Math](https://github.com/MCM-Math), [&#x0040;miguelmorin](https://github.com/miguelmorin), [&#x0040;mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [&#x0040;mitchelloharawild](https://github.com/mitchelloharawild), [&#x0040;mluerig](https://github.com/mluerig), [&#x0040;moodymudskipper](https://github.com/moodymudskipper), [&#x0040;njtierney](https://github.com/njtierney), [&#x0040;noahmotion](https://github.com/noahmotion), [&#x0040;npjc](https://github.com/npjc), [&#x0040;oranwutang](https://github.com/oranwutang), [&#x0040;osorensen](https://github.com/osorensen), [&#x0040;pachamaltese](https://github.com/pachamaltese), [&#x0040;paleolimbot](https://github.com/paleolimbot), [&#x0040;PaulLantos](https://github.com/PaulLantos), [&#x0040;peterhurford](https://github.com/peterhurford), [&#x0040;phmarek](https://github.com/phmarek), [&#x0040;powerbilayeredmap](https://github.com/powerbilayeredmap), [&#x0040;ppanko](https://github.com/ppanko), [&#x0040;ptoche](https://github.com/ptoche), [&#x0040;puhachov](https://github.com/puhachov), [&#x0040;rajkstats](https://github.com/rajkstats), [&#x0040;richierocks](https://github.com/richierocks), [&#x0040;sabahzero](https://github.com/sabahzero), [&#x0040;sahilseth](https://github.com/sahilseth), [&#x0040;SavasAli](https://github.com/SavasAli), [&#x0040;sctyner](https://github.com/sctyner), [&#x0040;sebneus](https://github.com/sebneus), [&#x0040;shauyin520](https://github.com/shauyin520), [&#x0040;sjackman](https://github.com/sjackman), [&#x0040;skanskan](https://github.com/skanskan), [&#x0040;slowkow](https://github.com/slowkow), [&#x0040;smouksassi](https://github.com/smouksassi), [&#x0040;sn248](https://github.com/sn248), [&#x0040;sowla](https://github.com/sowla), [&#x0040;sschloss1](https://github.com/sschloss1), [&#x0040;StefanBRas](https://github.com/StefanBRas), [&#x0040;steffilazerte](https://github.com/steffilazerte), [&#x0040;tcastrosantos](https://github.com/tcastrosantos), [&#x0040;thomasp85](https://github.com/thomasp85), [&#x0040;topepo](https://github.com/topepo), [&#x0040;Torvaney](https://github.com/Torvaney), [&#x0040;touala](https://github.com/touala), [&#x0040;tungmilan](https://github.com/tungmilan), [&#x0040;vanzanden](https://github.com/vanzanden), [&#x0040;vbuchhold](https://github.com/vbuchhold), [&#x0040;W-L](https://github.com/W-L), [&#x0040;wongjingping](https://github.com/wongjingping), [&#x0040;wrightaprilm](https://github.com/wrightaprilm), [&#x0040;x1o](https://github.com/x1o), [&#x0040;yosukefk](https://github.com/yosukefk), [&#x0040;yudong862](https://github.com/yudong862), [&#x0040;yutannihilation](https://github.com/yutannihilation), [&#x0040;zeehio](https://github.com/zeehio), [&#x0040;zlskidmore](https://github.com/zlskidmore), and [&#x0040;zuccaval](https://github.com/zuccaval).
