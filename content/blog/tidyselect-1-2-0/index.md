---
output: hugodown::hugo_document

slug: tidyselect-1-2-0
title: tidyselect 1.2.0
date: 2022-10-14
author: Lionel Henry and Hadley Wickham
description: >
    [tidyselect](https://tidyselect.r-lib.org/) 1.2.0 hit CRAN last week and includes a few updates to the syntax of selections in tidyverse functions

photo:
  url: https://unsplash.com/photos/xZxZxiceD8s
  author: Laura Gilchrist

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: [lifecycle]
rmd_hash: 99bfb1712693a647

---

<!--
TODO:
* [ ] Look over / edit the post's title in the yaml
* [ ] Edit (or delete) the description; note this appears in the Twitter card
* [ ] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [ ] Find photo & update yaml metadata
* [ ] Create `thumbnail-sq.jpg`; height and width should be equal
* [ ] Create `thumbnail-wd.jpg`; width should be >5x height
* [ ] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [ ] Add intro sentence, e.g. the standard tagline for the package
* [ ] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

[tidyselect](https://tidyselect.r-lib.org/) 1.2.0 hit CRAN last week and includes a few updates to the syntax of selections in tidyverse functions like `dplyr::select(...)` and `tidyr::pivot_longer(cols = )`.

tidyselect is a low level package that implements the backend for selection contexts in tidyverse functions. A selection context is an argument like `cols` in [`pivot_longer()`](https://tidyr.tidyverse.org/reference/pivot_longer.html) or a set of arguments like `...` in [`select()`](https://dplyr.tidyverse.org/reference/select.html) [^1]. In these special contexts, you can use a dialect of R that helps you create a selection of columns. You can select multiple columns with [`c()`](https://rdrr.io/r/base/c.html), a range of columns with `:`, and complex matches with selection helpers such as [`starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html). Under the hood, this selection syntax is interpreted and processed by the tidyselect package.

In this post, we'll cover the most important [lifecycle changes](https://lifecycle.r-lib.org/articles/stages.html) in the selection syntax that tidyverse users should know about. You can see a full list of changes in the [release notes](https://tidyselect.r-lib.org/news/index.html#tidyselect-120). We'll start by a quick recap of what it means in practice for a feature to be deprecated or soft-deprecated.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span></span></code></pre>

</div>

Note: With this release of tidyselect, some error messages will be suboptimal until dplyr 1.1.0 is released (planned in late October). We recommend waiting until then before updating tidyselect (though it's not a big deal if you have already updated).

## About soft-deprecation

Deprecation of features in tidyverse packages is handled by the lifecycle package. See <https://www.tidyverse.org/blog/2021/02/lifecycle-1-0-0/> for an introduction.

The main feature of lifecycle is to distinguish between two stages of deprecation and two usage modes, direct and indirect.

-   For script users, **direct usage** is when you use a deprecated feature from the global environment. If the deprecated feature was used inside a package function that you are calling, it is considered **indirect usage**.

-   For package developers, the distinction between direct and indirect usages is made by testthat in unit tests. If a function in your package calls the feature, it is considered direct usage. If that's a function in another package that you are calling, it's indirect usage.

These usage modes determine how verbose (and thus how annoying) the deprecation warnings are.

-   For **soft-deprecation**, indirect usage is always silent because we only want to alert people who are actually able to update code at this point.

    Direct usage is one warning every 8 hours to avoid being too annoying during this transition period, so that you can continue to work with existing code, ignore the warnings, and update to the new patterns when you have time.

-   For **deprecation**, it's now really time to update the code. and direct usage gives a warning every time so that deprecated features can no longer be ignored.

    Indirect usage now also warns, but only one warning every 8 hours since you indirect users are not in control of the code that uses the deprecated feature. The warning message automatically picks up the package URL where the usage was detected so that you can easily report the deprecation to the relevant maintainers.

lifecycle warnings are set up to helpfully inform you about upcoming changes while being as discrete as possible. All of the features deprecated in tidyselect in this blog post are in the soft-deprecation stage, and will remain this way for at least one year.

## Supplying character vectors of column names outside of `all_of()` and `any_of()`

To select columns from a character vector of names, you normally use [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html) or [`any_of()`](https://tidyselect.r-lib.org/reference/all_of.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>vars</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"cyl"</span>, <span class='s'>"am"</span><span class='o'>)</span></span>
<span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/all_of.html'>all_of</a></span><span class='o'>(</span><span class='nv'>vars</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://pillar.r-lib.org/reference/glimpse.html'>glimpse</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 32</span></span>
<span><span class='c'>#&gt; Columns: 2</span></span>
<span><span class='c'>#&gt; $ cyl <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 6, 6, 4, 6, 8, 6, 8, 4, 4, 6, 6, 8, 8, 8, 8, 8, 8, 4, 4…</span></span>
<span><span class='c'>#&gt; $ am  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1…</span></span></code></pre>

</div>

Whereas the former is adamant that it *must* select all of the requested columns:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/all_of.html'>all_of</a></span><span class='o'>(</span><span class='nv'>letters</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00; font-weight: bold;'>Error</span><span style='font-weight: bold;'> in `select()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> In argument: `all_of(letters)`.</span></span>
<span><span class='c'>#&gt; <span style='font-weight: bold;'>Caused by error in `all_of()`:</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BBBB00;'>!</span> Can't subset elements that don't exist.</span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>✖</span> Elements `a`, `b`, `c`, `d`, `e`, etc. don't exist.</span></span></code></pre>

</div>

The latter is more lenient and ignores any names that are not present in the data frame. In this case, it ends up selecting nothing:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/all_of.html'>any_of</a></span><span class='o'>(</span><span class='nv'>letters</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; data frame with 0 columns and 32 rows</span></span></code></pre>

</div>

Another feature of [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html) and [`any_of()`](https://tidyselect.r-lib.org/reference/all_of.html) is that they remove all ambiguity between variables in your environment like `vars` or `letters` (env-variables) and variables inside the data frame like `cyl` or `am` (data-variables). Let's add `vars` in the data frame to see what happens:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_data</span> <span class='o'>&lt;-</span> <span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>vars <span class='o'>=</span> <span class='m'>1</span><span class='o'>:</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/context.html'>n</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>my_data</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/all_of.html'>all_of</a></span><span class='o'>(</span><span class='nv'>vars</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://pillar.r-lib.org/reference/glimpse.html'>glimpse</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 32</span></span>
<span><span class='c'>#&gt; Columns: 2</span></span>
<span><span class='c'>#&gt; $ cyl <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 6, 6, 4, 6, 8, 6, 8, 4, 4, 6, 6, 8, 8, 8, 8, 8, 8, 4, 4…</span></span>
<span><span class='c'>#&gt; $ am  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1…</span></span></code></pre>

</div>

Because `vars` was supplied to [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html), [`select()`](https://dplyr.tidyverse.org/reference/select.html) will never confuse it with `mtcars$vars`. In technical terms, there is no **data-masking** within selection helpers like [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html), [`any_of()`](https://tidyselect.r-lib.org/reference/all_of.html), or even [`starts_with()`](https://tidyselect.r-lib.org/reference/starts_with.html). It is safe to supply env-variables to these functions without worrying about data-masking ambiguity.

This is not the case however if you supply a character vector outside of [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>my_data</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>vars</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://pillar.r-lib.org/reference/glimpse.html'>glimpse</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 32</span></span>
<span><span class='c'>#&gt; Columns: 1</span></span>
<span><span class='c'>#&gt; $ vars <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,…</span></span></code></pre>

</div>

This is why we have decided to deprecate direct supply of character vectors in favour of using [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html) and [`any_of()`](https://tidyselect.r-lib.org/reference/all_of.html). You will now get a soft-deprecation warning recommending to use [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>vars</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://pillar.r-lib.org/reference/glimpse.html'>glimpse</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Using an external vector in selections was deprecated in tidyselect 1.1.0.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use `all_of()` or `any_of()` instead.</span></span>
<span><span class='c'>#&gt;   # Was:</span></span>
<span><span class='c'>#&gt;   data %&gt;% select(vars)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;   # Now:</span></span>
<span><span class='c'>#&gt;   data %&gt;% select(all_of(vars))</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; See &lt;https://tidyselect.r-lib.org/reference/faq-external-vector.html&gt;.</span></span><span><span class='c'>#&gt; Rows: 32</span></span>
<span><span class='c'>#&gt; Columns: 2</span></span>
<span><span class='c'>#&gt; $ cyl <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 6, 6, 4, 6, 8, 6, 8, 4, 4, 6, 6, 8, 8, 8, 8, 8, 8, 4, 4…</span></span>
<span><span class='c'>#&gt; $ am  <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1…</span></span></code></pre>

</div>

## Using `.data` inside selections

The `.data` pronoun is a convenient way of programming with data-masking functions like [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) and [`filter()`](https://dplyr.tidyverse.org/reference/filter.html). It has two main functions:

1.  Retrieve a data frame column from a name stored in a variable with `[[`.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>var</span> <span class='o'>&lt;-</span> <span class='s'>"am"</span></span>
    <span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/transmute.html'>transmute</a></span><span class='o'>(</span>am <span class='o'>=</span> <span class='nv'>.data</span><span class='o'>[[</span><span class='nv'>var</span><span class='o'>]</span><span class='o'>]</span> <span class='o'>*</span> <span class='m'>10</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://pillar.r-lib.org/reference/glimpse.html'>glimpse</a></span><span class='o'>(</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; Rows: 32</span></span>
    <span><span class='c'>#&gt; Columns: 1</span></span>
    <span><span class='c'>#&gt; $ am <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 10, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10…</span></span></code></pre>

    </div>

2.  For package developers, `.data` is helpful to silence R CMD check notes about unknown variables. When the static analysis checker of R encounters an expression like `mtcars |> mutate(am * 2)`, it has no way of knowing that `am` is a data frame variable. Since it doesn't see any variable `am` in your environment, it emits a warning about a potential typo in the code.

    The `.data$col` pattern is used to work around this issue: `mtcars |> mutate(.data$am * 2)` doesn't produce any warnings.

Whereas `.data` is very useful in data-masking functions, its usage in selections is much more limited. As we have seen in the previous section, retrieving a variable from character vector should be done with [`all_of()`](https://tidyselect.r-lib.org/reference/all_of.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>var</span> <span class='o'>&lt;-</span> <span class='s'>"am"</span></span>
<span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/all_of.html'>all_of</a></span><span class='o'>(</span><span class='nv'>var</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://pillar.r-lib.org/reference/glimpse.html'>glimpse</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 32</span></span>
<span><span class='c'>#&gt; Columns: 1</span></span>
<span><span class='c'>#&gt; $ am <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,…</span></span></code></pre>

</div>

And to avoid the R CMD check note about unknown variables, it is much cleaner to wrap the column name in quotes:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='s'>"am"</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://pillar.r-lib.org/reference/glimpse.html'>glimpse</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Rows: 32</span></span>
<span><span class='c'>#&gt; Columns: 1</span></span>
<span><span class='c'>#&gt; $ am <span style='color: #555555; font-style: italic;'>&lt;dbl&gt;</span> 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1,…</span></span></code></pre>

</div>

Allowing the `.data` pronoun in selection contexts also makes the distinction between tidy-selections and data-masking blurrier. And so we have decided to deprecate it in selections:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>var</span> <span class='o'>&lt;-</span> <span class='s'>"am"</span></span>
<span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>.data</span><span class='o'>[[</span><span class='nv'>var</span><span class='o'>]</span><span class='o'>]</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Use of .data in tidyselect expressions was deprecated in tidyselect 1.2.0.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use `all_of(var)` (or `any_of(var)`) instead of `.data[[var]]`</span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>mtcars</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/select.html'>select</a></span><span class='o'>(</span><span class='nv'>.data</span><span class='o'>$</span><span class='nv'>am</span><span class='o'>)</span> <span class='o'>|&gt;</span> <span class='nf'><a href='https://rdrr.io/r/base/invisible.html'>invisible</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Warning: Use of .data in tidyselect expressions was deprecated in tidyselect 1.2.0.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>ℹ</span> Please use `"am"` instead of `.data$am`</span></span></code></pre>

</div>

## Acknowledgements

Many thanks to all contributors (issues and PRs) to this release!

[@alexpghayes](https://github.com/alexpghayes), [@angela-li](https://github.com/angela-li), [@apreshill](https://github.com/apreshill), [@arneschillert](https://github.com/arneschillert), [@batpigandme](https://github.com/batpigandme), [@behrman](https://github.com/behrman), [@bensoltoff](https://github.com/bensoltoff), [@braceandbracket](https://github.com/braceandbracket), [@brshallo](https://github.com/brshallo), [@bwalsh5](https://github.com/bwalsh5), [@carneybill](https://github.com/carneybill), [@ChrisDunleavy](https://github.com/ChrisDunleavy), [@ColinFay](https://github.com/ColinFay), [@courtiol](https://github.com/courtiol), [@csgillespie](https://github.com/csgillespie), [@DavisVaughan](https://github.com/DavisVaughan), [@dgrtwo](https://github.com/dgrtwo), [@DivadNojnarg](https://github.com/DivadNojnarg), [@dpprdan](https://github.com/dpprdan), [@dpseidel](https://github.com/dpseidel), [@drmowinckels](https://github.com/drmowinckels), [@dylan-cooper](https://github.com/dylan-cooper), [@EconomiCurtis](https://github.com/EconomiCurtis), [@edgararuiz-zz](https://github.com/edgararuiz-zz), [@EdwinTh](https://github.com/EdwinTh), [@elben10](https://github.com/elben10), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@espinielli](https://github.com/espinielli), [@fenguoerbian](https://github.com/fenguoerbian), [@gaborcsardi](https://github.com/gaborcsardi), [@giocomai](https://github.com/giocomai), [@gregrs-uk](https://github.com/gregrs-uk), [@gregswinehart](https://github.com/gregswinehart), [@gvelasq](https://github.com/gvelasq), [@hadley](https://github.com/hadley), [@hfrick](https://github.com/hfrick), [@hplieninger](https://github.com/hplieninger), [@ismayc](https://github.com/ismayc), [@jameslairdsmith](https://github.com/jameslairdsmith), [@jayhesselberth](https://github.com/jayhesselberth), [@jemus42](https://github.com/jemus42), [@jennybc](https://github.com/jennybc), [@jimhester](https://github.com/jimhester), [@juliasilge](https://github.com/juliasilge), [@justmytwospence](https://github.com/justmytwospence), [@karawoo](https://github.com/karawoo), [@krlmlr](https://github.com/krlmlr), [@leafyoung](https://github.com/leafyoung), [@lionel-](https://github.com/lionel-), [@lorenzwalthert](https://github.com/lorenzwalthert), [@LucyMcGowan](https://github.com/LucyMcGowan), [@maelle](https://github.com/maelle), [@markdly](https://github.com/markdly), [@martin-ueding](https://github.com/martin-ueding), [@maurolepore](https://github.com/maurolepore), [@MichaelChirico](https://github.com/MichaelChirico), [@mikemahoney218](https://github.com/mikemahoney218), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mitchelloharawild](https://github.com/mitchelloharawild), [@pkq](https://github.com/pkq), [@PursuitOfDataScience](https://github.com/PursuitOfDataScience), [@rgerecke](https://github.com/rgerecke), [@richierocks](https://github.com/richierocks), [@Robinlovelace](https://github.com/Robinlovelace), [@robinsones](https://github.com/robinsones), [@romainfrancois](https://github.com/romainfrancois), [@rosseji](https://github.com/rosseji), [@rudeboybert](https://github.com/rudeboybert), [@saghirb](https://github.com/saghirb), [@sbearrows](https://github.com/sbearrows), [@sharlagelfand](https://github.com/sharlagelfand), [@simonpcouch](https://github.com/simonpcouch), [@stedy](https://github.com/stedy), [@stephlocke](https://github.com/stephlocke), [@stragu](https://github.com/stragu), [@sysilviakim](https://github.com/sysilviakim), [@thisisdaryn](https://github.com/thisisdaryn), [@thomasp85](https://github.com/thomasp85), [@thuettel](https://github.com/thuettel), [@tmstauss](https://github.com/tmstauss), [@topepo](https://github.com/topepo), [@tracykteal](https://github.com/tracykteal), [@tyluRp](https://github.com/tyluRp), [@vspinu](https://github.com/vspinu), [@warint](https://github.com/warint), [@wibeasley](https://github.com/wibeasley), [@yitao-li](https://github.com/yitao-li), and [@yutannihilation](https://github.com/yutannihilation).

[^1]: If you are wondering whether a particular argument supports selections, look in the function documentation. Arguments tagged with `<tidy-select>` implement the selection dialect. By contrast, arguments tagged with `<data-masking>` only allow to refer to data frame columns directly.

