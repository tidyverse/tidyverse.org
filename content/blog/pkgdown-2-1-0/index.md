---
output: hugodown::hugo_document

slug: pkgdown-2-1-0
title: pkgdown 2.1.0
date: 2024-07-05
author: Hadley Wickham
description: >
    pkgdown 2.1.0 includes two major new features: support for quarto vignettes
    and a "light switch" that lets the reader switch between light and dark 
    mode. It also contains a bunch of other improvements to both the user
    and the developer experience.

photo:
  url: https://chatgpt.com/
  author: ChatGPT 4o

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [devtools, pkgdown]
rmd_hash: 25c015f526e1f499

---

<!--
TODO:
* [x] Look over / edit the post's title in the yaml
* [x] Edit (or delete) the description; note this appears in the Twitter card
* [s] Pick category and tags (see existing with [`hugodown::tidy_show_meta()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html))
* [x] Find photo & update yaml metadata
* [x] Create `thumbnail-sq.jpg`; height and width should be equal
* [x] Create `thumbnail-wd.jpg`; width should be >5x height
* [x] [`hugodown::use_tidy_thumbnails()`](https://rdrr.io/pkg/hugodown/man/use_tidy_post.html)
* [x] Add intro sentence, e.g. the standard tagline for the package
* [x] [`usethis::use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html)
-->

We're delighted to announce the release of [pkgdown](http://pkgdown.r-lib.org/) 2.1.0. pkgdown is designed to make it quick and easy to build a beautiful and accessible website for your package.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"pkgdown"</span><span class='o'>)</span></span></code></pre>

</div>

This is a massive release with a bunch of new features. I'll highlight the most important here, but as always, I highlight recommend skimming the [release notes](https://github.com/r-lib/pkgdown/releases/tag/v2.1.0) for other smaller improvements and bug fixes.

First, and most importantly, please join me in welcoming two new authors to pkgdown: [Olivier Roy](https://github.com/olivroy) and [Salim Brüggemann](https://github.com/salim-b). They have both contributed many improvements to the package and I'm very happy to officially have them aboard as package authors.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://pkgdown.r-lib.org/'>pkgdown</a></span><span class='o'>)</span></span></code></pre>

</div>

## Lifecycle changes

Let's get started with the important stuff, the [lifecycle updates](https://www.tidyverse.org/blog/2021/02/lifecycle-1-0-0/). Most important we've decided to deprecate support for Bootstrap 3, which was superseded in December 2021. We're starting to more directly encourage folks to move away from it as maintaining two separate sets of site templates is a time sink. If you're still using BS3, now's the [time to upgrade](https://www.tidyverse.org/blog/2021/12/pkgdown-2-0-0/#bootstrap-5).

There are three other changes that are less likely to affect folks:

-   The `document` argument to [`build_site()`](https://pkgdown.r-lib.org/reference/build_site.html) and [`build_reference()`](https://pkgdown.r-lib.org/reference/build_reference.html) has been removed after being deprecated in pkgdown 1.4.0; use the [`devel` argument](https://pkgdown.r-lib.org/reference/build_site.html#arg-devel) instead.

-   [`autolink_html()`](https://pkgdown.r-lib.org/reference/autolink_html.html) was deprecated in pkgdown 1.6.0 and now warns every time you use it; use [`downlit::downlit_html_path()`](https://downlit.r-lib.org/reference/downlit_html_path.html) instead.

-   [`preview_page()`](https://pkgdown.r-lib.org/reference/preview_page.html) has been deprecated; use [`preview_site()`](https://pkgdown.r-lib.org/reference/preview_site.html) instead.

## Major new features

pkgdown 2.1.0 has two major new features: support for Quarto vignettes and a new light switch that toggles between light and dark modes.

### Quarto support

[`build_article()`](https://pkgdown.r-lib.org/reference/build_articles.html)/[`build_articles()`](https://pkgdown.r-lib.org/reference/build_articles.html) now support articles and vignettes written with Quarto. To use it, make sure you have the the latest version of Quarto, 1.5, which was released last week. By and large you should be able to just write in Quarto and things will just work, but you will need to make a small change to your GitHub action. Learn more at [`vignette("quarto")`](https://pkgdown.r-lib.org/articles/quarto.html).

Combining the individual quarto and pkgdown templating systems is a delicate art, so while I've done my best to make it work, there may be some rough edges. Check out the current known limitations in [`vignette("quarto")`](https://pkgdown.r-lib.org/articles/quarto.html), and please file an issue if you encounter a quarto feature that doesn't work quite right.

### Light switch

pkgdown sites can now provide a "light switch" that allows the reader to switch between light and dark modes (based on work in bslib by [@gadenbuie](https://github.com/gadenbuie)). You can try it out on <https://pkgdown.r-lib.org>: the light switch appears at the far right at the navbar and remembers the users choice between visits to your site.

(Note that the light switch works differently to quarto dark mode. In quarto, you can provide two completely different themes for light and dark mode. In pkgdown, dark mode is a relatively thin overlay that based on your light theme colours.)

For now, you'll need to opt-in to the light-switch by adding the following to your `_pkgdown.yml`:

``` yaml
template
  light-switch: true
```

In the future we hope to turn it on automatically.

You can learn more about customising the light switch in [`vignette("customise")`](https://pkgdown.r-lib.org/articles/customise.html): you can choose to select your own syntax highlighting scheme for dark mode, override dark-specific BS lib variables, and move its location in the navbar.

## User experience

We've made a bunch of small changes to enhance the user experience of pkgdown sites:

-   We've continued in our efforts to make pkgdown sites as accessible as possible by now warning if you've forgotten to add alt text to images (including plots) in your articles. We've also added a new [`vignette("accessibility")`](https://pkgdown.r-lib.org/articles/accessibility.html) which describes additional manual tasks you can perform to make your site as accessible as possible.

-   [`build_reference()`](https://pkgdown.r-lib.org/reference/build_reference.html) adds anchors to arguments making it possible to link directly to an argument. This is very useful when you're trying to direct folks to the documentation for a specific argument, e.g. <https://pkgdown.r-lib.org/reference/build_site.html#arg-devel>.

-   [`build_reference_index()`](https://pkgdown.r-lib.org/reference/build_reference.html) now displays function lifecycle badges [next to the function name](https://pkgdown.r-lib.org/reference/index.html#deprecated-functions). If you want to gather together (e.g.) all the deprecated function in one spot in the reference index, you can use the new topic selector `has_lifecycle("deprecated")`.

-   The new `template.math-rendering` option allows you to control how math is rendered on your site. The default uses `mathml` which is zero dependency but has the lowest fidelity. If you use a lot of math on your site, you can switch back to the previous method with `mathjax`, or try out `katex`, a faster alternative.

-   pkgdown sites no longer depend on external content distribution networks (CDN) for common javascript, CSS, and font files. CDNs no longer provide [any performance advantages](https://www.stefanjudis.com/notes/say-goodbye-to-resource-caching-across-sites-and-domains/) and make deployment harder inside certain locked-down corporate environments.

-   pkgdown includes translations for more terms including "Abstract" and "Search site". A big thanks to @jplecavalier, @dieghernan, @krlmlr, @LDalby, @rich-iannone, @jmaspons, and @mine-cetinkaya-rundel for providing updated translations in French, Spanish, Portugese, Germna, Catalan, and Turkish!

    I've also written [`vignette("translations")`](https://pkgdown.r-lib.org/articles/translations.html), a brief vignette that discusses how translation works for non-English sites, and includes how you can create translations for new languages. (This is a great way to contribute to pkgdown if you are multi-lingual!)

### Developer experience

We've also made a bunch of minor improvements to make improve the package developer experience:

-   YAML validation has been substantially improved so you should get much clearer errors if you have made a mistake in your `_pkgdown.yml`. Please [file an issue](https://github.com/r-lib/pkgdown/issues/new) if you find a case where the error message is not helpful.

-   The `build_*()` functions (apart from [`build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)) no longer automatically preview in interactive sessions since they all emit clickable links to any files that have changed. You can continue to use [`preview_site()`](https://pkgdown.r-lib.org/reference/preview_site.html) to open the site in your browser.

-   The `build_*()` functions now work better if you're previewing just part of a site and haven't built the whole thing. It should no longer be necessary to run [`init_site()`](https://pkgdown.r-lib.org/reference/init_site.html) in most cases, and you shouldn't be able to get into a state where you're told to run [`init_site()`](https://pkgdown.r-lib.org/reference/init_site.html) and then it doesn't work.

-   We give more and clearer details of the site building process including reporting on exactly what is generated by bslib, what is copied from templates, and what redirects are generated.

## Acknowledgements

A big thanks to all 212 folks who contributed to this release! [@Adafede](https://github.com/Adafede), [@AEBilgrau](https://github.com/AEBilgrau), [@albertocasagrande](https://github.com/albertocasagrande), [@alex-d13](https://github.com/alex-d13), [@AliSajid](https://github.com/AliSajid), [@arkadiuszbeer](https://github.com/arkadiuszbeer), [@ArneBab](https://github.com/ArneBab), [@asadow](https://github.com/asadow), [@ateucher](https://github.com/ateucher), [@avhz](https://github.com/avhz), [@banfai](https://github.com/banfai), [@barcaroli](https://github.com/barcaroli), [@BartJanvanRossum](https://github.com/BartJanvanRossum), [@bastistician](https://github.com/bastistician), [@ben18785](https://github.com/ben18785), [@bijoychandraAU](https://github.com/bijoychandraAU), [@Bisaloo](https://github.com/Bisaloo), [@bkmgit](https://github.com/bkmgit), [@bnprks](https://github.com/bnprks), [@brycefrank](https://github.com/brycefrank), [@bschilder](https://github.com/bschilder), [@bundfussr](https://github.com/bundfussr), [@cararthompson](https://github.com/cararthompson), [@Carol-seven](https://github.com/Carol-seven), [@cbailiss](https://github.com/cbailiss), [@cboettig](https://github.com/cboettig), [@cderv](https://github.com/cderv), [@chlebowa](https://github.com/chlebowa), [@chuxinyuan](https://github.com/chuxinyuan), [@cromanpa94](https://github.com/cromanpa94), [@cthombor](https://github.com/cthombor), [@d-morrison](https://github.com/d-morrison), [@DanChaltiel](https://github.com/DanChaltiel), [@DarioS](https://github.com/DarioS), [@davidchall](https://github.com/davidchall), [@DavisVaughan](https://github.com/DavisVaughan), [@dbosak01](https://github.com/dbosak01), [@dchiu911](https://github.com/dchiu911), [@ddsjoberg](https://github.com/ddsjoberg), [@DeepanshKhurana](https://github.com/DeepanshKhurana), [@dhersz](https://github.com/dhersz), [@dieghernan](https://github.com/dieghernan), [@djhocking](https://github.com/djhocking), [@dkarletsos](https://github.com/dkarletsos), [@dmurdoch](https://github.com/dmurdoch), [@dshemetov](https://github.com/dshemetov), [@dsweber2](https://github.com/dsweber2), [@dvg-p4](https://github.com/dvg-p4), [@DyfanJones](https://github.com/DyfanJones), [@ecmerkle](https://github.com/ecmerkle), [@eddelbuettel](https://github.com/eddelbuettel), [@eeholmes](https://github.com/eeholmes), [@eitsupi](https://github.com/eitsupi), [@eliocamp](https://github.com/eliocamp), [@elong0527](https://github.com/elong0527), [@EmilHvitfeldt](https://github.com/EmilHvitfeldt), [@erikarasnick](https://github.com/erikarasnick), [@esimms999](https://github.com/esimms999), [@espinielli](https://github.com/espinielli), [@etiennebacher](https://github.com/etiennebacher), [@ewenharrison](https://github.com/ewenharrison), [@filipsch](https://github.com/filipsch), [@FlukeAndFeather](https://github.com/FlukeAndFeather), [@francoisluc](https://github.com/francoisluc), [@friendly](https://github.com/friendly), [@fweber144](https://github.com/fweber144), [@gaborcsardi](https://github.com/gaborcsardi), [@gadenbuie](https://github.com/gadenbuie), [@galachad](https://github.com/galachad), [@gangstR](https://github.com/gangstR), [@gavinsimpson](https://github.com/gavinsimpson), [@GeoBosh](https://github.com/GeoBosh), [@GFabien](https://github.com/GFabien), [@ggcostoya](https://github.com/ggcostoya), [@ghost](https://github.com/ghost), [@givison](https://github.com/givison), [@gladkia](https://github.com/gladkia), [@glin](https://github.com/glin), [@gmbecker](https://github.com/gmbecker), [@gravesti](https://github.com/gravesti), [@GregorDeCillia](https://github.com/GregorDeCillia), [@gregorypenn](https://github.com/gregorypenn), [@gsmolinski](https://github.com/gsmolinski), [@gsrohde](https://github.com/gsrohde), [@gungorMetehan](https://github.com/gungorMetehan), [@hadley](https://github.com/hadley), [@harshkrishna17](https://github.com/harshkrishna17), [@HenrikBengtsson](https://github.com/HenrikBengtsson), [@hfrick](https://github.com/hfrick), [@hrecht](https://github.com/hrecht), [@hsloot](https://github.com/hsloot), [@idavydov](https://github.com/idavydov), [@idmn](https://github.com/idmn), [@igordot](https://github.com/igordot), [@IndrajeetPatil](https://github.com/IndrajeetPatil), [@jabenninghoff](https://github.com/jabenninghoff), [@jack-davison](https://github.com/jack-davison), [@jangorecki](https://github.com/jangorecki), [@jayhesselberth](https://github.com/jayhesselberth), [@jennybc](https://github.com/jennybc), [@jeroen](https://github.com/jeroen), [@JerryWho](https://github.com/JerryWho), [@jhelvy](https://github.com/jhelvy), [@jmaspons](https://github.com/jmaspons), [@john-harrold](https://github.com/john-harrold), [@john-ioannides](https://github.com/john-ioannides), [@jonasmuench](https://github.com/jonasmuench), [@jonnybaik](https://github.com/jonnybaik), [@josherrickson](https://github.com/josherrickson), [@joshualerickson](https://github.com/joshualerickson), [@JosiahParry](https://github.com/JosiahParry), [@jplecavalier](https://github.com/jplecavalier), [@JSchoenbachler](https://github.com/JSchoenbachler), [@juliasilge](https://github.com/juliasilge), [@jwimberl](https://github.com/jwimberl), [@kalaschnik](https://github.com/kalaschnik), [@kevinushey](https://github.com/kevinushey), [@klmr](https://github.com/klmr), [@krlmlr](https://github.com/krlmlr), [@LDalby](https://github.com/LDalby), [@ldecicco-USGS](https://github.com/ldecicco-USGS), [@lhdjung](https://github.com/lhdjung), [@LiNk-NY](https://github.com/LiNk-NY), [@lionel-](https://github.com/lionel-), [@Liripo](https://github.com/Liripo), [@lorenzwalthert](https://github.com/lorenzwalthert), [@lschneiderbauer](https://github.com/lschneiderbauer), [@mabesa](https://github.com/mabesa), [@maelle](https://github.com/maelle), [@maRce10](https://github.com/maRce10), [@margotbligh](https://github.com/margotbligh), [@marine-ecologist](https://github.com/marine-ecologist), [@markfairbanks](https://github.com/markfairbanks), [@martinlaw](https://github.com/martinlaw), [@matt-dray](https://github.com/matt-dray), [@mattfidler](https://github.com/mattfidler), [@matthewjnield](https://github.com/matthewjnield), [@MattPM](https://github.com/MattPM), [@mccarthy-m-g](https://github.com/mccarthy-m-g), [@MEO265](https://github.com/MEO265), [@merliseclyde](https://github.com/merliseclyde), [@MichaelChirico](https://github.com/MichaelChirico), [@mikeblazanin](https://github.com/mikeblazanin), [@mikeroswell](https://github.com/mikeroswell), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@MLopez-Ibanez](https://github.com/MLopez-Ibanez), [@Moohan](https://github.com/Moohan), [@mpadge](https://github.com/mpadge), [@mrcaseb](https://github.com/mrcaseb), [@mrchypark](https://github.com/mrchypark), [@ms609](https://github.com/ms609), [@msberends](https://github.com/msberends), [@musvaage](https://github.com/musvaage), [@nanxstats](https://github.com/nanxstats), [@nathaneastwood](https://github.com/nathaneastwood), [@netique](https://github.com/netique), [@nicholascarey](https://github.com/nicholascarey), [@nicolerg](https://github.com/nicolerg), [@olivroy](https://github.com/olivroy), [@pearsonca](https://github.com/pearsonca), [@peterdesmet](https://github.com/peterdesmet), [@phauchamps](https://github.com/phauchamps), [@przmv](https://github.com/przmv), [@quantsch](https://github.com/quantsch), [@ramiromagno](https://github.com/ramiromagno), [@rcannood](https://github.com/rcannood), [@rempsyc](https://github.com/rempsyc), [@rgaiacs](https://github.com/rgaiacs), [@rich-iannone](https://github.com/rich-iannone), [@rickhelmus](https://github.com/rickhelmus), [@rmflight](https://github.com/rmflight), [@robmoss](https://github.com/robmoss), [@royfrancis](https://github.com/royfrancis), [@rsangole](https://github.com/rsangole), [@ryantibs](https://github.com/ryantibs), [@salim-b](https://github.com/salim-b), [@samuel-marsh](https://github.com/samuel-marsh), [@SebKrantz](https://github.com/SebKrantz), [@SESjo](https://github.com/SESjo), [@sgvignali](https://github.com/sgvignali), [@spsanderson](https://github.com/spsanderson), [@srfall](https://github.com/srfall), [@stefanoborini](https://github.com/stefanoborini), [@stephenashton-dhsc](https://github.com/stephenashton-dhsc), [@strengejacke](https://github.com/strengejacke), [@swsoyee](https://github.com/swsoyee), [@t-kalinowski](https://github.com/t-kalinowski), [@talgalili](https://github.com/talgalili), [@tanho63](https://github.com/tanho63), [@tedmoorman](https://github.com/tedmoorman), [@telphick](https://github.com/telphick), [@TFKentUSDA](https://github.com/TFKentUSDA), [@ThierryO](https://github.com/ThierryO), [@thisisnic](https://github.com/thisisnic), [@thomasp85](https://github.com/thomasp85), [@tomsing1](https://github.com/tomsing1), [@tony-aw](https://github.com/tony-aw), [@trevorld](https://github.com/trevorld), [@tylerlittlefield](https://github.com/tylerlittlefield), [@uriahf](https://github.com/uriahf), [@urswilke](https://github.com/urswilke), [@ValValetl](https://github.com/ValValetl), [@venpopov](https://github.com/venpopov), [@vincentvanhees](https://github.com/vincentvanhees), [@wangq13](https://github.com/wangq13), [@willgearty](https://github.com/willgearty), [@wviechtb](https://github.com/wviechtb), [@xuyiqing](https://github.com/xuyiqing), [@yjunechoe](https://github.com/yjunechoe), [@ynsec37](https://github.com/ynsec37), [@zeehio](https://github.com/zeehio), and [@zkamvar](https://github.com/zkamvar).

