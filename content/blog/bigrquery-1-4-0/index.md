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
rmd_hash: a3b4d5a0ed2f5592

---

We're gratified to announce the release of [bigrquery](https://bigrquery.r-dbi.org) 1.4.0. bigrquery makes it easy to work with data stored in [Google BigQuery](https://developers.google.com/bigquery/), a hosted database for big data.

You can install bigrquery from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"bigrquery"</span><span class='o'>)</span></code></pre>

</div>

This release is mostly to fix a bug in [`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html). We're also bumping the required version of the gargle package (<https://gargle.r-lib.org>), which handles everything around auth.

You can see a full list of changes in the [release notes](https://bigrquery.r-dbi.org/news/index.html).

## `bq_table_download()` bug fix

[`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html) is a good way to bring small-to-medium data out of BigQuery and into R, in the form of a tibble.

Under the hood, [`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html) retrieves the data in chunks, using several simultaneous connections to BigQuery servers, then parses and reassembles it. The use of concurrent requests has a substantial performance benefit, which we think is absolutely worth it. We ask for these chunks in terms of specific rows, but if the server determines the response will be too large, it sends fewer-than-expected rows (plus a token that can be used to pick up where things left off).

The bug is that [`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html) previously did not account for this and silently returned a tibble with the requested shape but, potentially, with lots of missing data. Many users and datasets are unaffected, because all chunks are received in their entirety. But the problem has been seen with datasets with many columns and where data complexity and sparsity mean that different slices of rows have a very different memory footprint.

[`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html) has been heavily refactored to make this phenomenon much less likely and to detect it when it happens:

-   The default value of `page_size` is no longer fixed and, instead, is determined empirically. Users are strongly recommended to let bigrquery select `page_size` automatically, unless there's a specific reason to do otherwise.
-   If one of our so-called chunks does not fit on a BigQuery page, [`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html) now throws an error with some advice about `page_size`.
-   The `max_results` argument has been deprecated in favor of `n_max`, which better reflects what we actually do with this number and is consistent with the `n_max` argument elsewhere, e.g., [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html).

Here's a look at the new and improved [`bq_table_download()`](https://bigrquery.r-dbi.org/reference/bq_table_download.html):

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://bigrquery.r-dbi.org'>bigrquery</a></span><span class='o'>)</span>

<span class='nv'>dat</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://bigrquery.r-dbi.org/reference/bq_table_download.html'>bq_table_download</a></span><span class='o'>(</span>
  <span class='s'>"bigquery-public-data.chicago_taxi_trips.taxi_trips"</span>,
  n_max <span class='o'>=</span> <span class='m'>100000</span>,
  bigint <span class='o'>=</span> <span class='s'>"integer64"</span>
<span class='o'>)</span>
<span class='c'>#&gt; Downloading first chunk of data.</span>
<span class='c'>#&gt; Received 29,221 rows in the first chunk.</span>
<span class='c'>#&gt; Downloading the remaining 70,779 rows in 4 chunks of (up to) 21,915 rows.</span>

<span class='nf'><a href='https://rdrr.io/r/utils/head.html'>tail</a></span><span class='o'>(</span><span class='nv'>dat</span><span class='o'>)</span>
<span class='c'>#&gt; # A tibble: 6 x 23</span>
<span class='c'>#&gt;   unique_key    taxi_id     trip_start_timesta… trip_end_timestamp  trip_seconds</span>
<span class='c'>#&gt;   &lt;chr&gt;         &lt;chr&gt;       &lt;dttm&gt;              &lt;dttm&gt;                   &lt;int64&gt;</span>
<span class='c'>#&gt; 1 1ad3f7df79d3… 0caf3d04eb… 2013-12-27 12:45:00 2013-12-27 13:00:00          840</span>
<span class='c'>#&gt; 2 3c982851afee… d7f7e8e4b0… 2014-01-25 19:45:00 2014-01-25 20:00:00          720</span>
<span class='c'>#&gt; 3 da7428c5329e… 46e168456e… 2014-01-06 17:45:00 2014-01-06 18:00:00          540</span>
<span class='c'>#&gt; 4 b0bb177ea839… 8d1222551a… 2014-01-08 11:45:00 2014-01-08 12:00:00          540</span>
<span class='c'>#&gt; 5 eee61e8e6c6d… ac39a2b21a… 2014-01-07 20:45:00 2014-01-07 21:00:00          540</span>
<span class='c'>#&gt; 6 4cc0ba56e6de… 25c1126afa… 2013-12-16 22:45:00 2013-12-16 22:45:00          420</span>
<span class='c'>#&gt; # … with 18 more variables: trip_miles &lt;dbl&gt;, pickup_census_tract &lt;int64&gt;,</span>
<span class='c'>#&gt; #   dropoff_census_tract &lt;int64&gt;, pickup_community_area &lt;int64&gt;,</span>
<span class='c'>#&gt; #   dropoff_community_area &lt;int64&gt;, fare &lt;dbl&gt;, tips &lt;dbl&gt;, tolls &lt;dbl&gt;,</span>
<span class='c'>#&gt; #   extras &lt;dbl&gt;, trip_total &lt;dbl&gt;, payment_type &lt;chr&gt;, company &lt;chr&gt;,</span>
<span class='c'>#&gt; #   pickup_latitude &lt;dbl&gt;, pickup_longitude &lt;dbl&gt;, pickup_location &lt;chr&gt;,</span>
<span class='c'>#&gt; #   dropoff_latitude &lt;dbl&gt;, dropoff_longitude &lt;dbl&gt;, dropoff_location &lt;chr&gt;</span></code></pre>

</div>

## Auth updates

If you are generally fairly passive about bigrquery auth, then you should just sit back and let things happen organically during usage. If you've used bigrquery before, you can expect to see some messages about cleaning and relocating the token cache when you first use v1.4.0. You can also expect to re-authenticate yourself with Google and re-authorize the "Tidyverse API Packages" to work with your files. This is all due to changes in gargle.

If your usage requires you to be more proactive about auth, read the [blog post for gargle's recent v1.2.0 release](https://www.tidyverse.org/blog/2021/07/gargle-1-2-0/). A key point is that we have rolled the built-in OAuth client, which is why those relying on it will need to re-auth.

**If the rolling of the tidyverse OAuth client is highly disruptive to your workflow, consider this a wake-up call** that you should be using your own OAuth client or, quite possibly, an entirely different method of auth. Our credential rolling will have no impact on users who use their own OAuth client or service account tokens.

gargle v1.2.0 offers support for a new method of auth that is especially relevant to bigrquery users: *workload identity federation*. This is a new (as of April 2021) keyless authentication mechanism offered by Google. Identity federation allows applications running on a non-Google Cloud platform, such as AWS, to access Google Cloud resources without using a conventional service account token, eliminating the security problem posed by long-lived, powerful service account credential files. Basically, instead of storing sensitive information in a file that must be managed with great care, the necessary secrets are obtained on-the-fly and exchanged for short-lived tokens, with very granular control over what actions are allowed. There is a cost, of course, which is that this auth method requires substantial configuration on both the GCP and AWS sides.

See the [gargle v1.2.0 blog post](https://www.tidyverse.org/blog/2021/07/gargle-1-2-0/) and the docs for [`gargle::credentials_external_account()`](https://gargle.r-lib.org/reference/credentials_external_account.html) to learn more.

## Acknowledgements

We'd like to thank everyone who has furthered the development of bigrquery, since the last major release (v1.0.0), through their contributions in issues and pull requests:

[@414theodore](https://github.com/414theodore), [@abalter](https://github.com/abalter), [@acvelozo](https://github.com/acvelozo), [@adhi-r](https://github.com/adhi-r), [@afalcioni](https://github.com/afalcioni), [@ahmohamed](https://github.com/ahmohamed), [@ajhindle](https://github.com/ajhindle), [@AlekseyBuzmakov](https://github.com/AlekseyBuzmakov), [@analyse9823](https://github.com/analyse9823), [@andirey](https://github.com/andirey), [@ArbenKqiku](https://github.com/ArbenKqiku), [@arvhug](https://github.com/arvhug), [@batpigandme](https://github.com/batpigandme), [@bbrewington](https://github.com/bbrewington), [@bhargavimoorthyrao](https://github.com/bhargavimoorthyrao), [@btrx-sreddy](https://github.com/btrx-sreddy), [@byapparov](https://github.com/byapparov), [@carbocation](https://github.com/carbocation), [@CartWill](https://github.com/CartWill), [@chrisherold](https://github.com/chrisherold), [@ChrisJohnsonUMG](https://github.com/ChrisJohnsonUMG), [@cpcgoogle](https://github.com/cpcgoogle), [@danny-molamola](https://github.com/danny-molamola), [@deflaux](https://github.com/deflaux), [@dmoimpact](https://github.com/dmoimpact), [@downloaderfan](https://github.com/downloaderfan), [@dsolito](https://github.com/dsolito), [@dujm](https://github.com/dujm), [@eamcvey](https://github.com/eamcvey), [@eddelbuettel](https://github.com/eddelbuettel), [@edgararuiz-zz](https://github.com/edgararuiz-zz), [@eduardodrc](https://github.com/eduardodrc), [@evandropp10](https://github.com/evandropp10), [@everron](https://github.com/everron), [@geotheory](https://github.com/geotheory), [@gikis1](https://github.com/gikis1), [@gjuggler](https://github.com/gjuggler), [@gkmuralimech](https://github.com/gkmuralimech), [@grantmcdermott](https://github.com/grantmcdermott), [@guillaumed90](https://github.com/guillaumed90), [@hadley](https://github.com/hadley), [@HarlanH](https://github.com/HarlanH), [@hlynurhallgrims](https://github.com/hlynurhallgrims), [@htappen](https://github.com/htappen), [@Iuiu1234](https://github.com/Iuiu1234), [@izzetagoren](https://github.com/izzetagoren), [@j450h1](https://github.com/j450h1), [@janejuenyang](https://github.com/janejuenyang), [@jayBana](https://github.com/jayBana), [@jberninger](https://github.com/jberninger), [@jcheng5](https://github.com/jcheng5), [@jennybc](https://github.com/jennybc), [@jimmyg3g](https://github.com/jimmyg3g), [@joetortorelli](https://github.com/joetortorelli), [@jordanwebb10](https://github.com/jordanwebb10), [@jpryda](https://github.com/jpryda), [@jrecasens](https://github.com/jrecasens), [@Ka2wei](https://github.com/Ka2wei), [@KarimZaoui](https://github.com/KarimZaoui), [@kesnalawrence](https://github.com/kesnalawrence), [@kevinwang09](https://github.com/kevinwang09), [@kkmann](https://github.com/kkmann), [@krlmlr](https://github.com/krlmlr), [@Kvit](https://github.com/Kvit), [@ldanai](https://github.com/ldanai), [@leemc-data-ed](https://github.com/leemc-data-ed), [@LukasWallrich](https://github.com/LukasWallrich), [@maelle](https://github.com/maelle), [@mapinas](https://github.com/mapinas), [@mauricioita](https://github.com/mauricioita), [@meystingray](https://github.com/meystingray), [@meztez](https://github.com/meztez), [@mr2dark](https://github.com/mr2dark), [@mwilson19](https://github.com/mwilson19), [@paleolimbot](https://github.com/paleolimbot), [@paulsendavidjay](https://github.com/paulsendavidjay), [@philbrierley](https://github.com/philbrierley), [@ras44](https://github.com/ras44), [@rasmusab](https://github.com/rasmusab), [@reliscu](https://github.com/reliscu), [@riccardopinosio](https://github.com/riccardopinosio), [@Saikri5hna](https://github.com/Saikri5hna), [@samudzi](https://github.com/samudzi), [@santic113](https://github.com/santic113), [@saptarshiguha](https://github.com/saptarshiguha), [@Schumzy](https://github.com/Schumzy), [@SeagleLiu](https://github.com/SeagleLiu), [@selcukakbas](https://github.com/selcukakbas), [@selesnow](https://github.com/selesnow), [@siroros](https://github.com/siroros), [@skydavis435](https://github.com/skydavis435), [@spgarbet](https://github.com/spgarbet), [@spiddy69](https://github.com/spiddy69), [@srkpratap](https://github.com/srkpratap), [@stelsemeyer](https://github.com/stelsemeyer), [@stevecondylios](https://github.com/stevecondylios), [@svmakarovv](https://github.com/svmakarovv), [@tchaithonov](https://github.com/tchaithonov), [@tdsmith](https://github.com/tdsmith), [@theclue](https://github.com/theclue), [@tinoater](https://github.com/tinoater), [@valentas-kurauskas](https://github.com/valentas-kurauskas), [@valentinumbach](https://github.com/valentinumbach), [@victorz-ca](https://github.com/victorz-ca), [@warnes](https://github.com/warnes), [@YuanyuanZhang1986](https://github.com/YuanyuanZhang1986), [@zacdav](https://github.com/zacdav), [@ZainRizvi](https://github.com/ZainRizvi), [@zerobytes](https://github.com/zerobytes), and [@zoews](https://github.com/zoews).

