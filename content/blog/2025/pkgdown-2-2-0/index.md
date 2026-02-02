---
output: hugodown::hugo_document

slug: pkgdown-2-2-0
title: pkgdown 2.2.0
date: 2025-11-06
author: Hadley Wickham
description: >
    The latest version of pkgdown automatically builds markdown files that 
    make it easy for LLMs to use your website.

photo:
  url: https://unsplash.com/photos/cardboard-box-lot-fyaTq-fIlro
  author: CHUTTERSNAP

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [pkgdown]
rmd_hash: a51d6a5c7f8c0bdf

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

We're delighted to announce the release of [pkgdown](https://pkgdown.r-lib.org) 2.2.0. pkgdown is designed to make it quick and easy to build a beautiful and accessible website for your package.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"pkgdown"</span><span class='o'>)</span></span></code></pre>

</div>

This version of pkgdown has one major change: a new [`pkgdown::build_llm_docs()`](https://pkgdown.r-lib.org/reference/build_llm_docs.html) function that automatically creates files that make it easier for LLMs to read your documentation. Concretely, this means two things:

-   You'll get an `llms.txt` at the root directory of your site. [`llms.txt`](https://llmstxt.org) is an emerging standard that provides an easy way for an LLM to get an overview of your site. pkgdown creates an overview by combining your README, your function index, and your article index: this should give the LLM a broad overview of what your package does, along with links to find out more.

-   Every existing `.html` on your site gets a corresponding `.md` file. These are generally easier for LLMs to understand because they contain just the content of the site, without any extraneous styling.

If you don't want to generate these files, just add the following to your `_pkgdown.yaml`:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>llm-docs: false
</code></pre>

</div>

This release also includes new translations for Dutch and Japanese, removal of the long-deprecated `autolink_html()` and `preview_page()`, and a handful of other bug fixes and minor improvements. You can read about them all in the [release notes](https://github.com/r-lib/pkgdown/releases/tag/v2.2.0).

## Acknowledgements

As always, a big thanks to everyone who helped make this release possible: [@cderv](https://github.com/cderv), [@chabld](https://github.com/chabld), [@Danny-dK](https://github.com/Danny-dK), [@davidorme](https://github.com/davidorme), [@dmurdoch](https://github.com/dmurdoch), [@hadley](https://github.com/hadley), [@hfrick](https://github.com/hfrick), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@jayhesselberth](https://github.com/jayhesselberth), [@jeroenjanssens](https://github.com/jeroenjanssens), [@jmgirard](https://github.com/jmgirard), [@krlmlr](https://github.com/krlmlr), [@lorenzwalthert](https://github.com/lorenzwalthert), [@maelle](https://github.com/maelle), [@MichaelChirico](https://github.com/MichaelChirico), [@pepijn-devries](https://github.com/pepijn-devries), [@remlapmot](https://github.com/remlapmot), [@rempsyc](https://github.com/rempsyc), [@Rohit-Satyam](https://github.com/Rohit-Satyam), [@royfrancis](https://github.com/royfrancis), [@rparmm](https://github.com/rparmm), [@schloerke](https://github.com/schloerke), [@TimTaylor](https://github.com/TimTaylor), and [@usrbinr](https://github.com/usrbinr).

