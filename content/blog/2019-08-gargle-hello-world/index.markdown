---
title: gargle's debut on CRAN
slug: gargle-hello-world
author: Jenny Bryan
description: >
  gargle is now on CRAN.
date: '2019-08-20'
categories: [package]
tags:
  - gargle
  - r-lib
photo:
  url: https://flic.kr/p/oe2LJ1
  author: North Carolina Christian advocate (1894)
---



We're elated to (somewhat belatedly) announce the initial release of gargle on CRAN!

The gargle package (<https://gargle.r-lib.org>) is meant to take some of the pain out of working with Google APIs. It's mostly aimed at the maintainers of R packages that call Google APIs. If we're successful, users won't really notice gargle, they'll just feel like these packages got easier to work with and less idiosyncratic.
  
The timing of this post is motivated by the release of [googledrive](https://googledrive.tidyverse.org) v1.0.0. As of this version, googledrive gets all of its auth functionality (and more) from gargle. Although we did not blog about it, bigrquery also recently made the switch, with the release of v1.2.0.

If you are interested in the user-facing implications of using gargle, check out the [blog post announcing googledrive v1.0.0](https://www.tidyverse.org/articles/2019/08/googledrive-1-0-0/) and the [changelog for bigrquery v1.2.0](https://bigrquery.r-dbi.org/news/index.html#bigrquery-1-2-0).
  
## gargle

The [gargle package](https://gargle.r-lib.org) first appeared on CRAN in early June 2019 and has gotten a few small updates as we learn more by wiring it into packages. gargle is already used by:

  * [bigrquery](https://bigrquery.r-dbi.org) (>= v1.2.0)
  * [googledrive](https://googledrive.tidyverse.org) (>= v1.0.0)
  * [gmailr](https://gmailr.r-lib.org) (>= v1.0.0 *coming soon to CRAN*)
  * [googleAuthR](https://code.markedmondson.me/googleAuthR/) (*dev version*)
  * [googlesheets4](https://googlesheets4.tidyverse.org) *GitHub only*
  * [gcalendr](https://andrie.github.io/gcalendr/) *GitHub only*

gargle's current functionality falls into two domains, which a client package can adopt (or not) separately:

  * Auth: help users authenticate themselves with their Google identity and
    obtain a token that the wrapper package can use to make authorized requests.
  * Request preparation and response handling: check requests against the
    machine-readable [Discovery Documents](https://developers.google.com/discovery/v1/reference/apis)
    that describe Google APIs and process API responses, especially errors.
    
The long-term stretch goal is to do for R what the [official Google API Client Libraries](https://developers.google.com/api-client-library/) do for other languages, like Python and Java.

## Auth via gargle

Under the hood, gargle's main auth function is [`token_fetch()`](https://gargle.r-lib.org/articles/how-gargle-gets-tokens.html), which tries a series of different methods for obtaining a token. The intent is to make auth "just work" in a wide variety of contexts. This makes some flows newly available in the client packages, such as Application Default Credentials ([official Google docs](https://cloud.google.com/docs/authentication/production) and a [more readable 3rd party blog post](https://www.jhanley.com/google-cloud-application-default-credentials/)).

The main change that users will notice is that gargle implements its own way of storing user OAuth tokens between sessions. The [httr package](https://httr.r-lib.org), which gargle depends on, has historically used a local `.httr-oauth` file for this. In contrast, gargle encourages tokens to be stored *outside* the project, in a hidden directory at the user level, in a key-value store that incorporates the Google user's email. This makes it harder to accidentally push your tokens to the cloud, easier to use multiple Google identities, and easier to share tokens across projects and packages. Users will notice they need to re-auth and may want to track down and delete vestigial `.httr-oauth` files.

## Articles and docs

The release of gargle has provided an occasion to document several recurring workflows that can be tricky for useRs, which now work the same across multiple packages:

  * [Non-interactive auth](https://gargle.r-lib.org/articles/non-interactive-auth.html)
  * [Auth when using R in the browser](https://gargle.r-lib.org/articles/auth-from-web.html)
  * [Managing tokens securely](https://gargle.r-lib.org/articles/articles/managing-tokens-securely.html)
  * [How to get your own API credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)
  
gargle also offers a mechanism for client packages to build the documentation for their auth function from templates stored in gargle. This means that packages using a common design will also use the same words to describe it.
  
Another set of articles is aimed at package maintainers interested in delegating auth or request & response handling to gargle:

  * [How to use gargle for auth in a client package](https://gargle.r-lib.org/articles/gargle-auth-in-client-package.html)
  * [Request helper functions](https://gargle.r-lib.org/articles/request-helper-functions.html)
  
## Privacy policy for Google-related tidyverse/r-lib packages

Google is tightening the rules around various aspects of API access (see, e.g., [Project Strobe](https://www.blog.google/technology/safety-security/project-strobe/) and [Elevating user trust in our API ecosystem](https://cloud.google.com/blog/products/g-suite/elevating-user-trust-in-our-api-ecosystems)). I predict the main thing that useRs will notice is that more and more R packages and apps will require the user to get involved in the nitty gritty details of auth. Users will need to create their own Google Cloud Platform projects, obtain their own API keys, and their own OAuth client IDs and secrets. The overall rationale for Google's changes makes sense, but the way people use open source R packages is an awkward fit with their recommended auth solutions. It's becoming more difficult for package developers to make auth feel like it "just works".

The Google-wrapping packages maintained by the tidyverse / r-lib team are now governed by a shared [Privacy Policy](https://www.tidyverse.org/google_privacy_policy/). This is linked from each package and also from the consent screen whenever auth is facilitated through our OAuth client.

## Some gargle history

I find gargle's origin story find very satisfying. I suspect that Hadley Wickham's bigrquery (first on CRAN January 2015) has shaped the basic design for how most R packages handle Google auth, directly or indirectly. I can certainly say that Joanna Zhao and I consulted it when developing googlesheets (first on CRAN July 2015). I know that Mark Edmondson was influenced, in turn, by googlesheets, when he developed googleAuthR (first on CRAN August 2015), used in his [suite of packages](https://code.markedmondson.me/r-packages/). By the time Lucy D'Agostino McGowan and I created googledrive (first on CRAN August 2017), I'd developed some strong opinions about how to modify httr's default behaviour for work with Google APIs. I was also working with Hadley Wickham at RStudio by that point and Lucy and I benefited from his design advice. In May-ish 2017, leading up to [rOpenSci's 2017 Unconf](https://unconf17.ropensci.org), Craig Citro [opened an issue](https://github.com/ropensci/unconf17/issues/85) to generate discussion about how to de-duplicate even more API pain, especially for Google APIs. He has a wealth of experience from his role in shaping the [official Python client](https://developers.google.com/api-client-library/) and he made the initial commits that laid the foundation for `gargle::token_fetch()`.

Starting from a common origin (bigrquery), all these people and packages have explored different aspects of this problem space and have developed various solutions. gargle represents the distillation of a lot of hard-won experience and a promising space for future consolidation.

## Thanks!

Thanks to all those who have helped get gargle to its first release:

[&#x0040;andrie](https://github.com/andrie), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;byapparov](https://github.com/byapparov), [&#x0040;craigcitro](https://github.com/craigcitro), [&#x0040;dlebech](https://github.com/dlebech), [&#x0040;hadley](https://github.com/hadley), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jonthegeek](https://github.com/jonthegeek), [&#x0040;MarkEdmondson1234](https://github.com/MarkEdmondson1234), [&#x0040;wlongabaugh](https://github.com/wlongabaugh), and [&#x0040;ZainRizvi](https://github.com/ZainRizvi)
