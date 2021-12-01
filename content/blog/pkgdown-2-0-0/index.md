---
output: hugodown::hugo_document

slug: pkgdown-2-0-0
title: pkgdown 2.0.0
date: 2021-12-01
author: Hadley Wickham
description: >
    pkgdown 2.0.0 includes a major refresh of the default template (now 
    using bootstrap 5), many new ways to customise your site, improvements
    to code styling, and much, much, more.
    
photo:
  url: https://unsplash.com/photos/1HIKnKtXEU0
  author: Edgar Soto

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [pkgdown, devtools]
rmd_hash: b130730f1d7f8c76

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

We're very chuffed to announce the release of [pkgdown](https://pkgdown.r-lib.org) 2.0.0. pkgdown is designed to make it quick and easy to build a website for your package. Install it with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"pkgdown"</span><span class='o'>)</span></code></pre>

</div>

This is a massive release that brings a major visual refresh and a huge number of improvements. This release would not have been possible without pkgdown's newest author, [Maëlle Salmon](https://masalmon.eu), who was the powerhouse behind many of the improvements in this release, particularly the switch to Bootstrap 5, improved customisation, and implementation of local search.

There are way too many changes to describe individually here, so this post will focus on the most important new features:

-   The new template that uses Bootstrap 5.
-   The exciting new ways to customise your site.
-   Some of the biggest changes to code display.
-   A grab bag of other cool features.

See the [release notes](https://pkgdown.r-lib.org/news/index.html) for a complete list of everything that's changed.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://pkgdown.r-lib.org'>pkgdown</a></span><span class='o'>)</span></code></pre>

</div>

## Bootstrap 5

pkgdown comes with a refreshed template that uses [Bootstrap 5](https://getbootstrap.com/docs/5.1/getting-started/introduction/), a major update over the previous [Bootstrap 3](https://getbootstrap.com/docs/3.4/). (Bootstrap is the collection of HTML, CSS, and JS files that give pkgdown sites their basic style). Because this is a major change, you'll need to opt-in by setting the `boostrap` version in your `_pkgdown.yml`:

``` yaml
template:
  bootstrap: 5
```

The old Bootstrap 3 template is superseded; it will continue to work for some time, but it won't gain any new features and we encourage you to switch to the new template the next time you're working on your package.

The new theme includes:

-   A number of minor improvements to accessibility, including a larger font size, greater use of `aria` attributes, and an [accessible syntax highlighting colour scheme](https://apreshill.github.io/rmda11y/arrow.html), designed by Alison Hill.

-   Support for new features like in-line footnotes and [tabsets in articles](https://bookdown.org/yihui/rmarkdown-cookbook/html-tabs.html).

-   Since so many packages have lovely logos, the package logo is now displayed on every page and made even more prominent on the home page.

As an added incentive to upgrade your template to Bootstrap 5, you'll get site search for "free": pkgdown now supports searching with no external dependencies and no setup. Learn more in [`vignette("search")`](https://pkgdown.r-lib.org/articles/search.html).

## Customisation

The new template is also much easier to customise. A few of the most important features are noted below to whet your appetite; learn more in [`vignette("customise")`](https://pkgdown.r-lib.org/articles/customise.html).

-   You can now easily change the overall visual appearance by picking a Bootswatch theme:

    ``` yaml
    template:
      bootstrap: 5
      bootswatch: cyborg
    ```

    Or by selectively overriding the "[bslib](https://rstudio.github.io/bslib/)" variables used to generate the CSS:

    ``` yaml
    template:
      bootstrap: 5
      bslib:
        bg: "#202123"
        fg: "#B8BCC2"
        primary: "#306cc9"
        base_font: {google: "Roboto"}
    ```

    You can also choose a different syntax highlighting theme:

    ``` yaml
    template:
      bootstrap: 5
      theme: arrow-dark
    ```

    If any of these options sound intriguing, read [`vignette("customise")`](https://pkgdown.r-lib.org/articles/customise.html) to get the full details!

-   You can now translate the English text that pkgdown contributes to each page. This means that if you've written your package documentation in another language, you can ensure that language is also used on every part of the page. Activate the translations by setting the `lang` field in `_pkgdown.yaml`, e.g.:

    ``` yaml
    lang: fr
    ```

    pkgdown includes translations for Spanish (es), German (de), French (fr), Portuguese (pt), Turkish (tr) and Chinese (zh_CN). A big thanks to my colleagues who provided the initial translations, and to [@dieghernan](https://github.com/dieghernan), [@rivaquiroga](https://github.com/rivaquiroga), [@jplecavalier](https://github.com/jplecavalier) who supplied additional improvements. If you're interested in adding translations for your language please [file an issue](https://github.com/r-lib/pkgdown/issues) and we'll help you get started.

-   You can add arbitrary HTML to every page with the new `includes` parameter. This makes it easy to add analytics to your site, e.g. to use [plausible.io](https://plausible.io):

    ``` yaml
    templates:
      includes:
        in_header: |
          <script defer data-domain="{YOUR DOMAIN}" src="https://plausible.io/js/plausible.js"></script>
    ```

    Learn more in [`?build_site`](https://pkgdown.r-lib.org/reference/build_site.html).

-   The author, sidebar, and footer configuration is much more flexible, allowing you to customise individual components while keeping most of the defaults (previously customisation was mostly all or nothing). See [`?build_home`](https://pkgdown.r-lib.org/reference/build_home.html) and [`?build_site`](https://pkgdown.r-lib.org/reference/build_site.html) for details.

## Code display

We made a bunch of smaller tweaks to the display of code:

-   Errors, warnings, and messages are styled minimally to make it easier for package authors to use their own colours and styles.

-   Articles now include colours and font formatting applied by the [cli](https://cli.r-lib.org) or crayon packages.

-   Long lines in code output are now wrapped, not scrolled. This better matches [`rmarkdown::html_document()`](https://pkgs.rstudio.com/rmarkdown/reference/html_document.html) and what you see in the console.

-   You can globally set the `width` of code output (in reference and articles) with:

    ``` yaml
    code:
      width: 50
    ```

-   The copy button now automatically omits output lines (e.g. `#>`).

## Other new features

-   If you need to move pages, you can provide `redirects`:

    ``` yaml
    redirects:
      - ["articles/old-vignette-name.html", "articles/new-vignette-name.html"]
      - ["articles/another-old-vignette-name.html", "articles/new-vignette-name.html"]
      - ["articles/yet-another-old-vignette-name.html", "https://pkgdown.r-lib.org/dev"]
    ```

    (Old path on the left, new path on the right)

-   You can selectively show HTML only on the devel or release site by adding class `pkgdown-devel` or `pkgdown-release`. This is most easily accessed from `.Rmd` files where you can use pandoc's `<div>` syntax to control where a block of markdown will display. For example, you can use the following markdown in your README to only show GitHub install instructions on the development version of your site:

    ``` md
    ::: {.pkgdown-devel}
    You can install the development version of pkgdown from GitHub with:
    `remotes::install_github("r-lib/pkgdown")`
    :::
    ```

-   Support for `as_is: true` and custom output formats for vignettes/articles has been somewhat improved. Support is fundamentally limited due to the challenges of integrating HTML from output formats that pkgdown doesn't know about, but it should be a little more reliable and a little better documented.

## Acknowledgements

[@1beb](https://github.com/1beb), [@a-beretta](https://github.com/a-beretta), [@aaamini](https://github.com/aaamini), [@adamsma](https://github.com/adamsma), [@AdrianAntico](https://github.com/AdrianAntico), [@alanaw1](https://github.com/alanaw1), [@aleruete](https://github.com/aleruete), [@amirmasoudabdol](https://github.com/amirmasoudabdol), [@Anirban166](https://github.com/Anirban166), [@apreshill](https://github.com/apreshill), [@arisp99](https://github.com/arisp99), [@atusy](https://github.com/atusy), [@ayushnoori](https://github.com/ayushnoori), [@b4D8](https://github.com/b4D8), [@bastistician](https://github.com/bastistician), [@bbolker](https://github.com/bbolker), [@Bisaloo](https://github.com/Bisaloo), [@c4f3a0ce](https://github.com/c4f3a0ce), [@cbailiss](https://github.com/cbailiss), [@cboettig](https://github.com/cboettig), [@cderv](https://github.com/cderv), [@chrarnold](https://github.com/chrarnold), [@colearendt](https://github.com/colearendt), [@cpsievert](https://github.com/cpsievert), [@crazycapivara](https://github.com/crazycapivara), [@davidchall](https://github.com/davidchall), [@DavidPatShuiFong](https://github.com/DavidPatShuiFong), [@dcnorris](https://github.com/dcnorris), [@dcousin3](https://github.com/dcousin3), [@debruine](https://github.com/debruine), [@dfriend21](https://github.com/dfriend21), [@dieghernan](https://github.com/dieghernan), [@djnavarro](https://github.com/djnavarro), [@dmurdoch](https://github.com/dmurdoch), [@drwilkins](https://github.com/drwilkins), [@earowang](https://github.com/earowang), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@exploringfinance](https://github.com/exploringfinance), [@fangzhou-xie](https://github.com/fangzhou-xie), [@fenguoerbian](https://github.com/fenguoerbian), [@francojc](https://github.com/francojc), [@gaborcsardi](https://github.com/gaborcsardi), [@gadenbuie](https://github.com/gadenbuie), [@GeoBosh](https://github.com/GeoBosh), [@GitHunter0](https://github.com/GitHunter0), [@gustavdelius](https://github.com/gustavdelius), [@hadley](https://github.com/hadley), [@HenrikBengtsson](https://github.com/HenrikBengtsson), [@hfrick](https://github.com/hfrick), [@ijlyttle](https://github.com/ijlyttle), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@JakeVestal](https://github.com/JakeVestal), [@jakob-wirbel](https://github.com/jakob-wirbel), [@JamesHWade](https://github.com/JamesHWade), [@jayhesselberth](https://github.com/jayhesselberth), [@JedGrabman](https://github.com/JedGrabman), [@jennybc](https://github.com/jennybc), [@jessekps](https://github.com/jessekps), [@jhelvy](https://github.com/jhelvy), [@jimhester](https://github.com/jimhester), [@john-harrold](https://github.com/john-harrold), [@jonkeane](https://github.com/jonkeane), [@jplecavalier](https://github.com/jplecavalier), [@jrosen48](https://github.com/jrosen48), [@jscott6](https://github.com/jscott6), [@kevinushey](https://github.com/kevinushey), [@kjhealy](https://github.com/kjhealy), [@klmr](https://github.com/klmr), [@krassowski](https://github.com/krassowski), [@krlmlr](https://github.com/krlmlr), [@kuriwaki](https://github.com/kuriwaki), [@kyleam](https://github.com/kyleam), [@laresbernardo](https://github.com/laresbernardo), [@lbusett](https://github.com/lbusett), [@lionel-](https://github.com/lionel-), [@maelle](https://github.com/maelle), [@ManuelHentschel](https://github.com/ManuelHentschel), [@MarkEdmondson1234](https://github.com/MarkEdmondson1234), [@matthewstrasiotto](https://github.com/matthewstrasiotto), [@mattwarkentin](https://github.com/mattwarkentin), [@maxheld83](https://github.com/maxheld83), [@mcanouil](https://github.com/mcanouil), [@mfherman](https://github.com/mfherman), [@mikeroswell](https://github.com/mikeroswell), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mjsteinbaugh](https://github.com/mjsteinbaugh), [@moutikabdessabour](https://github.com/moutikabdessabour), [@mrcaseb](https://github.com/mrcaseb), [@msberends](https://github.com/msberends), [@mtkerbeR](https://github.com/mtkerbeR), [@nandp1](https://github.com/nandp1), [@npranav10](https://github.com/npranav10), [@p-carter](https://github.com/p-carter), [@pachadotdev](https://github.com/pachadotdev), [@paulponcet](https://github.com/paulponcet), [@peterblattmann](https://github.com/peterblattmann), [@renejuan](https://github.com/renejuan), [@rich-iannone](https://github.com/rich-iannone), [@Rmomal](https://github.com/Rmomal), [@Robinlovelace](https://github.com/Robinlovelace), [@royfrancis](https://github.com/royfrancis), [@rundel](https://github.com/rundel), [@salim-b](https://github.com/salim-b), [@samuel-marsh](https://github.com/samuel-marsh), [@samuel-rosa](https://github.com/samuel-rosa), [@sarahemlin](https://github.com/sarahemlin), [@SchmidtPaul](https://github.com/SchmidtPaul), [@statnmap](https://github.com/statnmap), [@stefanoborini](https://github.com/stefanoborini), [@strengejacke](https://github.com/strengejacke), [@topepo](https://github.com/topepo), [@vandenman](https://github.com/vandenman), [@wlandau](https://github.com/wlandau), [@wolski](https://github.com/wolski), [@wviechtb](https://github.com/wviechtb), [@ycphs](https://github.com/ycphs), and [@yitao-li](https://github.com/yitao-li).

