---
title: 'httr 1.4.0'
slug: httr-1-4-0
description: > 
  httr 1.4.0 is now on CRAN!
date: '2018-12-18'
author: Mara Averick
photo:
  url: https://unsplash.com/photos/0JhaVZUowWU
  author: Chris Yang
categories:
  - package
tags:
  - httr
  - r-lib
---

We're well pleased to announce the release of [httr](https://httr.r-lib.org/) 1.4.0. The goal of httr is to provide a wrapper for the [curl](https://CRAN.R-project.org/package=curl) package, customised to the demands of modern web APIs.

The [httr 1.4.0](https://httr.r-lib.org/news/index.html#httr-1-4-0) release includes improved flexibility for [OAuth 2.0](https://oauth.net/2/), new and updated [demos](https://github.com/r-lib/httr/tree/master/demo), and several minor changes and improvements — the full details of which can be found in the [changelog](https://github.com/r-lib/httr/blob/master/NEWS.md#httr-140).

## OAuth 2.0 improvements

OAuth 2.0 has been made somewhat more flexible in order to support more websites. [`init_oauth2.0()`](https://httr.r-lib.org/reference/init_oauth2.0.html) now passes `use_basic_auth` onward, enabling basic authentication for OAuth 2.0. [`oauth2.0_token()`](https://httr.r-lib.org/reference/oauth2.0_token.html) and `init_oauth2.0()` have gained two new arguments:

  * `oob_value` specifies the value to use for the `redirect_uri` parameter when retrieving an authorization URL, necessary when using "out-of-band" (oob) configuration.  
  * `query_authorize_extra` makes it possible to add extra query parameters to the authorization URL, as is required by some APIs.  

Scopes are now de-duplicated, sorted and stripped of names before being hashed for on-disk token retrieval. This eliminates a source of hash mismatch that could cause new tokens to be requested, even when existing tokens had the necessary scope.

## Demo updates

Thanks to [Christophe Dervieux](https://github.com/cderv), a new [demo](https://github.com/r-lib/httr/blob/master/demo/oauth1-nounproject.r) for [OAuth 1.0a's one-legged](http://oauthbible.com/#oauth-10a-one-legged) authentication mechanism has been added, using the [Noun Project](https://thenounproject.com/) API. 

The [Faceboook demo](https://github.com/r-lib/httr/blob/master/demo/oauth2-facebook.r) now uses [device flow](https://developers.facebook.com/docs/facebook-login/for-devices/). This means that you can continue to use the Facebook API from R under their new security policy.

The [Vimeo demo](https://github.com/r-lib/httr/blob/master/demo/oauth2-vimeo.r) has been updated to use OAuth 2.0. 

## Acknowledgements

Thank you to the 69 contributors who made this release possible:
[&#x0040;aazaff](https://github.com/aazaff), [&#x0040;alex-hioperator](https://github.com/alex-hioperator), [&#x0040;barryrowlingson](https://github.com/barryrowlingson), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;bradyte](https://github.com/bradyte), [&#x0040;braggbear](https://github.com/braggbear), [&#x0040;brennanpincardiff](https://github.com/brennanpincardiff), [&#x0040;cameronbracken](https://github.com/cameronbracken), [&#x0040;cderv](https://github.com/cderv), [&#x0040;ChrisMuir](https://github.com/ChrisMuir), [&#x0040;cosmomeese](https://github.com/cosmomeese), [&#x0040;cranknasty](https://github.com/cranknasty), [&#x0040;cschroed-usgs](https://github.com/cschroed-usgs), [&#x0040;cstawitz](https://github.com/cstawitz), [&#x0040;ctrombley](https://github.com/ctrombley), [&#x0040;dcldmartin](https://github.com/dcldmartin), [&#x0040;dfv-ms](https://github.com/dfv-ms), [&#x0040;dkulp2](https://github.com/dkulp2), [&#x0040;drewabbot](https://github.com/drewabbot), [&#x0040;EOneita](https://github.com/EOneita), [&#x0040;ErezLo](https://github.com/ErezLo), [&#x0040;FelixMailoa](https://github.com/FelixMailoa), [&#x0040;giuseppec](https://github.com/giuseppec), [&#x0040;hadley](https://github.com/hadley), [&#x0040;Hong-Revo](https://github.com/Hong-Revo), [&#x0040;infinitetrial](https://github.com/infinitetrial), [&#x0040;Isaacsh](https://github.com/Isaacsh), [&#x0040;j-Rinehart](https://github.com/j-Rinehart), [&#x0040;JacquesBonet](https://github.com/JacquesBonet), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jguerrero77](https://github.com/jguerrero77), [&#x0040;JhossePaul](https://github.com/JhossePaul), [&#x0040;jlegewie](https://github.com/jlegewie), [&#x0040;jmwerner](https://github.com/jmwerner), [&#x0040;jthomp1818](https://github.com/jthomp1818), [&#x0040;KaranKhullar](https://github.com/KaranKhullar), [&#x0040;karigunnarsson](https://github.com/karigunnarsson), [&#x0040;klarakaleb](https://github.com/klarakaleb), [&#x0040;kokomoo](https://github.com/kokomoo), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;l-ts](https://github.com/l-ts), [&#x0040;leonardo-murano](https://github.com/leonardo-murano), [&#x0040;maalsol](https://github.com/maalsol), [&#x0040;mmuurr](https://github.com/mmuurr), [&#x0040;moloscripts](https://github.com/moloscripts), [&#x0040;mtmorgan](https://github.com/mtmorgan), [&#x0040;mvkorpel](https://github.com/mvkorpel), [&#x0040;Nosferican](https://github.com/Nosferican), [&#x0040;paulgarnes](https://github.com/paulgarnes), [&#x0040;peterdesmet](https://github.com/peterdesmet), [&#x0040;peterhartman](https://github.com/peterhartman), [&#x0040;picousse](https://github.com/picousse), [&#x0040;pohzipohzi](https://github.com/pohzipohzi), [&#x0040;porfila](https://github.com/porfila), [&#x0040;potterzot](https://github.com/potterzot), [&#x0040;ramnov](https://github.com/ramnov), [&#x0040;sajukassim](https://github.com/sajukassim), [&#x0040;sasajuratovic](https://github.com/sasajuratovic), [&#x0040;Sb9309](https://github.com/Sb9309), [&#x0040;shrektan](https://github.com/shrektan), [&#x0040;skirmer](https://github.com/skirmer), [&#x0040;stefanfritsch](https://github.com/stefanfritsch), [&#x0040;StevenMMortimer](https://github.com/StevenMMortimer), [&#x0040;swanderz](https://github.com/swanderz), [&#x0040;swood-ecology](https://github.com/swood-ecology), [&#x0040;tjpalanca](https://github.com/tjpalanca), [&#x0040;TuanTran07](https://github.com/TuanTran07), [&#x0040;viddagrava](https://github.com/viddagrava), and [&#x0040;wsphd](https://github.com/wsphd).
