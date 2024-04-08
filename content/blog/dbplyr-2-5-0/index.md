---
output: hugodown::hugo_document

slug: dbplyr-2-5-0
title: dbplyr 2.5.0
date: 2024-04-08
author: Hadley Wickham
description: >
    dbplyr 2.5.0 brings improved syntax for referring to tables nested 
    in schemas and catalogs along with a bunch of minor SQL generation
    improvements.
photo:
  url: https://unsplash.com/photos/gray-metal-drawers-h6xNSDlgciU
  author: jesse orrico

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [dbplyr]
rmd_hash: 0bccf87eecfb8f59

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

We're most pleased to announce the release of [dbplyr](http://dbplyr.tidyverse.org/) 2.5.0. dbplyr is a database backend for dplyr that allows you to use a remote database as if it was a collection of local data frames: you write ordinary dplyr code and dbplyr translates it to SQL for you.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dbplyr"</span><span class='o'>)</span></span></code></pre>

</div>

This post focuses on the biggest change in dbplyr 2.5.0: improved syntax for tables nested inside schema and catalogs. As usual, this release also contains a ton of minor improvements to SQL generation, and I'd highly recommend skimming the [release notes](https://github.com/tidyverse/dbplyr/releases/tag/v2.5.0) to learn the details.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dbplyr.tidyverse.org/'>dbplyr</a></span><span class='o'>)</span></span></code></pre>

</div>

## Referring to tables in a schema

Historically, dbplyr has provided a bewildering array of options to specify a tableinside a schema inside a catalog:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'><a href='https://dbplyr.tidyverse.org/reference/ident_q.html'>ident_q</a></span><span class='o'>(</span><span class='s'>"catalog_name.schema_name.table_name"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'><a href='https://dbplyr.tidyverse.org/reference/sql.html'>sql</a></span><span class='o'>(</span><span class='s'>"SELECT * FROM catalog_name.schema_name.table_name"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'><a href='https://dbplyr.tidyverse.org/reference/in_schema.html'>in_catalog</a></span><span class='o'>(</span><span class='s'>"catalog_name"</span>, <span class='s'>"schema_name"</span>, <span class='s'>"table_name"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'><a href='https://dbplyr.tidyverse.org/reference/ident_q.html'>ident_q</a></span><span class='o'>(</span><span class='s'>"catalog_name.schema_name"</span><span class='o'>)</span>, <span class='s'>"table_name"</span><span class='o'>)</span></span>
<span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'><a href='https://dbplyr.tidyverse.org/reference/sql.html'>sql</a></span><span class='o'>(</span><span class='s'>"catalog_name.schema_name"</span><span class='o'>)</span>, <span class='s'>"table_name"</span><span class='o'>)</span></span></code></pre>

</div>

You can also use [`DBI::Id()`](https://dbi.r-dbi.org/reference/Id.html), whose syntax has also evolved over time:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/Id.html'>Id</a></span><span class='o'>(</span>database <span class='o'>=</span> <span class='s'>"catalog_name"</span>, schema <span class='o'>=</span> <span class='s'>"schema_name"</span>, table <span class='o'>=</span> <span class='s'>"table_name"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/Id.html'>Id</a></span><span class='o'>(</span>catalog <span class='o'>=</span> <span class='s'>"catalog_name"</span>, schema <span class='o'>=</span> <span class='s'>"schema_name"</span>, table <span class='o'>=</span> <span class='s'>"table_name"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'>DBI</span><span class='nf'>::</span><span class='nf'><a href='https://dbi.r-dbi.org/reference/Id.html'>Id</a></span><span class='o'>(</span><span class='s'>"catalog_name"</span>, <span class='s'>"schema_name"</span>, <span class='s'>"table_name"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

Many of these options were poorly supported (i.e. we would accidentally break them from time-to-time) and suffered from the lack of a holistic vision. This release aims to bring order to the chaos by providing a succinct new syntax for literal table identifiers: [`I()`](https://rdrr.io/r/base/AsIs.html). This allows you to succinctly identify a table nested inside a schema or catalog:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/AsIs.html'>I</a></span><span class='o'>(</span><span class='s'>"catalog_name.schema_name.table_name"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='nv'>con</span> <span class='o'>|&gt;</span> <span class='nf'>tbl</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/AsIs.html'>I</a></span><span class='o'>(</span><span class='s'>"schema_name.table_name"</span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

[`I()`](https://rdrr.io/r/base/AsIs.html) is a base function, and you may be familiar from it from modelling, e.g. `lm(y ~ x + I(y * z))`. It performs a similar role for both dbplyr and modelling function: it tells the function to treat the argument as is, rather than quoting it in the case of dbplyr, or interpreting as an interaction in the case of [`lm()`](https://rdrr.io/r/stats/lm.html).

[`I()`](https://rdrr.io/r/base/AsIs.html) is dbplyr's preferred way of specifying nested table identifiers and we will eventually formally supersede and then one day deprecate the other options. However, because their usage is widespread, this process will be slow and gradual, and play out over multiple years; there's no need to make changes now.

(If you're the author of a dbplyr backend, you'll can take advantage of this new syntax by using the `dbplyr_table_path` class. dbplyr now provides a [few helper functions](https://dbplyr.tidyverse.org/reference/is_table_path.html) to make this easier.)

## Acknowledgements

A big thanks to all 46 folks who helped to make this release possible with their thoughtful comments and code contributions! [@aarizvi](https://github.com/aarizvi), [@abalter](https://github.com/abalter), [@andreassoteriadesmoj](https://github.com/andreassoteriadesmoj), [@andrew-schulman](https://github.com/andrew-schulman), [@apalacio9502](https://github.com/apalacio9502), [@carlinstarrs](https://github.com/carlinstarrs), [@catalamarti](https://github.com/catalamarti), [@chicotobi](https://github.com/chicotobi), [@DavisVaughan](https://github.com/DavisVaughan), [@dmenne](https://github.com/dmenne), [@edgararuiz](https://github.com/edgararuiz), [@edonnachie](https://github.com/edonnachie), [@eitsupi](https://github.com/eitsupi), [@ejneer](https://github.com/ejneer), [@erydit](https://github.com/erydit), [@espinielli](https://github.com/espinielli), [@fh-afrachioni](https://github.com/fh-afrachioni), [@ghost](https://github.com/ghost), [@godislobster](https://github.com/godislobster), [@gorcha](https://github.com/gorcha), [@hadley](https://github.com/hadley), [@hild0146](https://github.com/hild0146), [@JakeHurlbut](https://github.com/JakeHurlbut), [@jarodmeng](https://github.com/jarodmeng), [@Jiefei-Wang](https://github.com/Jiefei-Wang), [@joshbal](https://github.com/joshbal), [@kelseyroberts](https://github.com/kelseyroberts), [@kmishra9](https://github.com/kmishra9), [@krlmlr](https://github.com/krlmlr), [@m-muecke](https://github.com/m-muecke), [@maciekbanas](https://github.com/maciekbanas), [@marcusmunch](https://github.com/marcusmunch), [@mgarbuzov](https://github.com/mgarbuzov), [@mgirlich](https://github.com/mgirlich), [@misea](https://github.com/misea), [@MKatz-DHSC](https://github.com/MKatz-DHSC), [@Mkranj](https://github.com/Mkranj), [@multimeric](https://github.com/multimeric), [@nathanhaigh](https://github.com/nathanhaigh), [@nilescbn](https://github.com/nilescbn), [@talegari](https://github.com/talegari), [@Tazinho](https://github.com/Tazinho), [@thomashulst](https://github.com/thomashulst), [@Thranholm](https://github.com/Thranholm), [@tomshafer](https://github.com/tomshafer), and [@wstvcg](https://github.com/wstvcg).

