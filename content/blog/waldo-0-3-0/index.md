---
output: hugodown::hugo_document

slug: waldo-0-3-0
title: waldo 0.3.0
date: 2021-08-20
author: Hadley Wickham
description: >
    waldo 0.3.0 improves the display of data frames differences, and gives the 
    objects being compared the ability to control the detail of their 
    comparisons.

photo:
  url: https://unsplash.com/photos/E9tFH39iRPE
  author: NordWood Themes

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package, programming] 
tags: [testthat, waldo]
rmd_hash: 0f7f57695bd3ff50

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
-->

We're delighted to announce the release of [waldo](https://waldo.r-lib.org) 0.3.0. waldo is designed to find and concisely describe the difference between a pair of R objects. It was designed primarily to improve failure messages for [`testthat::expect_equal()`](https://testthat.r-lib.org/reference/equality-expectations.html), but it turns out to be useful in a number of other situations.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"waldo"</span><span class='o'>)</span></code></pre>

</div>

This blog post highlights the two biggest changes in this release: a new display format for data frame differences and new tools for package developers to control the details of comparison. You can see a full list of changes in the [release notes](https://github.com/r-lib/waldo/blob/master/NEWS.md)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://waldo.r-lib.org'>waldo</a></span><span class='o'>)</span></code></pre>

</div>

## Data frame differences

waldo 0.2.0 treated data frames in the same way as lists, which worked fine if a column changed, but wasn't terribly informative if a row changed. In 0.3.0, data frames get a new row-oriented comparison:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>df1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>4</span>, <span class='m'>5</span><span class='o'>)</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span>, <span class='s'>"d"</span>, <span class='s'>"e"</span><span class='o'>)</span><span class='o'>)</span>
<span class='nv'>df2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>1</span>, <span class='m'>2</span>, <span class='m'>3</span>, <span class='m'>10</span>, <span class='m'>4</span>, <span class='m'>5</span><span class='o'>)</span>, y <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span>, <span class='s'>"X"</span>, <span class='s'>"d"</span>, <span class='s'>"e"</span><span class='o'>)</span><span class='o'>)</span>
<span class='nf'><a href='https://waldo.r-lib.org/reference/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nv'>df2</span><span class='o'>)</span>
<span class='c'>#&gt; `attr(old, 'row.names')[3:5]`: <span style='color: #555555;'>3</span> <span style='color: #555555;'>4</span> <span style='color: #555555;'>5</span>  </span>
<span class='c'>#&gt; `attr(new, 'row.names')[3:6]`: <span style='color: #555555;'>3</span> <span style='color: #555555;'>4</span> <span style='color: #555555;'>5</span> <span style='color: #0000BB;'>6</span></span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; old vs new</span>
<span class='c'>#&gt;           <span style='font-weight: bold;'>  x y</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>  old[1, ]  1 a</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>  old[2, ]  2 b</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>  old[3, ]  3 c</span></span>
<span class='c'>#&gt; <span style='color: #0000BB;'>+ new[4, ] 10 X</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>  old[4, ]  4 d</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>  old[5, ]  5 e</span></span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; `old$x`: <span style='color: #555555;'>1</span> <span style='color: #555555;'>2</span> <span style='color: #555555;'>3</span>    <span style='color: #555555;'>4</span> <span style='color: #555555;'>5</span></span>
<span class='c'>#&gt; `new$x`: <span style='color: #555555;'>1</span> <span style='color: #555555;'>2</span> <span style='color: #555555;'>3</span> <span style='color: #0000BB;'>10</span> <span style='color: #555555;'>4</span> <span style='color: #555555;'>5</span></span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; `old$y`: <span style='color: #555555;'>"a"</span> <span style='color: #555555;'>"b"</span> <span style='color: #555555;'>"c"</span>     <span style='color: #555555;'>"d"</span> <span style='color: #555555;'>"e"</span></span>
<span class='c'>#&gt; `new$y`: <span style='color: #555555;'>"a"</span> <span style='color: #555555;'>"b"</span> <span style='color: #555555;'>"c"</span> <span style='color: #0000BB;'>"X"</span> <span style='color: #555555;'>"d"</span> <span style='color: #555555;'>"e"</span></span></code></pre>

</div>

You'll notice that you still get the column comparison as well. This is important because the row-oriented comparison relies on the printed representation of the data frames, and there are important cases where data frames look the same but are actually different. The most important case is probably strings vs factors: example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='o'>(</span><span class='nv'>df1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span>, stringsAsFactors <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt;   x</span>
<span class='c'>#&gt; 1 a</span>
<span class='c'>#&gt; 2 b</span>
<span class='c'>#&gt; 3 c</span>
<span class='o'>(</span><span class='nv'>df2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/data.frame.html'>data.frame</a></span><span class='o'>(</span>x <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"a"</span>, <span class='s'>"b"</span>, <span class='s'>"c"</span><span class='o'>)</span>, stringsAsFactors <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt;   x</span>
<span class='c'>#&gt; 1 a</span>
<span class='c'>#&gt; 2 b</span>
<span class='c'>#&gt; 3 c</span>
<span class='nf'><a href='https://waldo.r-lib.org/reference/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>df1</span>, <span class='nv'>df2</span><span class='o'>)</span>
<span class='c'>#&gt; `old$x` is <span style='color: #00BB00;'>an S3 object of class &lt;factor&gt;, an integer vector</span></span>
<span class='c'>#&gt; `new$x` is <span style='color: #00BB00;'>a character vector</span> ('a', 'b', 'c')</span></code></pre>

</div>

## Control of comparison

When developing new data structures, you often need to be able to control the details of waldo's comparisons. For example, take the xml2 package, which uses the [libxml](http://xmlsoft.org) C library to parse and process XML. When you print XML that's been parsed with xml2 it looks like a string:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://xml2.r-lib.org/'>xml2</a></span><span class='o'>)</span>
<span class='nv'>x1</span> <span class='o'>&lt;-</span> <span class='nf'>xml2</span><span class='nf'>::</span><span class='nf'><a href='http://xml2.r-lib.org/reference/read_xml.html'>read_xml</a></span><span class='o'>(</span><span class='s'>"&lt;a&gt;1&lt;/a&gt;"</span><span class='o'>)</span>
<span class='nv'>x1</span>
<span class='c'>#&gt; &#123;xml_document&#125;</span>
<span class='c'>#&gt; &lt;a&gt;</span></code></pre>

</div>

But behind the scenes, it's actually two pointers to C data structures:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/str.html'>str</a></span><span class='o'>(</span><span class='nv'>x1</span><span class='o'>)</span>
<span class='c'>#&gt; List of 2</span>
<span class='c'>#&gt;  $ node:&lt;externalptr&gt; </span>
<span class='c'>#&gt;  $ doc :&lt;externalptr&gt; </span>
<span class='c'>#&gt;  - attr(*, "class")= chr [1:2] "xml_document" "xml_node"</span></code></pre>

</div>

This means that a naive comparison isn't very useful:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>x2</span> <span class='o'>&lt;-</span> <span class='nf'>xml2</span><span class='nf'>::</span><span class='nf'><a href='http://xml2.r-lib.org/reference/read_xml.html'>read_xml</a></span><span class='o'>(</span><span class='s'>"&lt;a&gt;2&lt;/a&gt;"</span><span class='o'>)</span>
<span class='nf'><a href='https://waldo.r-lib.org/reference/compare.html'>compare</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/class.html'>unclass</a></span><span class='o'>(</span><span class='nv'>x1</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/class.html'>unclass</a></span><span class='o'>(</span><span class='nv'>x2</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; `old$node` is &lt;pointer: 0x7fdfb490e790&gt;</span>
<span class='c'>#&gt; `new$node` is &lt;pointer: 0x7fdfc1d5dea0&gt;</span>
<span class='c'>#&gt; </span>
<span class='c'>#&gt; `old$doc` is &lt;pointer: 0x7fdfb490e6e0&gt;</span>
<span class='c'>#&gt; `new$doc` is &lt;pointer: 0x7fdfc1d25300&gt;</span></code></pre>

</div>

To resolve this problem, waldo provides the [`compare_proxy()`](https://waldo.r-lib.org/reference/compare_proxy.html) generic. This is called on every S3 object prior to comparison so you can transform your objects into equivalent data structures that waldo can more easily compare. For example, waldo includes a built-in `compare_proxy.xml_node()` method that converts the C data structures back to strings:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://waldo.r-lib.org/reference/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='nv'>x2</span><span class='o'>)</span>
<span class='c'>#&gt; lines(as.character(old)) vs lines(as.character(new))</span>
<span class='c'>#&gt; <span style='color: #555555;'>  "&lt;?xml version=\"1.0\" encoding=\"UTF-8\"?&gt;"</span></span>
<span class='c'>#&gt; <span style='color: #BBBB00;'>- "&lt;a&gt;1&lt;/a&gt;"</span></span>
<span class='c'>#&gt; <span style='color: #0000BB;'>+ "&lt;a&gt;2&lt;/a&gt;"</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>  ""</span></span></code></pre>

</div>

(You could imagine converting the XML structure to a tree data structure in R to get even more informative comparisons, but I didn't take the time to do so.)

[`compare_proxy()`](https://waldo.r-lib.org/reference/compare_proxy.html) has existed for some time, but waldo 0.3.0 generalised it so as well as returning the modifying object, it also returns a modified "path" that describes how the object has been transformed:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>waldo</span><span class='nf'>:::</span><span class='nv'>compare_proxy.xml_node</span>
<span class='c'>#&gt; function(x, path) &#123;</span>
<span class='c'>#&gt;   list(object = as.character(x), path = paste0("as.character(", path, ")"))</span>
<span class='c'>#&gt; &#125;</span>
<span class='c'>#&gt; &lt;bytecode: 0x7fdf6387a408&gt;</span>
<span class='c'>#&gt; &lt;environment: namespace:waldo&gt;</span></code></pre>

</div>

This means that when comparison fails, you get a clear path to the root cause.

Creating a new S3 method is reasonably heavy (and requires a little gymnastics in your package to correctly register without taking a hard dependency on waldo), so thanks to [Duncan Murdoch](http://github.com/dmurdoch) waldo 0.3.0 gains a new way of controlling comparisons: the `waldo_opts` attribute. This attribute is a list with the same names as the arguments to [`compare()`](https://waldo.r-lib.org/reference/compare.html), where the values are used override the default values of [`compare()`](https://waldo.r-lib.org/reference/compare.html). This is a powerful tool because you can inject these attributes at any level of the object hierarchy, no matter how deep.

For example, take these two lists which contain the same data but in different order:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>x1</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>a <span class='o'>=</span> <span class='m'>1</span>, b <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>
<span class='nv'>x2</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>b <span class='o'>=</span> <span class='m'>2</span>, a <span class='o'>=</span> <span class='m'>1</span><span class='o'>)</span></code></pre>

</div>

Usually waldo will report these to be different:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://waldo.r-lib.org/reference/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='nv'>x2</span><span class='o'>)</span>
<span class='c'>#&gt; `names(old)`: <span style='color: #00BB00;'>"a"</span> <span style='color: #00BB00;'>"b"</span></span>
<span class='c'>#&gt; `names(new)`: <span style='color: #00BB00;'>"b"</span> <span style='color: #00BB00;'>"a"</span></span></code></pre>

</div>

With the new `list_as_map` arugment (also thanks to an idea from Duncan Murdoch), you can request that the list be compared purely as mappings between names and values:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://waldo.r-lib.org/reference/compare.html'>compare</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='nv'>x2</span>, list_as_map <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> No differences</span></code></pre>

</div>

This is great if you want this comparison to happen at the top level of the object, but what if the difference is buried deep within a list of lists, and you only want `list_as_map` to affect one small part of the object? Well, now you can add the `waldo_opts` attribute:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/attr.html'>attr</a></span><span class='o'>(</span><span class='nv'>x1</span>, <span class='s'>"waldo_opts"</span><span class='o'>)</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span>list_as_map <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
<span class='nf'><a href='https://waldo.r-lib.org/reference/compare.html'>compare</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nv'>x1</span><span class='o'>)</span>, <span class='nf'><a href='https://rdrr.io/r/base/list.html'>list</a></span><span class='o'>(</span><span class='nv'>x2</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #00BB00;'>✔</span> No differences</span></code></pre>

</div>

## Acknowledgements

Thanks to all 14 folks who contributed to this release by filing issues, discussion ideas, and creating pull requests: [@adamhsparks](https://github.com/adamhsparks), [@batpigandme](https://github.com/batpigandme), [@bhogan-mitre](https://github.com/bhogan-mitre), [@Bisaloo](https://github.com/Bisaloo), [@brodieG](https://github.com/brodieG), [@dmurdoch](https://github.com/dmurdoch), [@ericnewkirk](https://github.com/ericnewkirk), [@hadley](https://github.com/hadley), [@krlmlr](https://github.com/krlmlr), [@mgirlich](https://github.com/mgirlich), [@michaelquinn32](https://github.com/michaelquinn32), [@mpettis](https://github.com/mpettis), [@paleolimbot](https://github.com/paleolimbot), and [@tmwdr](https://github.com/tmwdr).

