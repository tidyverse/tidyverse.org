---
output: hugodown::hugo_document

slug: bigrquery-1-4-0
title: bigrquery 1.4.0
date: 2021-08-04
author: Jenny Bryan
description: >
    bigrquery 1.4.0 fixes a bug in `bq_table_download()`.

photo:
  url: https://unsplash.com/photos/uzw4MvfG5ps
  author: Henry & Co.

categories: [package] 
tags: [bigrquery, gargle, dbplyr, databases]
rmd_hash: ee905c9b8e515192

---

We're gratified to announce the release of [bigrquery](https://bigrquery.r-dbi.org) 1.4.0. bigrquery makes it easy to work with data stored in [Google BigQuery](https://developers.google.com/bigquery/), a hosted database for big data.

You can install bigrquery from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"bigrquery"</span><span class='o'>)</span></code></pre>

</div>

This release is mostly to fix a bug in [`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html). We're also bumping the required version of the gargle package (<https://gargle.r-lib.org>), which handles everything around auth.

You can see a full list of changes in the [release notes](https://bigrquery.r-dbi.org/news/index.html).

## `bq_table_download()` bug fix

*to write*

## Auth updates

If you are generally fairly passive about bigrquery auth, then you should just sit back and let things happen organically during usage. If you've used bigrquery before, you can expect to see some messages about cleaning and relocating the token cache when you first use v1.4.0. You can also expect to re-authenticate yourself with Google and re-authorize the "Tidyverse API Packages" to work with your files. This is all due to changes in gargle.

If your usage requires you to be more proactive about auth, read the [blog post for gargle's recent v1.2.0 release](https://www.tidyverse.org/blog/2021/07/gargle-1-2-0/). A key point is that we have rolled the built-in OAuth client, which is why those relying on it will need to re-auth.

**If the rolling of the tidyverse OAuth client is highly disruptive to your workflow, consider this a wake-up call** that you should be using your own OAuth client or, quite possibly, an entirely different method of auth. Our credential rolling will have no impact on users who use their own OAuth client or service account tokens.

gargle v1.2.0 offers support for a new method of auth that is especially relevant to bigrquery users: *workload identity federation*. This is a new (as of April 2021) keyless authentication mechanism offered by Google. Identity federation allows applications running on a non-Google Cloud platform, such as AWS, to access Google Cloud resources without using a conventional service account token, eliminating the security problem posed by long-lived, powerful service account credential files. Basically, instead of storing sensitive information in a file that must be managed with great care, the necessary secrets are obtained on-the-fly and exchanged for short-lived tokens, with very granular control over what actions are allowed. There is a cost, of course, which is that this auth method requires substantial configuration on both the GCP and AWS sides.

See the [gargle v1.2.0 blog post](https://www.tidyverse.org/blog/2021/07/gargle-1-2-0/) and the docs for [`gargle::credentials_external_account()`](https://gargle.r-lib.org/reference/credentials_external_account.html) to learn more.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://bigrquery.r-dbi.org'>bigrquery</a></span><span class='o'>)</span></code></pre>

</div>

## Acknowledgements

We'd like to thank everyone who has furthered the development of bigrquery, since the last major release (v1.0.0), through their contributions in issues and pull requests:

[@414theodore](https://github.com/414theodore), [@abalter](https://github.com/abalter), [@acvelozo](https://github.com/acvelozo), [@adhi-r](https://github.com/adhi-r), [@afalcioni](https://github.com/afalcioni), [@ahmohamed](https://github.com/ahmohamed), [@ajhindle](https://github.com/ajhindle), [@AlekseyBuzmakov](https://github.com/AlekseyBuzmakov), [@analyse9823](https://github.com/analyse9823), [@andirey](https://github.com/andirey), [@ArbenKqiku](https://github.com/ArbenKqiku), [@arvhug](https://github.com/arvhug), [@batpigandme](https://github.com/batpigandme), [@bbrewington](https://github.com/bbrewington), [@bhargavimoorthyrao](https://github.com/bhargavimoorthyrao), [@btrx-sreddy](https://github.com/btrx-sreddy), [@byapparov](https://github.com/byapparov), [@carbocation](https://github.com/carbocation), [@CartWill](https://github.com/CartWill), [@chrisherold](https://github.com/chrisherold), [@ChrisJohnsonUMG](https://github.com/ChrisJohnsonUMG), [@cpcgoogle](https://github.com/cpcgoogle), [@danny-molamola](https://github.com/danny-molamola), [@deflaux](https://github.com/deflaux), [@dmoimpact](https://github.com/dmoimpact), [@downloaderfan](https://github.com/downloaderfan), [@dsolito](https://github.com/dsolito), [@dujm](https://github.com/dujm), [@eamcvey](https://github.com/eamcvey), [@eddelbuettel](https://github.com/eddelbuettel), [@edgararuiz-zz](https://github.com/edgararuiz-zz), [@eduardodrc](https://github.com/eduardodrc), [@evandropp10](https://github.com/evandropp10), [@everron](https://github.com/everron), [@geotheory](https://github.com/geotheory), [@gikis1](https://github.com/gikis1), [@gjuggler](https://github.com/gjuggler), [@gkmuralimech](https://github.com/gkmuralimech), [@grantmcdermott](https://github.com/grantmcdermott), [@guillaumed90](https://github.com/guillaumed90), [@hadley](https://github.com/hadley), [@HarlanH](https://github.com/HarlanH), [@hlynurhallgrims](https://github.com/hlynurhallgrims), [@htappen](https://github.com/htappen), [@Iuiu1234](https://github.com/Iuiu1234), [@izzetagoren](https://github.com/izzetagoren), [@j450h1](https://github.com/j450h1), [@janejuenyang](https://github.com/janejuenyang), [@jayBana](https://github.com/jayBana), [@jberninger](https://github.com/jberninger), [@jcheng5](https://github.com/jcheng5), [@jennybc](https://github.com/jennybc), [@jimmyg3g](https://github.com/jimmyg3g), [@joetortorelli](https://github.com/joetortorelli), [@jordanwebb10](https://github.com/jordanwebb10), [@jpryda](https://github.com/jpryda), [@jrecasens](https://github.com/jrecasens), [@Ka2wei](https://github.com/Ka2wei), [@KarimZaoui](https://github.com/KarimZaoui), [@kesnalawrence](https://github.com/kesnalawrence), [@kevinwang09](https://github.com/kevinwang09), [@kkmann](https://github.com/kkmann), [@krlmlr](https://github.com/krlmlr), [@Kvit](https://github.com/Kvit), [@ldanai](https://github.com/ldanai), [@leemc-data-ed](https://github.com/leemc-data-ed), [@LukasWallrich](https://github.com/LukasWallrich), [@maelle](https://github.com/maelle), [@mapinas](https://github.com/mapinas), [@mauricioita](https://github.com/mauricioita), [@meystingray](https://github.com/meystingray), [@meztez](https://github.com/meztez), [@mr2dark](https://github.com/mr2dark), [@mwilson19](https://github.com/mwilson19), [@paleolimbot](https://github.com/paleolimbot), [@paulsendavidjay](https://github.com/paulsendavidjay), [@philbrierley](https://github.com/philbrierley), [@ras44](https://github.com/ras44), [@rasmusab](https://github.com/rasmusab), [@reliscu](https://github.com/reliscu), [@riccardopinosio](https://github.com/riccardopinosio), [@Saikri5hna](https://github.com/Saikri5hna), [@samudzi](https://github.com/samudzi), [@santic113](https://github.com/santic113), [@saptarshiguha](https://github.com/saptarshiguha), [@Schumzy](https://github.com/Schumzy), [@SeagleLiu](https://github.com/SeagleLiu), [@selcukakbas](https://github.com/selcukakbas), [@selesnow](https://github.com/selesnow), [@siroros](https://github.com/siroros), [@skydavis435](https://github.com/skydavis435), [@spgarbet](https://github.com/spgarbet), [@spiddy69](https://github.com/spiddy69), [@srkpratap](https://github.com/srkpratap), [@stelsemeyer](https://github.com/stelsemeyer), [@stevecondylios](https://github.com/stevecondylios), [@svmakarovv](https://github.com/svmakarovv), [@tchaithonov](https://github.com/tchaithonov), [@tdsmith](https://github.com/tdsmith), [@theclue](https://github.com/theclue), [@tinoater](https://github.com/tinoater), [@valentas-kurauskas](https://github.com/valentas-kurauskas), [@valentinumbach](https://github.com/valentinumbach), [@victorz-ca](https://github.com/victorz-ca), [@warnes](https://github.com/warnes), [@YuanyuanZhang1986](https://github.com/YuanyuanZhang1986), [@zacdav](https://github.com/zacdav), [@ZainRizvi](https://github.com/ZainRizvi), [@zerobytes](https://github.com/zerobytes), and [@zoews](https://github.com/zoews).

