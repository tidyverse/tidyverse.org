---
output: hugodown::hugo_document

slug: fonts-in-r
title: Fonts in R
date: 2025-05-07
author: Thomas Lin Pedersen
description: >
    Taking control of fonts and text rendering in R can be challenging. This
    deep-dive teaches you everything (and then some) you need to know to keep
    your sanity

photo:
  url: https://unsplash.com/photos/flat-lay-photography-of-stamp-lot-p8gzCnZf39k
  author: Kristian Strand

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [deep-dive]
tags: [systemfonts, textshaping, ragg, svglite, graphics]
---

```{=html}
<style type='text/css'>
pre {
  text-wrap: nowrap;
  overflow-x: scroll;
}
</style>
```

```{=html}
<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with `hugodown::tidy_show_meta()`)
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] `hugodown::use_tidy_thumbnails()`
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] `usethis::use_tidy_thanks()`
-->
```



The purpose of this document is to give you the a thorough overview of fonts as it relates to their use in R. However, for this to be possible, it is first necessary to get an understanding of fonts and how they work in digital publishing in general. If you have a thorough understanding of digital typography you may skip to [the next section](#font-handling-in-r).

## Digital typography

Many books can be, and have been, written about the subject of typography. This is not meant to be an exhaustive deep dive into all areas of this vast subject. Rather, it is meant to give you just enough understanding of core concepts and terminology to appreciate how it all plays into using fonts in R.

### Typeface or font?

There is a good chance that you, like 99% of world, use *"font"* as the term describing "the look" of the letters you type. You may, perhaps, have heard the term *"typeface"* as well and thought it synonymous. This is in fact slightly wrong, and a great deal of typography snobbery has been dealt out on that account. It is a rather inconsequential mix-up for the most part, especially because 99% of the population wouldn't bat an eye if you use them interchangeably. However, the distinction between the two serves as a good starting point to talk about other terms in digital typography as well as the nature of font files, so let's dive in.

When most people use the word "font" or "font family", what they are actually describing is a typeface. A **typeface** is a style of lettering that forms a cohesive whole. As an example, consider the well-known "Helvetica" typeface. This name embraces many different weights (bold, normal, light) as well as slanted (italic) and upright. However, all of these variations are all as much Helvetica as the others - they are all part of the same typeface.

If a typeface is font, then what is a font? A **font** is a subset of a typeface, describing a particular variation of the typeface, i.e. the combination of typeface, weight, width, and slant that comes together to describe the specific subset of a typeface that is used. We typically give a specific combination of a name, like "bold" or "medium" or "italic", which we call the **font style**. In other words, the typeface plus a font style gives you a font. Be aware that the style name is at the discretion of the developer of the typeface. It is very common to see discrepancies between the style name and e.g. the weight reported by the font (e.g. Avenir Next Ultra Light is in reality a *thin* weight font).

![Different fonts from the Avenir Next typeface](figure/unnamed-chunk-2-1.png)

In the rest of this document we will use the terms typeface and font with the meaning described above.

### Font files

Next, we need to talk about how typefaces are represented for use by computers. Font files record information on how to draw the individual glyphs (characters), but also instructions about how to draw sequences of glyphs like distance adjustments (kerning) and substitution rules (ligatures). Font files typically encode a single font but can encode a full typeface:


``` r
typefaces <- systemfonts::system_fonts()

# Full typeface in one file
typefaces[typefaces$family == "Helvetica", c("path", "index", "family", "style")]
#> # A tibble: 6 × 4
#>   path                                index family    style        
#>   <chr>                               <int> <chr>     <chr>        
#> 1 /System/Library/Fonts/Helvetica.ttc     2 Helvetica Oblique      
#> 2 /System/Library/Fonts/Helvetica.ttc     4 Helvetica Light        
#> 3 /System/Library/Fonts/Helvetica.ttc     5 Helvetica Light Oblique
#> 4 /System/Library/Fonts/Helvetica.ttc     1 Helvetica Bold         
#> 5 /System/Library/Fonts/Helvetica.ttc     3 Helvetica Bold Oblique 
#> 6 /System/Library/Fonts/Helvetica.ttc     0 Helvetica Regular

# One font per font file
typefaces[typefaces$family == "Arial", c("path", "index", "family", "style")]
#> # A tibble: 4 × 4
#>   path                                                     index family style      
#>   <chr>                                                    <int> <chr>  <chr>      
#> 1 /System/Library/Fonts/Supplemental/Arial.ttf                 0 Arial  Regular    
#> 2 /System/Library/Fonts/Supplemental/Arial Bold.ttf            0 Arial  Bold       
#> 3 /System/Library/Fonts/Supplemental/Arial Bold Italic.ttf     0 Arial  Bold Italic
#> 4 /System/Library/Fonts/Supplemental/Arial Italic.ttf          0 Arial  Italic
```

Here, **family** gives the name of the typeface, and **style** the name of the font within that typeface.

It took a considerable number of tries before the world managed to nail the digitial representation of fonts, leading to a proliferation of file types. As an R user, there are three formats that are particularly improtant:

-   **TrueType** (ttf/ttc). Truetype is the baseline format that all modern formats stand on top of. It was developed by Apple in the '80s and became popular due to its great balance between size and quality. Fonts can be encoded, either as scalable paths, or as bitmaps of various sizes, the former generally being preferred as it allows for seamless scaling and small file size at the same time.

-   \*\* OpenType\*\* (otf/otc). OpenType was created by Microsoft and Adobe to improve upon TrueType. While TrueType was a great success, it the number of glyphs it could contain was limited and as was its support for selecting different features during [shaping](#text-shaping). OpenType resolved these issues, so if you want access to advanced typography features you'll need a font in OpenType format.

-   \*\* Web Open Font Format\*\* (woff/woff2). TrueType and OpenType tend to create large files. Since a large percentage of the text consumed today is delivered over the internet this creates a problem. WOFF resolves this problem by acting as a compression wrapper around TrueType/OpenType to reduce file sizes while also limiting the number of advanced features provided to those relevant to web fonts. The woff2 format is basically identical to woff except it uses the more efficient [brotli](https://en.wikipedia.org/wiki/Brotli) compression algorithm. WOFF was designed specifically to be delivered over the internet and support is still a bit limited outside of browsers.

While we have mainly talked about font files as containers for the shape of glyphs, they also carries a lot of other information needed for rendering text in a way pleasant for reading. Font level information recordsd a lot of stylistic information about typeface/font, statistics on the number of glyphs and how many different mappings between character encodings and glyphs it contains, and overall sizing information such as the maximum descend of the font, the position of an underline relative to the baseline etc. systemfonts provdies a convenient way to access this data from R:


``` r
dplyr::glimpse(systemfonts::font_info(family = "Helvetica"))
#> Rows: 1
#> Columns: 24
#> $ path               <chr> "/System/Library/Fonts/Helvetica.ttc"
#> $ index              <int> 0
#> $ family             <chr> "Helvetica"
#> $ style              <chr> "Regular"
#> $ italic             <lgl> FALSE
#> $ bold               <lgl> FALSE
#> $ monospace          <lgl> FALSE
#> $ weight             <ord> normal
#> $ width              <ord> normal
#> $ kerning            <lgl> FALSE
#> $ color              <lgl> FALSE
#> $ scalable           <lgl> TRUE
#> $ vertical           <lgl> FALSE
#> $ n_glyphs           <int> 2252
#> $ n_sizes            <int> 0
#> $ n_charmaps         <int> 10
#> $ bbox               <list> <-11.406250, 17.343750, -5.765625, 13.453125>
#> $ max_ascend         <dbl> 9.234375
#> $ max_descend        <dbl> -2.765625
#> $ max_advance_width  <dbl> 18
#> $ max_advance_height <dbl> 12
#> $ lineheight         <dbl> 12
#> $ underline_pos      <dbl> -1.203125
#> $ underline_size     <dbl> 0.59375
```

As well as a bunch of information about individual glyphs, Further, for each glyph there is a range of information in addition to its shape:


``` r
systemfonts::glyph_info("j", family = "Helvetica", size = 30)
#> # A tibble: 1 × 9
#>   glyph index width height x_bearing y_bearing x_advance y_advance bbox     
#>   <chr> <int> <dbl>  <dbl>     <dbl>     <dbl>     <dbl>     <dbl> <list>   
#> 1 j        77     6     27        -1        21         7         0 <dbl [4]>
```

These terms are more easily understood with a diagram:

![plot of chunk unnamed-chunk-6](figure/unnamed-chunk-6-1.png)

The `x_advance` in particular is important when rendering text because it tells you how far to move to the right before rendering the next glyph (ignoring for a bit the concept of kerning)

### Text shaping {#text-shaping}

The next important concept to understand is **text shaping**, which, in the simplest of terms, is to convert a succession of characters into sequence of glyphs along with their locations. Important here is the distinction between **characters**, the things you think of as letters, and **glyphs**, which is what the font will draw. For example, think of the character "f", which is often tricky to draw because the "hook" of the f can interfere with other characters. To solve this problem, many typefaces include **ligatures**, like "ﬁ", which are used for specific pairs of characaters. Ligatures are extremely important for languages like Arabic.

Just a few of the challenges of text shaping include kerning, bidirectional text, and font substitution. **Kerning**, which controls the distance between specific pairs of characters. For example, you can put "VM" a little closer together but "OO" needs to be a little further apart. Kerning is an integral part of all modern text rendering and you will almost solemnly notice it when it is absent (or worse, [wrongly applied](https://www.fastcompany.com/91324550/kerning-on-pope-francis-tomb-is-a-travesty)).

Not every language writes text in the same direction, but regardless of your native script, you are likely to use arabic numerals which are always written left-to-right. This gives rise to the challenge of **bidirectional** (or bidi) text, which mixes text flowing in different directions. This imposes a whole new range of challenges!

Finally, you might request a character that a font doesn't contain. One way to deal with this is to render a glyph representing a missing glyph, usually an empty box or a question mark. But it's typically more useful to use the correct glyph from a different font. This is called **font fallback** and happens all the time for emojis, but can also happen when you suddenly change script without bothering to pick a new font. Font fallback is an imprecise science, typically relying on an operating system font that has a very large number of characters, but might look very different from your existing font.

Once you have determined the order and location of glyphs, you are still not done. Text often needs to be wrapped to fit into a specific width, it may need a specific justification, perhaps, indentation or tracking must be applied, etc. Thankfully, all of this is generally a matter of (often gnarly) math that you just have to get right. That is, all except text wrapping which should happen at the right boundaries, and may need to break up a word and inserting a hyphen etc.

Like I said, the pit of despair is bottomless...

## Font handling in R {#font-handling-in-r}

You hopefully arrive at this section with an appreciation of the horrors that goes into rendering text. If not, maybe this [blog post](https://faultlore.com/blah/text-hates-you/) will convince you.

Are you still here? Good.

Now that you understand the basics of what goes into handling fonts and text, we can now discuss the details of fonts in R specifically.

### Fonts and text from a user perspective {#fonts-and-text-from-a-user-perspective}

The users perception of working with fonts in R is largely shaped by plots. This means using either base or grid graphics or one of the packages that have been build on top of it, like [ggplot2](https://ggplot2.tidyverse.org). While the choice of tool will affect *where* you specify the font to use, they generally agree on how to specify it.

+-------------------------------------------------------------------------------------------------------------+--------------+-------------------------------------------------------+---------------------------------------------------------------------------------------------------------------+
| Graphic system                                                                                              | Argument     |                                                       |                                                                                                               |
+=============================================================================================================+==============+=======================================================+===============================================================================================================+
|                                                                                                             | *Typeface*   | *Font*                                                | **Size**                                                                                                      |
+-------------------------------------------------------------------------------------------------------------+--------------+-------------------------------------------------------+---------------------------------------------------------------------------------------------------------------+
| **Base**                                                                                                    | `family`     | `font`                                                | `cra` (pixels) or `cin` (inches) multiplied by `cex`                                                          |
|                                                                                                             |              |                                                       |                                                                                                               |
| *Arguments are passed to `par()` to set globally or directly to the call that renders text (e.g. `text()`)* |              |                                                       |                                                                                                               |
+-------------------------------------------------------------------------------------------------------------+--------------+-------------------------------------------------------+---------------------------------------------------------------------------------------------------------------+
| **Grid**                                                                                                    | `fontfamily` | `fontface`                                            | `fontsize` (points) multiplied by `cex`                                                                       |
|                                                                                                             |              |                                                       |                                                                                                               |
| Arguments are passed to the `gp` argument of relevant grobs using the `gpar()` constructor                  |              |                                                       |                                                                                                               |
+-------------------------------------------------------------------------------------------------------------+--------------+-------------------------------------------------------+---------------------------------------------------------------------------------------------------------------+
| **ggplot2**                                                                                                 | `family`     | `face` (in `element_text()`) or `fontface` (in geoms) | `size` (points when used in `element_text()`, depends on the value of `size.unit` argument when used in geom) |
|                                                                                                             |              |                                                       |                                                                                                               |
| Arguments are set in `element_text()` to alter theme fonts or directly in the geom call to alter geom fonts |              |                                                       |                                                                                                               |
+-------------------------------------------------------------------------------------------------------------+--------------+-------------------------------------------------------+---------------------------------------------------------------------------------------------------------------+

From the table it is clear that in R *fontfamily*/*family* is used to describe the typeface, *font*/*fontface*/*face* is used to select a font from the typeface based on a limited number of styles. Size settings is just a plain mess.

The major limitation in the *fontface* (and friends) setting is that it takes a number, not a string, and you can only select from four options: `1`: plain, `2`: bold, `3`: italic, and `4`: bold-italic. This means, for example, that there's no way to select Futura Condensed Extra Bold. Another limitation is that it's not possible to specify any font variations such as using tabular numbers or stylistic ligatures.

### Fonts and text from a graphics device perspective

In R, a graphics device is the part responsible for doing the rendering you request and put it on your screen or in a file. When you call `png()` or `ragg::agg_png()` you open up a graphics device that will receive all the plotting instructions from R. Both graphics devices will ultimately produce the same file type (PNG), but how they choose to handle and respond to the plotting instructions may differ (greatly). Nowhere is this difference more true than when it comes to text rendering.

After a user has made a call that renders some text, it is funneled through the graphic system (base or grid), handed off to the graphics engine, which ultimately asks the graphics device to render the text. From the perspective of the graphics device it is much the same information that the user provided which are presented to it. The `text()` method of the device are given an array of characters, the typeface, the size in points, and an integer denoting if the style is regular, bold, italic, or bold-italic.

![Flow of font information through the R rendering stack](text_call_flow.svg){fig-alt="A diagram showing the flow of text rendering instructions from ggplot2, grid, the graphics engine, and down to the graphics device. Very little changes in the available information about the font during the flow"}

This means that it is up to the graphics device to find the approprate font file (using the provided typeface and font style) and shape the text with all that that entails. This is a lot of work, which is why text is handled so inconsistently between graphics devices. Issues can range from not being able to find fonts installed on the computer, to not providing font fallback mechanisms, or even handling right-to-left text. It may also be that certain font file formats are not well supported so that e.g. color emojis are not rendered correctly.

There have been a number of efforts to resolve these problems over the years:

-   **extrafont**: Developed by Winston Chang, [extrafont](https://github.com/wch/extrafont) sought to mainly improve the situation for the `pdf()` device which generally only had access to the postscript fonts that comes with R. The package allows the `pdf()` device to get access to TrueType fonts installed on the computer, as well as provide means for embedding the font into the PDF so that it can be opened on systems where the font is not installed. (It also provides the capabilities to to the Windows `png()` device).

-   **sysfonts** and **showtext**. These packages are developed by Yixuan Qiu and provide support for system fonts to all graphics devices, by hijacking the `text()` method of the graphics device to text text as polygons or raster images. This guarantees your plots will look the same on every device, but it doesn't do advanced text shaping, so there's no support for ligatures or font substituion. Additionally, it produces large files with inaccessible text when used to produce pdf and svg outputs.

-   **systemfonts** and **textshaping**. These packages are developed by me to provide a soup-to-nuts solution to text rendering for graphics devices. [systemfonts](https://systemfonts.r-lib.org) provides access to fonts installed on the system along with font fallback mechanisms, registration of non-system fonts, reading of font files etc. [textshaping](https://github.com/r-lib/textshaping) builds on top of systemfonts and provides a fully modern engine for shaping text. The functionality is exposed both at the R level and at the C level, so that graphics devices can directly access to font lookup and shaping.

We will fosus on systemfonts, because it's designed to give R a fully modern text rendering stack. That unfortunately is impossible to do without coordination with the graphics device, which means that to use all these features you need a supported graphics device. There are currently two options:

-   The [ragg](https://ragg.r-lib.org) package provides graphics devices for rendering raster graphics in a variety of formats (PNG, JPEG, TIFF) and uses systemfonts and textshaping extensively.
-   The [svglite](https://svglite.r-lib.org) package likewise provides a graphic device for rendering vector graphics to SVG using systemfonts and textshaping for text.

You might notice there's currently a big hole in this workflow: PDFs. This is something we plan to work on in the future.

## A systemfonts based workflow

With all that said, how do you actually use systemfonts to use custom fonts in your plots? First, you'll need to use ragg or svglite.

### Using ragg

While there is no way to unilaterally make `ragg::agg_png()` everywhere, it's possible to get close:

-   Positron: recent versions automatically use ragg for the plot pane if it's installed.

-   RStudio IDE: set "AGG" as the backend under Global Options \> General \> Graphics.

-   `ggplot2::ggsave()`: ragg will be automatically used for raster output if installed.

-   R Markdown and Quarto: you need to set the `dev` option to `"ragg_png"`. You can either do this with code:

    ```{{r}}
    #| include: false
    knitr::opts_chunk$set(dev = "ragg_png")
    ```

    Or in Quarto, you can set it in the yaml metadata:

    ``` yaml
    ---
    title: "My Document"
    format: html
    knitr:
      opts_chunk:
        dev: "ragg_png"
    ---
    ```

If you want to use a font installed on your computer, you're done!


``` r
grid::grid.text(
  "FUTURA 🎉",
  gp = grid::gpar(fontfamily = "Futura", fontface = 3, fontsize = 30)
)
```

![plot of chunk unnamed-chunk-7](figure/unnamed-chunk-7-1.png)

If the results don't look as you expect, you can use various systemfonts helpers to diagnose the problem:


``` r
systemfonts::match_fonts("Futura", weight = "bold")
#> # A tibble: 1 × 3
#>   path                                          index features  
#>   <chr>                                         <int> <list>    
#> 1 /System/Library/Fonts/Supplemental/Futura.ttc     2 <font_ftr>
systemfonts::font_fallback("🎉", family = "Futura", weight = "bold")
#>                                          path index
#> 1 /System/Library/Fonts/Apple Color Emoji.ttc     0
```

If you want to see all the fonts that are available for use, you can use `systemfonts::system_fonts()`


``` r
systemfonts::system_fonts()
```


```
#> # A tibble: 570 × 9
#>    path                                                   index name  family style weight width italic monospace
#>    <chr>                                                  <int> <chr> <chr>  <chr> <ord>  <ord> <lgl>  <lgl>    
#>  1 /System/Library/Fonts/Supplemental/Rockwell.ttc            2 Rock… Rockw… Bold  bold   norm… FALSE  FALSE    
#>  2 /System/Library/Fonts/Noteworthy.ttc                       0 Note… Notew… Light normal norm… FALSE  FALSE    
#>  3 /System/Library/Fonts/Supplemental/DevanagariMT.ttc        1 Deva… Devan… Bold  bold   norm… FALSE  FALSE    
#>  4 /System/Library/Fonts/Supplemental/Kannada Sangam MN.…     0 Kann… Kanna… Regu… normal norm… FALSE  FALSE    
#>  5 /System/Library/Fonts/Supplemental/Verdana Bold.ttf        0 Verd… Verda… Bold  bold   norm… FALSE  FALSE    
#>  6 /System/Library/Fonts/ArialHB.ttc                          8 Aria… Arial… Light light  norm… FALSE  FALSE    
#>  7 /System/Library/Fonts/AppleSDGothicNeo.ttc                10 Appl… Apple… Thin  thin   norm… FALSE  FALSE    
#>  8 /System/Library/Fonts/Supplemental/DecoTypeNaskh.ttc       0 Deco… DecoT… Regu… normal norm… FALSE  FALSE    
#>  9 /System/Library/Fonts/Supplemental/Trebuchet MS Itali…     0 Treb… Trebu… Ital… normal norm… TRUE   FALSE    
#> 10 /System/Library/Fonts/Supplemental/Khmer MN.ttc            0 Khme… Khmer… Regu… normal norm… FALSE  FALSE    
#> # ℹ 560 more rows
```

### Extra font styles

As we discussed above, the R interface only allows you to select between four styles: plain, italic, bold, and bold-italic. If you want to use a thin font, you have no way of communicating this wish to the device. To overcome this, systemfonts provides `register_variant()` which allows you to register a font with a new typeface name. For example, to use the thin font from the Avenir Next typeface you can register it as follows:


``` r
systemfonts::register_variant(
  name = "Avenir Thin",
  family = "Avenir Next",
  weight = "thin"
)
```

Now you can use Avenir Thin where you would otherwise specify the typeface:


``` r
grid::grid.text(
  "Thin weight is soo classy",
  gp = grid::gpar(fontfamily = "Avenir Thin", fontsize = 30)
)
```

![plot of chunk unnamed-chunk-12](figure/unnamed-chunk-12-1.png)

`register_variant()` also allows you to turn on font features otherwise hidden away:


``` r
systemfonts::register_variant(
  name = "Avenir Small Caps",
  family = "Avenir Next",
  features = systemfonts::font_feature(
    letters = "small_caps"
  )
)
grid::grid.text(
  "All caps — Small caps",
  gp = grid::gpar(fontfamily = "Avenir Small Caps", fontsize = 30)
)
```

![plot of chunk unnamed-chunk-13](figure/unnamed-chunk-13-1.png)

### Fonts from other places

Historically, systemfonts primary role was to access the font installed on your computer, the **system fonts**. But what if you're using a computer where you don't have the rights to install new fonts, or you don't want the hassle of installing a font just to use it for a single plot? That's the problem solved by `systemfonts::add_font()` which makes it easy to use a font based on a path. But in many cases you don't even need that as systemfont now scans `./fonts` and `~/fonts`. This means that you can put personal fonts in a fonts folder in your home directory, and project fonts in a fonts directory at the root of the project. This is a great way to ensure that specific fonts are available when you deploy some code to a server.

And you don't even need to leave R to populate these folders. `systemfonts::get_from_google_fonts()` will download and install a google font in `~/fonts`:


``` r
systemfonts::get_from_google_fonts("Barrio")

grid::grid.text(
  "A new font a day keeps Tufte away",
  gp = grid::gpar(fontfamily = "Barrio", fontsize = 30)
)
```

![plot of chunk unnamed-chunk-14](figure/unnamed-chunk-14-1.png)

And if you want to make sure this code works for anyone using your code (regardless of whether or not they already have the font installed), you can use `systemfonts::require_font()`. If the font isn't already installed, this function download it from one of the repositories it knows about. If it can't find it it will either throw an error (the default) or remap the name to another font so that plotting will still succeed.


``` r
systemfonts::require_font("Rubik Distressed")
#> Trying Google Fonts... Found! Downloading font to /var/folders/l4/tvfrd0ps4dqdr2z7kvnl9xh40000gn/T//RtmpHsMd5i

grid::grid.text(
  "There are no bad fonts\nonly bad text",
  gp = grid::gpar(fontfamily = "Rubik Distressed", fontsize = 30)
)
```

![plot of chunk unnamed-chunk-15](figure/unnamed-chunk-15-1.png)

By default, `require_font()` places new fonts in a temporary folder so it doesn't pollute your carefully curated collection of fonts.

### Font embedding in SVG

Font work a little differently in vector formats like SVG. These formats include the raw text and only render the font when you open the file. This makes for small, accessible files with crisp text at every every level of zoom. But it comes with a price: since the text is rendered when it's opened, it relies on the font in use being available on the viewer's computer. This obviously puts you at the mercy of their font selection, so if you want consistent outputs you'll need to **embed** the font.

In SVG, you can embed fonts using an `@import` statement in the stylesheet, and can point to a web resource so the SVG doesn't need to contain the entire font. systemfonts provides facilities to generate URLs for import statements and can provide them in a variety of formats:


``` r
systemfonts::fonts_as_import("Barrio")
#> [1] "https://fonts.bunny.net/css2?family=Barrio&display=swap"
systemfonts::fonts_as_import("Rubik Distressed", type = "link")
#> [1] "<link rel=\"stylesheet\" href=\"https://fonts.bunny.net/css2?family=Rubik+Distressed&display=swap\"/>"
```

Further, if the font is not available from an online repository, it can embed the font data directly into the URL:


``` r
substr(systemfonts::fonts_as_import("Chalkduster"), 1, 200)
#> [1] "data:text/css,@font-face%20%7B%0A%20%20font-family:%20%22Chalkduster%22;%0A%20%20src:%20url(data:font/ttf;charset=utf-8;base64,AAEAAAAMAIAAAwC4T1MvMmk8+wsAAAFIAAAAYGNtYXBJhgfNAAAEOAAACspnbHlmLDPYGwAAf"
```

svglite uses this feature to allow seamless font embedding with the `web_fonts` argument. It can take a URL as returned by `fonts_as_import()` or just the name of the typeface and the URL will automatically be resolved. Look at line 6 in the SVG generated below


``` r
svg <- svglite::svgstring(web_fonts = "Barrio")
grid::grid.text("Example", gp = grid::gpar(fontfamily = "Barrio"))
invisible(dev.off())
svg()
#> <?xml version='1.0' encoding='UTF-8' ?>
#> <svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' width='720.00pt' height='576.00pt' viewBox='0 0 720.00 576.00'>
#> <g class='svglite'>
#> <defs>
#>   <style type='text/css'><![CDATA[
#>     @import url('https://fonts.bunny.net/css2?family=Barrio&display=swap');
#>     .svglite line, .svglite polyline, .svglite polygon, .svglite path, .svglite rect, .svglite circle {
#>       fill: none;
#>       stroke: #000000;
#>       stroke-linecap: round;
#>       stroke-linejoin: round;
#>       stroke-miterlimit: 10.00;
#>     }
#>     .svglite text {
#>       white-space: pre;
#>     }
#>     .svglite g.glyphgroup path {
#>       fill: inherit;
#>       stroke: none;
#>     }
#>   ]]></style>
#> </defs>
#> <rect width='100%' height='100%' style='stroke: none; fill: #FFFFFF;'/>
#> <defs>
#>   <clipPath id='cpMC4wMHw3MjAuMDB8MC4wMHw1NzYuMDA='>
#>     <rect x='0.00' y='0.00' width='720.00' height='576.00' />
#>   </clipPath>
#> </defs>
#> <g clip-path='url(#cpMC4wMHw3MjAuMDB8MC4wMHw1NzYuMDA=)'>
#> <text x='360.00' y='292.32' text-anchor='middle' style='font-size: 12.00px; font-family: "Barrio";' textLength='48.12px' lengthAdjust='spacingAndGlyphs'>Example</text>
#> </g>
#> </g>
#> </svg>
```

## Want more?

This document has mainly focused on how to use the fonts you desire from within R. R has other limitations when it comes to text rendering specifically how to render text that consists of a mix of fonts. This has been solved by [marquee](https://marquee.r-lib.org) and the curious soul can continue there in order to up their skills in rendering text with R


``` r
grid::grid.draw(
  marquee::marquee_grob(
    "_This_ **is** the {.red end}",
    marquee::classic_style(base_size = 30)
  )
)
```

![plot of chunk unnamed-chunk-19](figure/unnamed-chunk-19-1.png)
