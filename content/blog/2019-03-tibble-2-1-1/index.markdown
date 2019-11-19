---
title: tibble 2.1.1
slug: tibble-2.1.1
description: >
    tibble 2.1.1 is on CRAN now! This article describes and motivates the latest minor release of the tibble package.
date: 2019-03-19
author: Kirill Müller, Jenny Bryan
photo:
  url: https://unsplash.com/photos/yaiy4mCbzw0
  author: Ganapathy Kumar
categories: [package]
tags:
  - tibble
  - tidyverse
---




<STYLE type='text/css' scoped>
PRE.fansi SPAN {padding-top: .25em; padding-bottom: .25em};
</STYLE>


Version 2.1.1 of the *tibble* package is on CRAN now. Tibbles are a modern reimagining of the data frame, keeping what time has shown to be effective, and throwing out what is not, with nicer default output too! Grab the latest version with:

```r
install.packages("tibble")
```

This release mostly focuses on the name repair introduced in *tibble* 2.0.1.
We have specific regrets about one aspect of name repair and we think the pros of fixing it outweigh the cons:
when a column name is completely absent, the numbered suffix we add becomes the entire name.
Originally, we chose `..j` (two dots and a number).
However, that produces names that require special handling, because names of the form `..j` have a special meaning: they are reserved words, you can assign them a value but not query them.


```r
..2 <- 5
..2
#> Error in eval(expr, envir, enclos): ..2 used in an incorrect context, no ... to look in
```


The ability to query a value by name is very important for data frames in general and especially for the tidy evaluation framework:


```r
df <- tibble(`..1` = "not ok", .name_repair = "minimal")
with(df, `..1`)
#> Error in eval(substitute(expr), data, enclos = parent.frame()): ..1 used in an incorrect context, no ... to look in
dplyr::select(df, `..1`)
#> Error in .f(.x[[i]], ...): ..1 used in an incorrect context, no ... to look in
```

Since name repair is often something that happens automatically, we think it's best to suffix with `...j` (three dots and a number) and leave people with names that are easier to work with.


```r
as_tibble(list(1, 2, 3), .name_repair = "unique")
#> New names:
#> * `` -> ...1
#> * `` -> ...2
#> * `` -> ...3
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #555555;'># A tibble: 1 x 3</span>
#&gt;    .​.​.1  .​.​.2  .​.​.3
#&gt;   <span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span>
#&gt; <span style='color: #555555;'>1</span><span>     1     2     3</span></CODE></PRE>

Existing names of the form `..j` (and also `...`) are repaired too:


```r
tibble(... = "a", ..1 = "b", .name_repair = "unique")
#> New names:
#> * `...` -> ...1
#> * `..1` -> ...2
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #555555;'># A tibble: 1 x 2</span>
#&gt;   .​.​.1  .​.​.2 
#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span>
#&gt; <span style='color: #555555;'>1</span><span> a     b</span></CODE></PRE>

By extension, this means that names of this form are rejected unless you specify a name repair strategy:


```r
tibble(..1 = "a")
#> Error: Column 1 must not have names of the form ... or ..j.
#> Use .name_repair to specify repair.
tibble(..1 = "a", .name_repair = "minimal")
```

<PRE class="fansi fansi-output"><CODE>#&gt; <span style='color: #555555;'># A tibble: 1 x 1</span>
#&gt;   ..1  
#&gt;   <span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span>
#&gt; <span style='color: #555555;'>1</span><span> a</span></CODE></PRE>

For consistency, three dots are used for all disambiguating suffixes, not only for empty names.

This might affect you if you use *readxl* or another package that uses the new name repair, and we're sorry for the disruption.
We're confident that a bit of short-term pain now is better than the agony that would have come from the existent behavior.
Also, name repair currently is in the "maturing" lifecycle, 
Read more about name repair in the [tidyverse design principles](https://principles.tidyverse.org/names-attribute.html#the-names-attribute-of-an-object).

<p><img src="/images/tibble-2.1.1/dots.jpg"/></p>
