---
title: 'ggplot2 3.1.0'
author: Mara Averick and Claus Wilke
date: '2018-10-29'
slug: ggplot2-3-1-0
description: > 
  ggplot2 3.1.0 is now on CRAN!
categories:
  - package
tags:
  - ggplot2
  - tidyverse
photo:
  url: https://unsplash.com/photos/Ibq4B5iE_-4
  author: Stephan Henning
---



We're happy to announce the release of
[ggplot2 3.1.0](https://ggplot2.tidyverse.org/) on CRAN. ggplot2 is a system for declaratively creating graphics, based on The Grammar of Graphics. You provide the data, tell ggplot2 how to map variables to aesthetics, what graphical primitives to use, and it takes care of the details.

The 3.1.0 release is a minor release that fixes a number of bugs and adds a few new features. Breaking changes have been kept to a minimum and end users of ggplot2 are unlikely to encounter any issues when switching from 3.0.0 to 3.1.0. However, there are a few items that developers of ggplot2 extensions should be aware of. For a complete list of changes and issues of relevance for extension developers, please see the [release notes](https://github.com/tidyverse/ggplot2/releases/tag/v3.1.0).

## New features

`coord_sf()` has much-improved customization of axis tick labels. Labels can now
be set manually, and there are two new parameters, `label_graticule` and
`label_axes`, that can be used to specify which graticules to label on which side
of the plot. In particular, `label_graticule` labels the North, West, East, or South ends of the graticule lines, specified via a simple string argument. For example, `label_graticule = "NE"` will label the North and East ends, which in a standard projection with North pointing up will result in labels on top and to the right.


```r
library(sf)

nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

ggplot() + 
  geom_sf(aes(fill = AREA), data = nc) +
  coord_sf(label_graticule = "NE") +
  scale_y_continuous(
    breaks = c(34, 34.5, 35, 35.5, 36, 36.5),
    labels = parse(text = c("34 * degree * N", "NA", "35 * degree * N", "NA", "36 * degree * N", "NA"))
  )
```

<img src="/articles/2018-10-ggplot2-3-1-0_files/figure-html/coord-sf-1.png" width="672" />

Two new geoms, `geom_sf_label()` and `geom_sf_text()`, can draw labels and text
on sf objects.


```r
ggplot(nc[1:3, ]) +
  geom_sf(aes(fill = AREA)) +
  geom_sf_label(aes(label = NAME))
```

<img src="/articles/2018-10-ggplot2-3-1-0_files/figure-html/geom-sf-text-1.png" width="672" />

Under the hood, a new `stat_sf_coordinates()` calculates the
x and y coordinates from the coordinates of the sf geometries. You can customize
the calculation method via the `fun.geometry` argument.


```r
# default uses st_point_on_surface(), which guarantees the calculated point 
# falls inside each polygon
ggplot(nc) +
  geom_sf() +
  stat_sf_coordinates(geom = "point", color = "red")
```

<img src="/articles/2018-10-ggplot2-3-1-0_files/figure-html/stat_sf_coordinates-1.png" width="672" />

```r

# can use st_centroid() instead to draw centroids
ggplot(nc) +
  geom_sf() +
  stat_sf_coordinates(
    fun.geometry = function(x) st_centroid(st_zm(x)),
    geom = "point", color = "red"
  )
```

<img src="/articles/2018-10-ggplot2-3-1-0_files/figure-html/stat_sf_coordinates-2.png" width="672" />


## Minor fixes and improvements

Aesthetics containing the word "color" are now always standardized internally to read "colour". This happens transparently to the end user, so that the British and American spellings of "colour" / "color" are fully equivalent throughout the entire ggplot2 code base. Therefore, the following four examples all produce the same plot.


```r
p1 <- ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Sepal.Length, fill = Petal.Length)) +
  geom_point(shape = 21, size = 3, stroke = 2) +
  scale_color_viridis_c(
    aesthetics = c("color", "fill"),
    name = "Length", option = "B"
  )

p2 <- ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, colour = Sepal.Length, fill = Petal.Length)) +
  geom_point(shape = 21, size = 3, stroke = 2) +
  scale_colour_viridis_c(
    aesthetics = c("colour", "fill"),
    name = "Length", option = "B"
  )

p3 <- ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, colour = Sepal.Length, fill = Petal.Length)) +
  geom_point(shape = 21, size = 3, stroke = 2) +
  scale_colour_viridis_c(
    aesthetics = c("color", "fill"),
    name = "Length", option = "B"
  )

p4 <- ggplot(iris, aes(x = Sepal.Length, y = Petal.Length, color = Sepal.Length, fill = Petal.Length)) +
  geom_point(shape = 21, size = 3, stroke = 2) +
  scale_color_viridis_c(
    aesthetics = c("colour", "fill"),
    name = "Length", option = "B"
  )

cowplot::plot_grid(p1, p2, p3, p4)
```

<img src="/articles/2018-10-ggplot2-3-1-0_files/figure-html/color-vs-colour-1.png" width="672" />

Normalized statistics are now provided with `stat_bin2d()`, `stat_binhex()`, `stat_density_2d()`, and `stat_contour()` to plot 2d distributions normalized to a common height. This feature can be useful for faceted 2d plots, where the maximum density/count can vary greatly between panels. For example, when using  `stat_density_2d()` with `contour = TRUE`, we can now use the calculated statistic `nlevel` to color by where each contour polygon lies relative to the highest one in that facet.


```r
ggplot(diamonds, aes(x, depth)) +
  stat_density_2d(
    aes(fill = stat(nlevel)),
    geom = "polygon",
    n = 100,
    bins = 10,
    contour = TRUE
  ) +
  facet_wrap(clarity~.) +
  scale_fill_viridis_c(option = "A")
```

<img src="/articles/2018-10-ggplot2-3-1-0_files/figure-html/stat-density-2d-1.png" width="672" />


## Acknowledgements

Thank you to the **126** people who who contributed issues, code and comments to this release:
[&#x0040;abeeCrombie](https://github.com/abeeCrombie), [&#x0040;adam-erickson](https://github.com/adam-erickson), [&#x0040;adrfantini](https://github.com/adrfantini), [&#x0040;Adri1CIRAD](https://github.com/Adri1CIRAD), [&#x0040;agarwal-peeush](https://github.com/agarwal-peeush), [&#x0040;alexhallam](https://github.com/alexhallam), [&#x0040;alireza08](https://github.com/alireza08), [&#x0040;alistaire47](https://github.com/alistaire47), [&#x0040;amhedberg](https://github.com/amhedberg), [&#x0040;amirmasoudabdol](https://github.com/amirmasoudabdol), [&#x0040;andrewheiss](https://github.com/andrewheiss), [&#x0040;andrewmarx](https://github.com/andrewmarx), [&#x0040;anhttdang](https://github.com/anhttdang), [&#x0040;aosmith16](https://github.com/aosmith16), [&#x0040;artidata](https://github.com/artidata), [&#x0040;baderstine](https://github.com/baderstine), [&#x0040;barana912](https://github.com/barana912), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;benjaminhlina](https://github.com/benjaminhlina), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;Bisaloo](https://github.com/Bisaloo), [&#x0040;bjreisman](https://github.com/bjreisman), [&#x0040;bpbraun](https://github.com/bpbraun), [&#x0040;brodieG](https://github.com/brodieG), [&#x0040;bschneidr](https://github.com/bschneidr), [&#x0040;carlislerainey](https://github.com/carlislerainey), [&#x0040;ccpsilva](https://github.com/ccpsilva), [&#x0040;Chrismarsh](https://github.com/Chrismarsh), [&#x0040;chrismp](https://github.com/chrismp), [&#x0040;cipi118](https://github.com/cipi118), [&#x0040;clauswilke](https://github.com/clauswilke), [&#x0040;coolbutuseless](https://github.com/coolbutuseless), [&#x0040;corybrunson](https://github.com/corybrunson), [&#x0040;DarioS](https://github.com/DarioS), [&#x0040;dpseidel](https://github.com/dpseidel), [&#x0040;dracodoc](https://github.com/dracodoc), [&#x0040;drammock](https://github.com/drammock), [&#x0040;earthcli](https://github.com/earthcli), [&#x0040;edmundesterbauer](https://github.com/edmundesterbauer), [&#x0040;elbamos](https://github.com/elbamos), [&#x0040;eliocamp](https://github.com/eliocamp), [&#x0040;Eluvias](https://github.com/Eluvias), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;EmmanuelCharpentier](https://github.com/EmmanuelCharpentier), [&#x0040;emrichter](https://github.com/emrichter), [&#x0040;espher1987](https://github.com/espher1987), [&#x0040;felipegerard](https://github.com/felipegerard), [&#x0040;ftabaro](https://github.com/ftabaro), [&#x0040;gregrs-uk](https://github.com/gregrs-uk), [&#x0040;guillaumecharbonnier](https://github.com/guillaumecharbonnier), [&#x0040;hadley](https://github.com/hadley), [&#x0040;Henrik-P](https://github.com/Henrik-P), [&#x0040;hisakatha](https://github.com/hisakatha), [&#x0040;hzarkoob](https://github.com/hzarkoob), [&#x0040;igordot](https://github.com/igordot), [&#x0040;ilarischeinin](https://github.com/ilarischeinin), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;itcarroll](https://github.com/itcarroll), [&#x0040;Janewyx](https://github.com/Janewyx), [&#x0040;jar1karp](https://github.com/jar1karp), [&#x0040;jdrum00](https://github.com/jdrum00), [&#x0040;JessicaGarzke](https://github.com/JessicaGarzke), [&#x0040;JHonaker](https://github.com/JHonaker), [&#x0040;jiho](https://github.com/jiho), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;JM-RG](https://github.com/JM-RG), [&#x0040;JohnMount](https://github.com/JohnMount), [&#x0040;jonocarroll](https://github.com/jonocarroll), [&#x0040;josesho](https://github.com/josesho), [&#x0040;jpasquier](https://github.com/jpasquier), [&#x0040;jpgoldberg](https://github.com/jpgoldberg), [&#x0040;jtelleria](https://github.com/jtelleria), [&#x0040;justinjunge](https://github.com/justinjunge), [&#x0040;karawoo](https://github.com/karawoo), [&#x0040;kendonB](https://github.com/kendonB), [&#x0040;kimmagnusb](https://github.com/kimmagnusb), [&#x0040;klmr](https://github.com/klmr), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;lawremi](https://github.com/lawremi), [&#x0040;lhunsicker](https://github.com/lhunsicker), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;lorenzwalthert](https://github.com/lorenzwalthert), [&#x0040;mafed](https://github.com/mafed), [&#x0040;makis23](https://github.com/makis23), [&#x0040;malcolmbarrett](https://github.com/malcolmbarrett), [&#x0040;MarioClueless](https://github.com/MarioClueless), [&#x0040;martisak](https://github.com/martisak), [&#x0040;mikesafar](https://github.com/mikesafar), [&#x0040;mikmart](https://github.com/mikmart), [&#x0040;MJochim](https://github.com/MJochim), [&#x0040;mkoohafkan](https://github.com/mkoohafkan), [&#x0040;mojaveazure](https://github.com/mojaveazure), [&#x0040;msberends](https://github.com/msberends), [&#x0040;neoworld77](https://github.com/neoworld77), [&#x0040;PabloRMira](https://github.com/PabloRMira), [&#x0040;paleolimbot](https://github.com/paleolimbot), [&#x0040;pank](https://github.com/pank), [&#x0040;pitakakariki](https://github.com/pitakakariki), [&#x0040;ptoche](https://github.com/ptoche), [&#x0040;rensa](https://github.com/rensa), [&#x0040;rharfoot](https://github.com/rharfoot), [&#x0040;RichardJActon](https://github.com/RichardJActon), [&#x0040;royfrancis](https://github.com/royfrancis), [&#x0040;rpruim](https://github.com/rpruim), [&#x0040;rsaporta](https://github.com/rsaporta), [&#x0040;sambweber](https://github.com/sambweber), [&#x0040;schloerke](https://github.com/schloerke), [&#x0040;slowkow](https://github.com/slowkow), [&#x0040;statsandthings](https://github.com/statsandthings), [&#x0040;stephenbfroehlich](https://github.com/stephenbfroehlich), [&#x0040;steveharoz](https://github.com/steveharoz), [&#x0040;stragu](https://github.com/stragu), [&#x0040;tbobin](https://github.com/tbobin), [&#x0040;the-Hull](https://github.com/the-Hull), [&#x0040;thomasp85](https://github.com/thomasp85), [&#x0040;topepo](https://github.com/topepo), [&#x0040;tstev](https://github.com/tstev), [&#x0040;TylerGrantSmith](https://github.com/TylerGrantSmith), [&#x0040;vikram-rawat](https://github.com/vikram-rawat), [&#x0040;wch](https://github.com/wch), [&#x0040;willgearty](https://github.com/willgearty), [&#x0040;woodwards](https://github.com/woodwards), [&#x0040;YinLiLin](https://github.com/YinLiLin), [&#x0040;yutannihilation](https://github.com/yutannihilation), [&#x0040;yyffang](https://github.com/yyffang), [&#x0040;zeehio](https://github.com/zeehio), and [&#x0040;ZelinC](https://github.com/ZelinC)
