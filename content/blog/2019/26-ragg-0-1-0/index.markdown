---
title: ragg 0.1.0
author: Thomas Lin Pedersen
date: '2019-07-15'
slug: ragg-0-1-0
description: >
    A set of new graphic devices just landed on CRAN. Read more about the ragg package here.
categories:
  - package
tags:
  - r-lib
  - ragg
photo:
  url: https://unsplash.com/photos/sBkK2VWV8Kw
  author: Gordon Williams
---



We're stoked to announce the release of [ragg 0.1.0](https://ragg.r-lib.org) on CRAN. ragg provides a set of high quality and high performance raster devices, capable of producing png, tiff, or ppm files, or a matrix of raw color values directly within R.

ragg is part of our broader effort to improve graphics performance and quality in R at all levels of the stack, so that you'll benefit no matter what plotting framework you choose to use. Other parts of this efforts have been:

- Developing the [devoid](https://github.com/r-lib/devoid) package to allow more precise benchmarking of plotting code.
- Multiple improvements to rendering speed in grid in the latest R release (3.6.0).
- Performance improvements in [ggplot2](https://ggplot2.tidyverse.org) 3.2.0 both broadly and for sf plotting specifically.
- Performance improvements in [gtable](https://gtable.r-lib.com) 0.3.0.

## The devices
An R graphic device is an object that receives instructions from the graphic engine in R and translates that into some meaningful format for viewing. The graphic engine in R is the layer that sits between the graphic generating code in R and the devices, and is responsible for allowing the plethora of different output options from the same plot code. The output from a graphic device can either be a file, on screen, or in some other form. ragg provides a set of raster devices, that is, devices that rasterize the instructions and write it to some sort of raster output (e.g. a png file). This is opposed to vector devices such as `pdf()` and `svg()` that do not perform rasterization but write the instructions directly into a vector graphics format.

ragg provides three different file outputs (png, tiff, and ppm), though it is important to note that everything, except for the serialization of the data into the file format, is equivalent. A case could be made for also including jpeg output, but this format is generally not useful for graphics as it introduces noticeable artifacts with line graphics.

Apart from the three file-based devices, ragg also provides a device that gives direct access to the raster buffer from R. This means that you can plot directly into a matrix of color values which you can then further process in R, should you wish.

## Features
There are 5 main areas where ragg sets itself apart from the graphic devices already available:

- **Performance:** ragg is faster than cairo, the standard anti-aliased device in R. Tests show that it is about twice as fast to render a moderately complex ggplot. See the
[Performance](https://ragg.r-lib.org/articles/ragg_performance.html) vignette for more in-depth benchmarking.
- **Anti-aliasing:** ragg is fully anti-aliased, as opposed to the cairo devices that only apply anti-aliasing to strokes and text (not fill). For a comparison, see the [shape rendering](https://ragg.r-lib.org/articles/ragg_quality.html#shape-rendering) section of the Quality vignette.
- **Text rendering:** ragg provides high-quality rendering of rotated text, something that other raster devices struggle with. See the [text](https://ragg.r-lib.org/articles/ragg_quality.html#text) section of the Quality vignette for examples.
- **Font access:** ragg has direct access to all your system fonts, without you having to do anything. All installed fonts on your system should be ready to use.
- **System independence:** The rendering code in ragg is system independent and should be identical whether it has been rendered on Windows, macOS, or Linux. The only difference is the available fonts on the different systems.

## Example
The ragg devices are used just like any other device, by starting them, running your plotting code, and turning them off (code below add some complexity in order to embed the created file in the page):


```r
library(ragg)
library(ggplot2)

file <- knitr::fig_path('.png')

agg_png(file, width = 700, height = 500, units = 'px')
ggplot(diamonds) + 
  geom_bar(aes(color, fill = color)) + 
  ggtitle("A fancy font") + 
  theme(text = element_text(family = "Daubmark", size = 50))
invisible(dev.off())

knitr::include_graphics(file)
```

<img src="/articles/2019-06-26-ragg-0-1-0_files/figure-html/unnamed-chunk-1-1.png" width="700px" style="display: block; margin: auto;" />

ragg can also be used with `ggsave()` by passing the device in as an argument:


```r
file <- knitr::fig_path('.png')
p <- ggplot(mpg, aes(displ, hwy)) + 
  geom_point()

ggsave(file, p, device = agg_png, res = 300)
#> Saving 7 x 4.33 in image

knitr::include_graphics(file)
```

<img src="/articles/2019-06-26-ragg-0-1-0_files/figure-html/unnamed-chunk-2-1.png" width="700px" style="display: block; margin: auto;" />

## Life cycle
ragg is currently to be considered [experimental](https://www.tidyverse.org/lifecycle/#experimental). That is not to indicate that any API changes are to be expected, or that using it is not a safe long-term strategy. But we are continuing to invest and improve upon the graphic stack in R, and we cannot say whether ragg will be part of our final solution, or if it is just an interesting experiment. The experience gained in the graphic stack from building ragg will definitely be put to good use though, and you can expect more improvements in the future.

## Acknowledgements
Thanks to [&#x0040;jeroen](https://github.com/jeroen) for much assistance in getting ragg to compile on all systems!
