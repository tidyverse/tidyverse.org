---
output: hugodown::hugo_document
slug: playing-on-the-same-team-as-your-dependecy
title: Playing on the same team as your dependency
date: 2022-09-29
author: Thomas Lin Pedersen
description: >
    Using another package as a dependency is a two-way street, but the
    expectations can be murky. This blog post guides you towards becoming a 
    stellar reverse dependency.
photo:
  url: https://unsplash.com/photos/G1hIBdjQoAA
  author: Florian Schmetz
# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [learn] 
tags: []
editor_options: 
  markdown: 
    wrap: 72
rmd_hash: c02a9476f1907823

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

Developing packages for R is a matter of standing on the shoulders of others. Very seldom does packages exist in a vacuum --- on the contrary, we often rely on dependencies to avoid duplication of code or lean into the work done by experts within an adjacent field.

It can easily feel like a one-way relationship to take on a dependency of another package. You are responsible for keeping your package working and the developer of the dependency can ignore whatever goes on in your package. Code flows only from the dependency to your package. This is not true, though. By taking on a dependency you enter into a mutual relationship with it. The dependency implicitly promises not to change its interface without providing an upgrade path to you. You, on the other hand, promises to only rely on the public interface of the package. This blog post goes into detail as to what your promise entails.

### Why does this matter?

As a developer, you may be surprised to learn that the dependency's promise is enforced by CRAN. When submitting a new version for release, the package goes through a battery of tests, including a reverse dependency check where all packages on CRAN that depend on the submitted package are checked against the new version. If any regressions have occurred, it is flagged. The CRAN repository policy states:

> If an update will change the package's API and hence affect packages depending on it, it is expected that you will contact the maintainers of affected packages and suggest changes, and give them time (at least 2 weeks, ideally more) to prepare updates before submitting your updated package.

This is good in general --- it *is* important that a package maintains a stable interface across versions --- but can become a huge obstacle to updates if the packages that depends on you are reaching behind the curtain and making assumptions you never promised to adhere to.

## What's in an API?

For better and worse, R as a language is extremely liberal with what you can access as a user. There is practically no data or function you can't access and modify, which makes the concept of APIs a question of conventions. Those conventions are quite well defined when it comes to functions in packages, but much less so for everything else. We will discuss functions first, and then proceed into the more gray areas of objects and data.

### Exported functions

When creating a package, you are required to provide a NAMESPACE file which states the functions you import *into* your package for use, and the functions you export *out of* your package for others to use. The NAMESPACE file demarcates in very clear terms the functional interface of a package, but is still based on mutual trust. While you cannot import functions from a package that have not been exported, there is nothing in the R language that prevents you from using them by accessing them directly. Below, we will talk about several ways of doing this and why each of them has issues:

#### Using `:::`

R provides two operators for accessing objects in a package namespace: `::` allows you to fetch exported objects and functions, while `:::` allows you to access *any* object and function (both public and internal). Thus, you could for instance gain access to the internal `camelize()` function in ggplot2 to convert geom function names into ggproto object names like so:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>ggplot2</span><span class='nf'>:::</span><span class='nf'>camelize</span><span class='o'>(</span><span class='s'>'geom_point'</span>, first <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "GeomPoint"</span></code></pre>

</div>

*But* since there is no need for `:::` except for reaching beyond the package interface, its use is actively checked and packages using it are rejected from CRAN.

#### Using `utils::getFromNamespace()`

To circumvent the detection of `:::`, we sometimes see code like the following in packages:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>camelize</span> <span class='o'>&lt;-</span> <span class='nf'>utils</span><span class='nf'>::</span><span class='nf'><a href='https://rdrr.io/r/utils/getFromNamespace.html'>getFromNamespace</a></span><span class='o'>(</span><span class='s'>"camelize"</span>, <span class='s'>"ggplot2"</span><span class='o'>)</span></code></pre>

</div>

There are two huge issues with this approach. The first being that you now have sneakily accessed something that was never meant for public consumption (this is a general theme). The second is that you are grabbing a function from another package *at build time*. This means that the `camelize()` function living in your package is the one from the ggplot2 version available when your package got build on CRAN. Why is that a problem? Consider again `camelize()`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>ggplot2</span><span class='nf'>:::</span><span class='nv'>camelize</span>
<span class='c'>#&gt; function(x, first = FALSE) &#123;</span>
<span class='c'>#&gt;   x &lt;- gsub("_(.)", "\\U\\1", x, perl = TRUE)</span>
<span class='c'>#&gt;   if (first) x &lt;- firstUpper(x)</span>
<span class='c'>#&gt;   x</span>
<span class='c'>#&gt; &#125;</span>
<span class='c'>#&gt; &lt;bytecode: 0x106658a98&gt;</span>
<span class='c'>#&gt; &lt;environment: namespace:ggplot2&gt;</span></code></pre>

</div>

We can see that it contains a call to `firstUpper()` which is another internal function. As ggplot2 developers, we might decide one day that this factorization of code is too granular, and inline the code of `firstUpper()` into `camelize()`, allowing us to remove `firstUpper()` altogether.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># New version of camelize</span>
<span class='nv'>camelize</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span>, <span class='nv'>first</span> <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/grep.html'>gsub</a></span><span class='o'>(</span><span class='s'>"_(.)"</span>, <span class='s'>"\\U\\1"</span>, <span class='nv'>x</span>, perl <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
  <span class='kr'>if</span> <span class='o'>(</span><span class='nv'>first</span><span class='o'>)</span> <span class='nv'>x</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/paste.html'>paste0</a></span><span class='o'>(</span><span class='nf'>to_upper_ascii</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/substr.html'>substring</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='m'>1</span>, <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/substr.html'>substring</a></span><span class='o'>(</span><span class='nv'>x</span>, <span class='m'>2</span><span class='o'>)</span><span class='o'>)</span>
  <span class='nv'>x</span>
<span class='o'>&#125;</span></code></pre>

</div>

All of that would be perfectly fine for us to do. After all, we are not changing the public interface of ggplot2, we aren't even changing how `camelize()` works. But, in packages that have fetched `camelize()` at build time, the function would be unchanged, still calling `firstUpper()` which now no longer exists. As you might imagine, this can lead to some very hard to debug errors for you, your users, and the maintainer of the dependency.

#### Use `asNamespace()` inside a function

This rule can be extended beyond its use to access unexported functions: **Never assign a function from another package to a variable in your own package**. You might import a function from a package developed by someone who prefers long and descriptive function names, say `add_these_two_objects_together()`, and find it easier to create a shorthand version:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>add2</span> <span class='o'>&lt;-</span> <span class='nv'>add_these_two_objects_together</span></code></pre>

</div>

While `add_these_two_objects_together` is exported and you are doing nothing wrong in terms of interfaces, you are still setting up a build-time dependency that might cause breakage any time your dependency gets updated on a system.

Thus, we arrive at the last approach: Fetching the function inside a function call and then using it. In the example, below we are using [`asNamespace()`](https://rdrr.io/r/base/ns-internal.html) but the same principle holds true for [`getFromNamespace()`](https://rdrr.io/r/utils/getFromNamespace.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>camelize</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/r/base/ns-internal.html'>asNamespace</a></span><span class='o'>(</span><span class='s'>"ggplot2"</span><span class='o'>)</span><span class='o'>$</span><span class='nf'>camelize</span><span class='o'>(</span><span class='nv'>...</span><span class='o'>)</span>
<span class='o'>&#125;</span></code></pre>

</div>

Now, while this is many times better than what we did before, it is still a big red flag. Consider the same situation as before. We inline every use of `camelize()` in ggplot2 (it's only used once), and remove the function. This will again lead to a breakage of your package when ggplot2 got updated because you made assumptions that ggplot2 never promised anything about.

#### What to do?

What if you really wanted that functionality? A good first approach is to simply copy the code for the function into your own package. For something like `camelize()`, this is fairly simple as it doesn't call into other internal functions (except `firstUpper()` but we saw that that could be inlined). One thing to keep in mind here is to make sure that the licence of the dependency doesn't prevent you from doing this (e.g. a package released under MIT license can't copy code from a package released under a GPL-2 licence).

If you can't copy the code into your own package, either due to incompatible licenses or because the function is a rabbit hole of internal function calls, you'll need to reach out to the maintainer and ask whether the required function can be exported so you can use it. Keep in mind that there are many good reasons why you could get a "no", since every new export increases the maintenance burden of a package. So, you can get a "yes" and all is well, or you might get a "no" and have to accept that as well. Getting a "no" is not a blanket approval to do any of the above things we have discussed, for the exact reasons we described. Rather, it means you have to reframe your solution so it doesn't require this functionality or abandon it altogether.

### Exported structures

While the situation with functions is quite clear-cut --- there are *do's* and *don'ts* --- we enter a much grayer area when it comes to any sort of data/object structure you get from a dependency, either as an object exported by the package or as a return value from an exported function. The reason why it is a gray area is that there is no formal way to specify an interface to on object in R and the users are used to an "anything goes" mentality when it comes to reaching into data structures. For example, while attributes are a bit more "hidden away" than elements in a list, there is no notion of these being prohibited from access. There might be a mutual understanding that, if you alter attributes in some way, it might lead to breakage somewhere downstream. But merely reading attributes is a pretty common thing to do. The same goes for more complex objects that contain more than just data. An example is the object created by a call to `ggplot()`

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nf'>ggplot2</span><span class='nf'>::</span><span class='nf'><a href='https://ggplot2.tidyverse.org/reference/ggplot.html'>ggplot</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; List of 9</span>
<span class='c'>#&gt;  $ data       : list()</span>
<span class='c'>#&gt;   ..- attr(*, "class")= chr "waiver"</span>
<span class='c'>#&gt;  $ layers     : list()</span>
<span class='c'>#&gt;  $ scales     :Classes 'ScalesList', 'ggproto', 'gg' &lt;ggproto object: Class ScalesList, gg&gt;</span>
<span class='c'>#&gt;     add: function</span>
<span class='c'>#&gt;     clone: function</span>
<span class='c'>#&gt;     find: function</span>
<span class='c'>#&gt;     get_scales: function</span>
<span class='c'>#&gt;     has_scale: function</span>
<span class='c'>#&gt;     input: function</span>
<span class='c'>#&gt;     n: function</span>
<span class='c'>#&gt;     non_position_scales: function</span>
<span class='c'>#&gt;     scales: NULL</span>
<span class='c'>#&gt;     super:  &lt;ggproto object: Class ScalesList, gg&gt; </span>
<span class='c'>#&gt;  $ mapping    : Named list()</span>
<span class='c'>#&gt;   ..- attr(*, "class")= chr "uneval"</span>
<span class='c'>#&gt;  $ theme      : list()</span>
<span class='c'>#&gt;  $ coordinates:Classes 'CoordCartesian', 'Coord', 'ggproto', 'gg' &lt;ggproto object: Class CoordCartesian, Coord, gg&gt;</span>
<span class='c'>#&gt;     aspect: function</span>
<span class='c'>#&gt;     backtransform_range: function</span>
<span class='c'>#&gt;     clip: on</span>
<span class='c'>#&gt;     default: TRUE</span>
<span class='c'>#&gt;     distance: function</span>
<span class='c'>#&gt;     expand: TRUE</span>
<span class='c'>#&gt;     is_free: function</span>
<span class='c'>#&gt;     is_linear: function</span>
<span class='c'>#&gt;     labels: function</span>
<span class='c'>#&gt;     limits: list</span>
<span class='c'>#&gt;     modify_scales: function</span>
<span class='c'>#&gt;     range: function</span>
<span class='c'>#&gt;     render_axis_h: function</span>
<span class='c'>#&gt;     render_axis_v: function</span>
<span class='c'>#&gt;     render_bg: function</span>
<span class='c'>#&gt;     render_fg: function</span>
<span class='c'>#&gt;     setup_data: function</span>
<span class='c'>#&gt;     setup_layout: function</span>
<span class='c'>#&gt;     setup_panel_guides: function</span>
<span class='c'>#&gt;     setup_panel_params: function</span>
<span class='c'>#&gt;     setup_params: function</span>
<span class='c'>#&gt;     train_panel_guides: function</span>
<span class='c'>#&gt;     transform: function</span>
<span class='c'>#&gt;     super:  &lt;ggproto object: Class CoordCartesian, Coord, gg&gt; </span>
<span class='c'>#&gt;  $ facet      :Classes 'FacetNull', 'Facet', 'ggproto', 'gg' &lt;ggproto object: Class FacetNull, Facet, gg&gt;</span>
<span class='c'>#&gt;     compute_layout: function</span>
<span class='c'>#&gt;     draw_back: function</span>
<span class='c'>#&gt;     draw_front: function</span>
<span class='c'>#&gt;     draw_labels: function</span>
<span class='c'>#&gt;     draw_panels: function</span>
<span class='c'>#&gt;     finish_data: function</span>
<span class='c'>#&gt;     init_scales: function</span>
<span class='c'>#&gt;     map_data: function</span>
<span class='c'>#&gt;     params: list</span>
<span class='c'>#&gt;     setup_data: function</span>
<span class='c'>#&gt;     setup_params: function</span>
<span class='c'>#&gt;     shrink: TRUE</span>
<span class='c'>#&gt;     train_scales: function</span>
<span class='c'>#&gt;     vars: function</span>
<span class='c'>#&gt;     super:  &lt;ggproto object: Class FacetNull, Facet, gg&gt; </span>
<span class='c'>#&gt;  $ plot_env   :&lt;environment: R_GlobalEnv&gt; </span>
<span class='c'>#&gt;  $ labels     : Named list()</span>
<span class='c'>#&gt;  - attr(*, "class")= chr [1:2] "gg" "ggplot"</span></code></pre>

</div>

This is obviously more than just data, but which elements, if any, are actually fair to access as a package developer? This is a tough question to answer in general terms.

If you want to be a very polite (and who wouldn't), the best way to go about it is to look for accessor functions for the part of the object you are interested in, and in the absence of one, ask the maintainer to add one. The reason why accessor functions are so much better than relying on e.g. [`attr()`](https://rdrr.io/r/base/attr.html) to extract some information stored in an attribute, is that it frees the maintainer to change the *structure* of the data/object, while keeping the *interface* constant. Asking a maintainer for a public accessor function will also alert the maintainer to the fact that others are actually interested in said information, which could inform future development.

#### Testing, testing

You may be the most polite package developer, using only the finest public accessor functions in your code and keeping out of any data structure you don't control the provenance of and still be reliant of implementation details in objects from other packages. How? You may inadvertently test for their internal details in your unit tests when you are comparing objects wholesale, or if you have saved complex objects and load these up during testing.

Once again, we are certainly in a gray area here, but one guideline to help you is to ask yourself whether your unit test is only testing for parts that your own package influence, or does it also include assumptions about implementation details of another package. As an example (once again from ggplot2), you might want to ensure that a plot function in your package works as intended. On one extreme end you can save a working ggplot object returned from your function and then test for equivalence with that during unit testing. This is not a great idea because anything we might change internally in ggplot2 would likely result in changes to the created ggplot2 object. And while it still works, it may look slightly different. On the other end, you may instead do visual testing using the vdiffr package where you only look at the actual output. However, that also makes a lot of assumptions about how ggplot2 chooses to render its objects and internal changes may again break your tests without there being anything broken in reality.

> Visual testing in general is something that is mainly intended for packages providing graphic rendering, e.g. ggplot2 and it's extension package ecosystem. If you are using other packages to create your plots you should in general lean on them to test for visual regressions.

The Goldilocks zone for your testing is to figure out which exact elements your high-level plot function influences, and then get to these, preferably using public accessor functions. For ggplot2 it will often be enough to extract the data for each layer (using `layer_data()`) and test specific columns of that (never test against the full layer data since ggplot2 may add to this etc.).

If you find that you are missing public accessor function in order to do proper testing, once again reach out to the maintainer and ask. You may learn that this information is not exposed because it is subject to change, thus a poor fit for unit testing. Or you may get your function and end up with more robust tests in your own package.

While the example above is using ggplot2, this can be extrapolated to every other dependency that provide any form of complex output or exported data structure. Always question yourself whether your unit test is testing more than your own package's behavior. If they do, try to eliminate the influence of the dependencies as much as possible. Remember that tests that fail for reasons other than what it is testing for is not only annoying to you --- it can also drag out the release of the packages you rely on.

