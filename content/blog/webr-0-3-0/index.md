---
output: hugodown::hugo_document

slug: webr-0-3-0
title: webR 0.3.0
date: 2024-03-18
author: George Stagg
description: >
    webR 0.3.0 is now available at npm, GitHub, and via CDN. Take a look at
    what's new in this release.

photo:
  url: https://unsplash.com/photos/purple-and-black-pyramid-wallpaper-k1bO_VTiZSs
  author: Sandro Katalina

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [webr, webassembly, wasm]
rmd_hash: 40b98f7712d538bf

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [x] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
* [ ] Update all 0.3.0-rc.0 references to 0.3.0
-->
<!-- Initialise webR in the page -->
{{< webr-init >}}
<!-- Add webr engine for knit -->

<div class="highlight">

</div>

<!-- Custom styles for output -->

<div class="highlight">

<style type="text/css">
.output > pre, .output code {
  background-color: #ffffff !important;
  margin-top: -17px;
  border-top-left-radius: 0px;
  border-top-right-radius: 0px;
}

.error > pre, .error code {
  background-color: #fcebeb !important;
  color: #410E0E !important;
}
</style>

</div>

We're delighted to announce the release of [webR](https://docs.r-wasm.org/webr/latest/) 0.3.0. This release brings bug fixes, infrastructure upgrades, and exciting improvements to webR's API for creating R objects and evaluating R code from JavaScript. These new features make integrating webR with existing JavaScript frameworks such as [Observable](https://observablehq.com) a breeze.

You can install the latest release from [npm](https://www.npmjs.com/package/webr) with the command:

    npm i webr@0.3.0

or if you're using JavaScript modules to import webR directly from CDN:

``` javascript
import { WebR } from 'https://webr.r-wasm.org/v0.3.0/webr.mjs';
```

A summary of changes is described below, with the full [release notes](https://github.com/r-wasm/webr/releases) on GitHub.

## Evaluating R code from JavaScript

The underlying interpreter powering webR is built from the same source code as R itself, with patches applied so that it can run in the WebAssembly environment. With this release, we have rebased our patches on the latest stable version of R[^1]. By keeping our source in sync, improvements and bug fixes made by the R Core Team also benefit any project making use of webR.

WebR's core functionality is to evaluate R code from a JavaScript environment. As such, it is imperative that this works well, even with large and complex scripts. The [webR app](https://webr.r-wasm.org/v0.3.0-rc.0/) has been updated to better handle large R scripts, and scripts longer than 4096 characters should no longer cause strange issues in the R console.

### Loading WebAssembly packages

The package management functions provided by webR have been expanded and improved. Once enabled [^2], [`install.packages()`](https://rdrr.io/r/utils/install.packages.html), [`library()`](https://rdrr.io/r/base/library.html) and [`require()`](https://rdrr.io/r/base/library.html) are shimmed so that installing or loading R packages automatically downloads WebAssembly binaries from the [webR package repository](https://repo.r-wasm.org). Also, it is no longer required to run the [`library()`](https://rdrr.io/r/base/library.html) command a second time to subsequently load the package.

In this interactive example, webR is configured to automatically install WebAssembly packages. Click "Run code" to download the packages listed in the R script.

<div class="highlight">

{{< webr-editor code=`# Explicitly install wasm packages\ninstall.packages("cli")\n\n# Automatically install wasm packages\nlibrary(vctrs)\nrequire(jsonlite)\n\n# Confirm the packages installed successfully\nrownames(installed.packages())` width=504 height=311.472 >}}

</div>

See the [documentation](https://docs.r-wasm.org/webr/latest/packages.html) for more details on how to control this behaviour in your own webR-powered applications, including optionally showing an interactive download menu to the user.

### Error handling and reporting

Improvements have been made to how webR raises R conditions as JavaScript exceptions. Exceptions now include the offending source R call in the error message text, better matching what is shown in a traditional R console.

``` javascript
await webR.evalR("sin('abc')");
```

<div class="output error">

    Uncaught Error: Error in sin("abc"): non-numeric argument to mathematical function

</div>

Conditions raised when invoking function objects are now also re-thrown as JavaScript exceptions, rather than a generic `UnwindProtectException` error. Compare the error messages shown below from the previous and latest versions of webR to see the useful context added by this change.

``` javascript
// webR 0.2.2
const do_calc = await webR.evalR(`function (n){ rnorm(n) }`)
do_calc(-10)
```

<div class="output error">

    Uncaught (in promise) UnwindProtectException: A non-local transfer of control occured during evaluation

</div>

``` javascript
// webR 0.3.0
const do_calc = await webR.evalR(`function (n){ rnorm(n) }`)
do_calc(-10)
```

<div class="output error">

    Uncaught (in promise) Error: Error in rnorm(n): invalid arguments

</div>

Some base R features can be problematic when running R under WebAssembly. For example, in the constrained WebAssembly sandbox the base R function [`system()`](https://rdrr.io/r/base/system.html) does not work. The latest release of webR now handles these cases more consistently, raising R [`stop()`](https://rdrr.io/r/base/stop.html) conditions rather than incorrectly returning an empty result.

``` r
# webR 0.3.0
system()
```

<div class="output error">

    Error in webr_hook_system(command) : 
      The "system()" function is unsupported under Emscripten.

</div>

## Capturing HTML canvas graphics output

The [`captureR()`](https://docs.r-wasm.org/webr/latest/evaluating.html#evaluating-r-code-and-capturing-output-with-capturer) function is designed to capture output generated when evaluating R code. With this release, plots drawn using webR's HTML canvas graphics device, [`webr::canvas()`](https://rdrr.io/pkg/webr/man/canvas.html), are also captured and returned by default.

``` javascript
// Evaluate R code, capturing all output
const capture = await webR.globalShelter.captureR(`
  x <- rnorm(10000)
  print(x[1])
  hist(x)
`);
console.log(capture);
```

<div class="output">

    {
      result: Proxy(Object),
      output: [
        { type: 'stdout', data: '[1] 0.7612882' },
      ],
      images: [ ImageBitmap ],
    }

</div>

Captured plots are returned as an array of [`ImageBitmap`](https://developer.mozilla.org/en-US/docs/Web/API/ImageBitmap) JavaScript objects in the `images` property. This interface represents a bitmap image in a way that can be efficiently drawn to a HTML [`<canvas>`](https://developer.mozilla.org/en-US/docs/Web/HTML/Element/canvas) element.

This change makes plotting consistent with other forms of R output and simplifies the process when working with multiple independent R code blocks and output images. See the webR documentation on [evaluating R code](https://docs.r-wasm.org/webr/latest/evaluating.html#evaluating-r-code-and-capturing-output-with-capturer) for further details, and this [Observable notebook](https://observablehq.com/d/ec99bb89a4c646ab) for an example of capturing R plots from JavaScript.

### Graphics device bug fixes

In addition to adding the ability to capture graphics output, the [`webr::canvas()`](https://rdrr.io/pkg/webr/man/canvas.html) graphics device has also had various bug fixes made to better implement R base graphics. The easiest way to demonstrate is probably by example:

<div class="highlight">

{{< webr-editor code=`# The lty and lwd graphical properties now work correctly\nplot(1:10, type = "l", lty = 2, lwd = 3)\npoints(1:10, cex = 3, lwd = 2)` width=504 height=311.472 >}}

</div>

<div class="highlight">

{{< webr-editor code=`# The cex graphical property is now taken into account\n# when calculating font sizes\nplot(1, main = "This is a large title", cex.main = 3)` width=504 height=311.472 >}}

</div>

<div class="highlight">

{{< webr-editor code=`# Rasters with negative width or height are now correctly\n# drawn mirrored and flipped.\ninstall.packages("jpeg")\nlogo = jpeg::readJPEG(system.file(package = "jpeg", "img", "Rlogo.jpg"))\nplot(NULL, xlab = "", ylab = "", xlim = c(0, 1), ylim = c(0, 1))\n\nrasterImage(logo, xleft = 0.2, xright = 0.5, ybottom = 0.5, ytop = 1)\nrasterImage(logo, xleft = 0.8, xright = 0.5, ybottom = 0.5, ytop = 1)\nrasterImage(logo, xleft = 0.2, xright = 0.5, ybottom = 0.5, ytop = 0)\nrasterImage(logo, xleft = 0.8, xright = 0.5, ybottom = 0.5, ytop = 0)` width=504 height=311.472 >}}

</div>

## The R object interface

The R object interface provided by webR has been expanded to support the conversion of more types of JavaScript objects into R objects. Such conversions are automatically applied when interacting with the R environment from JavaScript.

### Raw vectors

JavaScript objects of type `TypedArray`, `ArrayBuffer`, and `ArrayBufferView` (e.g. [`Uint8Array`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Uint8Array)) may now be used to construct R objects. By default, objects of this type are converted to R raw atomic vectors. This simplifies the transfer of binary data to R.

``` javascript
const data = new Uint8Array([4, 12, 8, 24, 15, 12]);
// Print data's R object class and an example byte
await webR.evalR(`
  class(data)
  data[2]
`, { withAutoprint: true, env: { data } });
```

<div class="output">

    [1] "raw"
    [1] 0c

</div>

### R `data.frame`

JavaScript objects of shape `{ x: [...], y: [...] }`, with data in a "long" column-based form, can now be used to construct R objects. In previous versions of webR, this object shape was reserved for future use. However, with this release webR now constructs an R `data.frame` by taking the source object's properties as column vectors. The resulting `data.frame` can then be manipulated from R in the usual way:

``` javascript
const data = { column_x: ["foo", "bar", "baz"], column_y: [1, 3, 7] }
await webR.evalR(`
  class(data)
  colnames(data)
  data[2:3,]
`, { withAutoprint: true, env: { data } });
```

<div class="output">

    [1] "data.frame"
    [1] "column_x" "column_y"
            column_x column_y
     2      bar        3
     3      baz        7

</div>

Similarly, an R `data.frame` can be converted back into a JavaScript object of this form:

``` javascript
const cars = await webR.evalR(`mtcars`);
await cars.toObject();
```

<div class="output">

    {
      am: [1, 1, 1, ..., 1],
      carb: [4, 4, 1, ..., 2],
      cyl: [6, 6, 4, ..., 4]
      ...,
      wt: [2.62, 2.875, 2.32, ..., 2.78],
    }

</div>

### D3 "wide" format

In JavaScript, particularly when using frameworks built upon [D3](https://d3js.org), it is typical to work with data in a "wide" form: an array of objects per row, each including all the column names and values. With this release, webR can also convert JavaScript objects in this form into an R `data.frame`.

The following example loads the same data as shown in the previous example but expressed in the "wide" form.

``` javascript
const data = [
  { column_x: "foo", column_y: 1 },
  { column_x: "bar", column_y: 3 },
  { column_x: "baz", column_y: 7 },
];
await webR.evalR(`
  class(data)
  colnames(data)
  data[2:3,]
`, { withAutoprint: true, env: { data } });
```

<div class="output">

    [1] "data.frame"
    [1] "column_x" "column_y"
            column_x column_y
     2      bar        3
     3      baz        7

</div>

An R `data.frame` can also be converted into a D3 compatible JavaScript object:

``` javascript
const cars = await webR.evalR(`mtcars`);
await cars.toD3();
```

<div class="output">

    [
      { mpg: 21, cyl: 6, disp: 160, ... },
      { mpg: 21, cyl: 6, disp: 160, ... },
      { mpg: 22.8, cyl: 4, disp: 108, ...},
      ...
      { mpg: 21.4, cyl: 4, disp: 121, ...},
    ]

</div>

## WebAssembly toolchain upgrades

We have updated our WebAssembly build system, upgrading the [Emscripten](https://emscripten.org) C/C++ compiler to version 3.1.47 and the [LLVM Flang](https://flang.llvm.org/docs/) Fortran compiler to be based on LLVM 18.1.1. As part of the work, webR now supports building under Nix using [flakes](https://nixos.wiki/wiki/Flakes), suggested and largely implemented by [@wch](https://github.com/wch).

With this, source-code level reproducible builds of the webR WebAssembly binaries can be made, strengthening the argument for webR as a potential future platform for reproducible data science.

### LLVM Flang

To compile Fortran sources in the R source code[^3] for webR, we require a Fortran compiler that supports outputting WebAssembly objects. This is a surprisingly tricky business, and our current solution is to maintain a patched version of LLVM's `flang-new` compiler frontend.

In recent months, the patches we must make to LLVM Flang have become smaller and easier to manage as the LLVM team continues to improve the Flang frontend. While too long for this post, for those interested in exactly what changes we make to enable WebAssembly output, I have written a deep-dive blog post, [Fortran on WebAssembly](https://gws.phd/posts/fortran_wasm/).

## Additional system libraries and Rust support

Thanks to some great work by [@jeroen](https://github.com/jeroen) and [@yutannihilation](https://github.com/yutannihilation), this release of webR includes some additional WebAssembly system libraries and software in the webR Docker container. This includes numerical libraries such as [GSL](https://www.gnu.org/software/gsl/) and [GMP](https://gmplib.org), image manipulation tools such as [ImageMagick](https://imagemagick.org/), and a Rust compiler configured to build WebAssembly R packages containing Rust source code.

A demonstration R package containing Rust code, compatible with webR, can be found at <https://github.com/yutannihilation/savvy-webr-test/>.

An example Shiny app making use of the WebAssembly compiled ImageMagick library is shown below, with the source code at <https://github.com/jeroen/shinymagick>.

<iframe style="border: 1px solid black;" width="100%" height="550px" src="https://georgestagg.github.io/shinymagick/">
</iframe>

## WebAssembly R package binaries

With the introduction of additional system libraries and changes to the WebAssembly toolchain, the default webR package repository has also been refreshed. The repository tends to follow CRAN package releases, though is updated less frequently. **19452** WebAssembly R packages have been recompiled from source for this release, with **12969** packages, about 63% of CRAN, fully available[^4] for use in webR.

As my usual caveat goes, we have not been able to test all the available packages. Feel free to try your favourite package in the [webR app](https://webr.r-wasm.org/v0.3.0-rc.0/) and let us know in a [GitHub issue](https://github.com/r-wasm/webr/issues) if there is a problem.

The [package repository index](https://repo.r-wasm.org) contains further information and a searchable list of WebAssembly R packages. In addition, [R-Universe](https://r-universe.dev) also builds webR-compatible binaries and so can be used as an alternative repository for access to even more R packages.

### Building custom WebAssembly R packages

If you'd like to build your own R packages for webR, the [rwasm](https://r-wasm.github.io/rwasm/) package provides functions to help compile R packages for WebAssembly, manage repositories, and prepare webR-compatible filesystem images.

We've also started building [reusable workflows for GitHub Actions](https://github.com/r-wasm/actions/). If you have an R package with source code hosted on GitHub, an action can be added to your repository such that a WebAssembly version of your package will be built automatically by a GitHub runner on package release.

## Acknowledgements

Thank you, as always, to the users and developers contributing to webR in the form of discussion in issues, bug reports, and pull requests.

[@adrianolszewski](https://github.com/adrianolszewski), [@christianp](https://github.com/christianp), [@coatless](https://github.com/coatless), [@ColinFay](https://github.com/ColinFay), [@drgomulka](https://github.com/drgomulka), [@erex](https://github.com/erex), [@gitdemont](https://github.com/gitdemont), [@gorkang](https://github.com/gorkang), [@isbool](https://github.com/isbool), [@JeremyPasco](https://github.com/JeremyPasco), [@jeroen](https://github.com/jeroen), [@JosiahParry](https://github.com/JosiahParry), [@Luke-Symes-Tsy](https://github.com/Luke-Symes-Tsy), [@maek-ies](https://github.com/maek-ies), [@MaybeJustJames](https://github.com/MaybeJustJames), [@ravinder387](https://github.com/ravinder387), [@StaffanBetner](https://github.com/StaffanBetner), [@SugarRayLua](https://github.com/SugarRayLua), [@takahser](https://github.com/takahser), [@tim-newans](https://github.com/tim-newans), [@timelyportfolio](https://github.com/timelyportfolio), [@tstubbs-evolution](https://github.com/tstubbs-evolution), [@yhm-amber](https://github.com/yhm-amber), [@yii-iiy](https://github.com/yii-iiy), [@yutannihilation](https://github.com/yutannihilation), and [@zhangwenda0518](https://github.com/zhangwenda0518).

[^1]: The latest stable release at the time of writing: [R 4.3.3 --- "Angel Food Cake"](https://cran.rstudio.com/doc/manuals/r-release/NEWS.html)

[^2]: The package library shims are enabled by default in the webR app.

[^3]: There are also many R packages containing Fortran source code.

[^4]: Here "available" means that both a binary build of an R package and all of its dependencies can be downloaded from the repository.

