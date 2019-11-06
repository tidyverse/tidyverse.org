---
title: roxygen2 7.0.0
author: Hadley Wickham
date: '2019-11-05'
slug: roxygen2-7-0-0
categories:
  - package
tags:
  - r-lib
  - devtools
  - roxygen2
---

We're exceedingly happy to announce the release of [roxygen2 7.0.0](https://roxygen2.r-lib.org). roxygen2 allows you to write specially formatted R comments that generate R documentation files (`man/*.Rd`) and the `NAMESPACE` file. roxygen2 is used by over 8,000 CRAN packages.

Install the latest version of roxygen2 with:


```r
install.packages("roxygen2")
```

This a huge release containing [many minor improvements and bug fixes](https://roxygen2.r-lib.org/news/index.html#roxygen2-7-0-0). This blog post focusses on seven major improvements:

* roxygen2 is no longer (ironically!) the worst documented package. It has 
  fresh new website, <https://roxygen2.r-lib.org>, and the vignettes have been
  updated to dsicussed 

* There are number of minor improvements to the formatting of `.Rd` files.
  You should expect to see quite a few changes when you document with 
  roxygen2 7.0.0 for the first time. 

* roxygen2's markdown translation now supports tables and headings.

* You can share text and code between your README/vignettes, and your 
  documentation with the new `@includeRmd` tag.

* You can now document R6 classes!

* The way in which roxygen2 loads your code is considerably more flexible, 
  making it easier to use roxygen2 in a variety of workflows.

* roxygen2 is now readily extensible and it's easy to create new tags and
  new roclets in other packages.

## Improved documentation

roxygen2 finally (!!) has a [pkgdown](https://pkgdown.r-lib.org/) website! I used this as an opportunity to look at all the vignettes and make sure they are comprehensive and readable:

* [Rd tags](https://roxygen2.r-lib.org/articles/rd.html)
* [Inline Rd formatting](https://roxygen2.r-lib.org/articles/rd-formatting.html)
* [`NAMESPACE`](https://roxygen2.r-lib.org/articles/namespace.html)

Of course, documentation can always be improved, so if you find something hard to follow, please [file an issue](https://github.com/r-lib/roxygen2/issues/new)!

## Output changes

When you run roxygen2 7.0.0 for the first time, you'll notice a number of changes to the rendered `.Rd`. The two most important are:

* `%` (the Rd comments symbol) is now automatically escaped in markdown text. That means if you previously escaped it with `\%`, you'll need to remove the backslash and take it back to `%`. 

    If you forget to do this, you'll see confusing R CMD check notes like:

    * `unknown macro '\item'`
    * `unexpected section header '\description'`
    * `unexpected END_OF_INPUT`

* You'll also notice that the functon usage formatting has changed. 

    Previously, function usage usage was wrapped to produce the smallest number of lines, e.g.:
      
    
    ```r
    parse_package(path = ".", env = env_package(path), 
      registry = default_tags(), global_options = list())
    ```
    
    Now it is wrapped so that each argument gets its own line (#820):
    
    
    ```r
    parse_package(
      path = ".",
      env = env_package(path),
      registry = default_tags(),
      global_options = list()
    )
    ```
    
    If you prefer the old behaviour you can put the following in your
    `DESCRIPTION`:
    
    ```
    Roxygen: list(old_usage = TRUE)
    ```

You'll also notice a number of small improvements:

* `@family` automatically adds `()` when linking to functions,
  and prints each link on its own line (to improve diffs).

* Markdown code (e.g. ``` `foofy` ```) is converted to to either `\code{}` or 
  `\verb{}`, depending on whether it not is R code. This better matches the 
  documentation of the `\code{}` and `\verb{}` macros, solves a certain
  class of escaping problems, and should make it easier to include arbitrary 
  "code" snippets in documentation without causing Rd failures.


## Markdown improvements

You can now use Markdown headings in top-level tags like `@description`, `@details`, and `@returns`. Level 1 headings create a new top-level `\section{}` and Level 2 headings (and below) create nested `\subsection{}`s.

Markdown tables in the [GFM table style](https://github.github.com/gfm/#tables-extension-) are converted to `\tabular{}` macros:

```md
| foo | bar |
| --- | --- |
| baz | bim |
```

would become

```
\tabular{ll}{
   foo \tab bar \cr
   baz \tab bim \cr
}
```

Usimg unsupported markdown features (like blockquotes, inline HTML, and horizontal rules) will now produce an informative message.

## R6 documentation

You can now document R6 classes!! The best place to learn more is [the vignette](https://roxygen2.r-lib.org/articles/rd.html#r6), but the basic usage is straighforward. The main difference between documenting R6 methods and documenting functions is that methods require explicit `@description` and `@detail` tags.


```r
#' R6 Class pepresenting a person
#'
#' A person has a name and a hair color.
Person <- R6::R6Class("Person",
  public = list(
    #' @field name First or full name of the person.
    name = NULL,

    #' @field hair Hair color of the person.
    hair = NULL,

    #' @description
    #' Create a new person object.
    #' @param name Name.
    #' @param hair Hair color.
    #' @return A new `Person` object.
    initialize = function(name = NA, hair = NA) {
      self$name <- name
      self$hair <- hair
      self$greet()
    },

    #' @description
    #' Change hair color.
    #' @param val New hair color.
    #' @examples
    #' P <- Person("Ann", "black")
    #' P$hair
    #' P$set_hair("red")
    #' P$hair
    set_hair = function(val) {
      self$hair <- val
    },

    #' @description
    #' Say hi.
    greet = function() {
      cat(paste0("Hello, my name is ", self$name, ".\n"))
    }
  )
)
```

This release should cover the main features, but we'll continue tweaking as people start to use in anger.

If you document a package with a lot of R6 classes, you will get a lot of warnings about documentation for missing methods. If you want to just suppress those warnings, you can off R6 documetation by setting `r6 = FALSE` in the `Roxygen` field of your `DESCRIPTION` field, i.e. `Roxygen: list(r6 = FALSE)`.

## `@includeRmd`

`@includeRmd` helps avoiding repetition, as you can use the same `.Rmd` or `.md`  document in the manual and also in the `README.md` file or in vignettes. One way to include an Rmd file in another one is to use child documents:

````
```{r child = "common.Rmd"}
```
````
[](https://roxygen2.r-lib.org/articles/rd.html#including-external--rmd-md-files)

Starting from roxygen2 7.0.0, you can use `@includeRmd path/to/file.Rmdname` to include an external `.Rmd` or `.md` document into a manual page (the path is relative package root directory). You can include the same file in multiple documentation files, and for the first time, share content across documentation and vignettes.

All content in the Rmd file will go either in the details or in new top level sections. It is currently not possible to document function arguments, return values, etc. in external Rmd documents.

The included Rmd file can have roxygen markdown style links to other help topics. E.g. `[roxygen2::roxygenize()]` will link to the manual page of the `roxygenize` function in roxygen2. See `vignette("rd-formatting.Rmd")` for details.

`@includeRmd` tries to set up knits to support caching in the Rmd file. It sets the cache path to the default knitr cache path of the included Rmd file (i.e. `foo/bar/file_cache/` for `foo/bar/file.Rmd`), so if you do not change the cache path within the Rmd itself, then everything should work out of the box. You should add these cache paths to `.gitignore` and `.Rbuildignore`.

`@includeRmd` also sets the knitr figure path of the (`fig.path`) to the default figure path of the included Rmd. Overriding this default is unlikely to work.

## Code loading

roxygen2 now provides three strategies for loading your code:

* `load_pkgload()`, the default, uses [pkgload](https://www.github.com/r-lib/pkgload). 
  Compared to the previous release, this now automatically recompiles your 
  package if needed.

* `load_source()` attaches required packages and `source()`s all files in `R/`. 
  This is a cruder simulation of package loading than pkgload (and e.g. is 
  unreliable if you use S4 extensively), but it does not require that the 
  package be compiled. Use if the default strategy (used in roxygen2 6.1.0 
  and above) causes you grief.

* `load_installed()` assumes you have installed the package. This is best
  used as part of a bigger automated workflow.

You can override the default either by calling (e.g.) `roxygenise(load_code = "source"))` or by setting the `load` option in your DESCRIPTION: `Roxygen: list(load = "source")`.

## Extending roxygen2

The process for extending roxygen2 with new tags and new roclets has been completely overhauled, and is now documented in `vignette("extending")`. If you're one of the few people who have written a roxygen2 extension, this will break your code - but the documentation, object structure, and print methods are now so much better that I hope it's not too annoying! Because this interface is now documented, it will not change in the future without warning and a deprecation cycle. 

If you have previously made a new roclet, see the major changes at <https://github.com/r-lib/roxygen2/blob/master/NEWS.md#extending-roxygen2>.

A big thanks goes to [Mikkel Meyer Andersen](https://github.com/mikldk) for starting on the vignette and motivating me to make the extension process much more pleasant (#882).

## Deprecated and defunct

* Rd comments (`%`) are automatically escaped in markdown formatted text. 
  This is a backward incompatible change because you will need to replace 
  existing uses of `\%` with `%` (#879).

* Using `@docType package` no longer automatically adds `-name`. Instead 
  document `_PACKAGE` to get all the defaults for package documentation, or
  use `@name` to override the default file name.

* `@S3method` has been removed. It was deprecated in roxygen2 4.0.0
  released 2014-05-02, over 5 years ago.

* Using the old `wrap` option will now trigger a warning, as hasn't worked
  for quite some time. Supress the error by deleting the option from your
  `DESCRIPTION`.
