---
output: hugodown::hugo_document

slug: cran-checks-compiled-code
title: "New CRAN requirements for packages with C and C++"
date: 2023-03-13
author: Andy Teucher
description: >
    A few recent changes in CRAN requirements for packages containing C or C++
    code have caused package developers some headaches. This post outlines
    the issues and provides solutions the tidyverse team has used to address them.

photo:
  url: https://unsplash.com/photos/dhGFLj3rI0Q
  author: Quino Al

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn, programming]
rmd_hash: ccd4cbdf603a062c

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
* [ ] `Add intro sentence, e.g. the standard tagline for the package
* [ ] `usethis::use_tidy_thanks()`
-->

The R package landscape is dynamic, with changes in infrastructure common, especially when CRAN makes changes to their policies and requirements. This is particularly true for packages that include low-level compiled code, requiring developers to be nimble in responding to these changes.

The tidyverse team at Posit is in the unique situation where we have a concentration of developers working full-time on creating and maintaining open source packages. This internal community provides the opportunity to collaborate to develop shared practices and discover solutions to problems that arise. When we can, we like to share what we've learned so other developers can benefit.

There have been a few recent changes at CRAN for packages containing C and C++ code that developers have had to adapt to, and we would like to share some of our learning:

## NOTE regarding `SystemRequirements: C++11`

Many package authors might have noticed a new NOTE on R-devel when submitting a package to CRAN containing C++ code:

    * checking C++ specification ...
      NOTE Specified C++11: please drop specification unless essential

This NOTE is now appearing during `R CMD check` on R-devel for packages where the DESCRIPTION file has the following:

    SystemRequirements: C++11 

Packages that use C++11 would also usually have set `CXX_STD=CXX11` in the `src/Makevars` and `src/Makevars.win` files (and `src/Makevars.ucrt`, if present). These specifications tell R to use the C++11 standard when compiling the code.

To understand the NOTE, a bit of history will be helpful (thanks to Winston Chang for [writing this up](https://gist.github.com/wch/849ca79c9416795d99c48cc06a44ca1e)):

-   In R 3.5 and below, on systems with an old compiler, R would default to using the C++98 standard when compiling the code. If a package needed a C++11 compiler, the DESCRIPTION file needed to have `SystemRequirements: C++11`, and the various `src/Makevars*` files needed to set `CXX_STD=CXX11`.
-   In R 3.6.2, R began defaulting to compiling packages with the C++11 standard, as long as the compiler supported C++11 (which was true on most systems).
-   In R 4.0, C++11 became the minimum supported compiler, so `SystemRequirements: C++11` was no longer necessary.
-   In (the forthcoming) R 4.3, the [default C++ standard is C++17](https://developer.r-project.org/blosxom.cgi/R-devel/NEWS/2023/01/27#n2023-01-27) where available. `R CMD check` now [raises a NOTE](https://developer.r-project.org/blosxom.cgi/R-devel/NEWS/2023/01/31) if anything older than the default is specified in `SystemRequirements:` or `CXX_STD` in the various `src/Makevars*` files. This NOTE will block submission to CRAN --- if the standard you specify is necessary for your package you will likely need to explain why.

### How to fix it

1.  Edit the DESCRIPTION file and remove `SystemRequirements: C++11`.
2.  Edit `src/Makevars`, `src/Makevars.win`, and `src/Makevars.ucrt` and remove `CXX_STD=CXX11`.

After making these changes, the package should install without trouble on R 3.6 and above. It may not build on R \<= 3.5 on systems with very old compilers, though it is likely that the vast majority of users will have a newer version of R and/or have recent enough compilers. If you want to be confident that your package will be installable on R 3.5 and below with old compilers, there are several options; we offer two of the simplest approaches here:

-   You can use a configure script at the top level of the package, and have it add `CXX_STD=CXX11` for R 3.5 and below. An example (unmerged) [pull request to the readxl](https://github.com/tidyverse/readxl/pull/722/files) package demonstrates this approach. You will also need to add `Biarch: true` in your DESCRIPTION file. This appears to be the approach preferred by CRAN.
-   For users with R \<= 3.5 on a system with an older compiler, package authors can instruct users to edit their `~/.R/Makevars` file to include this line: `CXX_STD=CXX11`.

The tidyverse has a [policy of supporting four previous versions](https://www.tidyverse.org/blog/2019/04/r-version-support/) of R. Currently that includes R 3.5, but with the upcoming release of R 4.3 (which should be this Spring some time) the minimum version we will support is R 3.6. As we won't be supporting R 3.5 in the near future, you should not feel pressured to either unless you have a compelling reason.

## WARNING regarding the use of <code>sprintf()</code> in C/C++

Another recent change in CRAN checks on R-devel that authors might encounter is the disallowing of the use of the C functions <code>sprintf()</code> and `vsprintf()`. `R CMD check` on R-devel may throw warnings that look something like this:

    checking compiled code ... WARNING
    File 'fs/libs/fs.so':
      Found 'sprintf', possibly from 'sprintf' (C)
        Object: 'file.o'
    Compiled code should not call entry points which might 
    terminate R nor write to stdout/stderr instead of to the 
    console, nor use Fortran I/O nor system RNGs nor [v]sprintf.
    See 'Writing portable packages' in the 'Writing R Extensions' manual.

According to the [NEWS for R-devel](https://developer.r-project.org/blosxom.cgi/R-devel/NEWS/2022/12/24#n2022-12-24) (which will be R 4.3):

> The use of sprintf and vsprintf from C/C++ has been deprecated in macOS 13 and is a known security risk. `R CMD check` now reports (on all platforms) if their use is found in compiled code: replace by snprintf or vsnprintf respectively.

These are considered to be a security risk because they potentially allow [buffer overflows](https://en.wikipedia.org/wiki/Buffer_overflow) that write more bytes than are available in the output buffer. This is a risk if the text that is being passed to <code>sprintf()</code> comes from an uncontrolled source.

Here is a very simple example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://cpp11.r-lib.org'>cpp11</a></span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'><a href='https://cpp11.r-lib.org/reference/cpp_source.html'>cpp_function</a></span><span class='o'>(</span><span class='s'>'</span></span>
<span><span class='s'>  int say_height(int height) &#123;</span></span>
<span><span class='s'>    // "My height is xxx cm" is 19 characters but we need</span></span>
<span><span class='s'>    // to add one for the null-terminator</span></span>
<span><span class='s'>    char out[19 + 1];</span></span>
<span><span class='s'>    int n;</span></span>
<span><span class='s'>    n = sprintf(out, "My height is %i cm", height);</span></span>
<span><span class='s'>    Rprintf(out);</span></span>
<span><span class='s'>    return n;</span></span>
<span><span class='s'>  &#125;</span></span>
<span><span class='s'>'</span></span>
<span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>say_height</span><span class='o'>(</span><span class='m'>182</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; My height is 182 cm</span></span>
<span></span><span><span class='c'>#&gt; [1] 19</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>say_height</span><span class='o'>(</span><span class='m'>1824</span><span class='o'>)</span> <span class='c'># This will abort due to buffer overflow</span></span></code></pre>

</div>

### How to fix it

In most cases, this should be a simple fix: replace <code>sprintf()</code> with `snprintf()` and `vsprintf()` with `vsnprintf()`. These `n` variants take a second parameter that specifies the maximum number of bytes written. If the output is a static buffer, you can use `sizeof()`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://cpp11.r-lib.org/reference/cpp_source.html'>cpp_function</a></span><span class='o'>(</span><span class='s'>'</span></span>
<span><span class='s'>  int say_height_safely(int height) &#123;</span></span>
<span><span class='s'>    // "My height is xxx cm" is 19 characters but we need </span></span>
<span><span class='s'>    // to add one for the null-terminator</span></span>
<span><span class='s'>    char out[19 + 1];</span></span>
<span><span class='s'>    int n;</span></span>
<span><span class='s'>    n = snprintf(out, sizeof(out), "My height is %i cm", height);</span></span>
<span><span class='s'>    Rprintf(out);</span></span>
<span><span class='s'>    if (n &gt;= sizeof(out)) &#123;</span></span>
<span><span class='s'>       Rprintf("\\nTruncated because input is longer than allowed!\\n");</span></span>
<span><span class='s'>    &#125;</span></span>
<span><span class='s'>    return n;</span></span>
<span><span class='s'>  &#125;</span></span>
<span><span class='s'>'</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>say_height_safely</span><span class='o'>(</span><span class='m'>182</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; My height is 182 cm</span></span>
<span></span><span><span class='c'>#&gt; [1] 19</span></span>
<span></span><span><span class='nf'>say_height_safely</span><span class='o'>(</span><span class='m'>1824</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; My height is 1824 c</span></span>
<span><span class='c'>#&gt; Truncated because input is longer than allowed!</span></span>
<span></span><span><span class='c'>#&gt; [1] 20</span></span>
<span></span></code></pre>

</div>

Notice that the return value of `sprintf()` and `snprintf()` are different. `sprintf()` returns the total number of characters written (excluding the null-terminator), while `snprintf()` returns the number of character that would have been written had `n` been sufficiently large.

If the destination is not a static buffer, the easiest thing to do is pass in the size of the array:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://cpp11.r-lib.org/reference/cpp_source.html'>cpp_function</a></span><span class='o'>(</span><span class='s'>'</span></span>
<span><span class='s'>  int say_height_safely(int height) &#123;</span></span>
<span><span class='s'>    // "My height is xxx cm" is 19 characters but we need </span></span>
<span><span class='s'>    // to add one for the null-terminator</span></span>
<span><span class='s'>    size_t size = 19 + 1; </span></span>
<span><span class='s'>    char out[size]; </span></span>
<span><span class='s'>    int n; </span></span>
<span><span class='s'>    n = snprintf(out, size, "My height is %i cm", height);</span></span>
<span><span class='s'>    Rprintf(out);</span></span>
<span><span class='s'>    if (n &gt;= sizeof(out)) &#123;</span></span>
<span><span class='s'>       Rprintf("\\nTruncated because input is longer than allowed!\\n");</span></span>
<span><span class='s'>    &#125;</span></span>
<span><span class='s'>    return n;</span></span>
<span><span class='s'>  &#125;</span></span>
<span><span class='s'>'</span><span class='o'>)</span></span>
<span></span>
<span><span class='nf'>say_height_safely</span><span class='o'>(</span><span class='m'>1824</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; My height is 1824 c</span></span>
<span><span class='c'>#&gt; Truncated because input is longer than allowed!</span></span>
<span></span><span><span class='c'>#&gt; [1] 20</span></span>
<span></span></code></pre>

</div>

## WARNING regarding the use of strict prototypes in C

Many maintainers with packages containing C code have also been getting hit with this warning:

    warning: a function declaration without a prototype is deprecated in all versions of C [-Wstrict-prototypes]

This usually comes from C function declarations that look like this, with no arguments specified (which is very common):

``` c
int myfun() {
  ...
};
```

This new warning is because CRAN is now running checks on R-devel with the `-Wstrict-prototypes` compiler flag set. In R we define functions that take no arguments with `myfun <- function() {...}` all the time. In C, with this flag set, the fact that a function takes no arguments must be explicitly stated (i.e., the arguments list cannot be empty). In the upcoming C23 standard, empty function signatures will be considered valid and not ambiguous, however at this point it is likely to be the reason you encounter this warning from CRAN.

### How to fix it

This can be fixed by placing the `void` keyword in the previously empty argument list:

``` c
int myfun(void) {
  ...
};
```

Here is an example where the authors of [Cubist](https://topepo.github.io/Cubist/) applied the [necessary patches](https://github.com/topepo/Cubist/pull/46), and [another one in rlang](https://github.com/r-lib/rlang/pull/1508).

### Vendored code

Function declarations without a prototype are very common, and unfortunately are thus likely to appear in libraries that you include in your package. This may require you to patch that code in your package. The [readxl](https://readxl.tidyverse.org) package includes the [libxls C library](https://github.com/libxls/libxls), which was patched [in readxl here](https://github.com/tidyverse/readxl/commit/afdc9b90cfc2bb1e1c5490c7ba3af5ecfc4a7876) to deal with this issue.

The ideal solution in cases like this would be to submit patches to the upstream libraries so you don't have to deal with the ongoing maintenance of your local patches, but that is not always possible. Generally, you can explain this problem when submitting your package, and as long as you've have notified the upstream maintainer, CRAN should accept your updated package.

### Unspecified types in function signature

The `-Wstrict-prototypes` compiler flag will also catch deprecated function definitions where the types of the arguments are not declared. This is actually likely the primary purpose for CRAN enabling this flag, as it is ambiguous and much more dangerous than empty function signatures.

These take the form:

``` c
void myfun(x, y) {
  ...
};
```

where the argument types are not declared. This is solved by declaring the types of the arguments:

``` c
void myfun(int x, char* y) {
  ...
};
```

