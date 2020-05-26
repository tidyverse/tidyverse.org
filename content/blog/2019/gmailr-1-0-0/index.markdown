---
title: gmailr v1.0.0
slug: gmailr-1-0-0
author: Jim Hester
description: >
  gmailr v1.0.0 is on CRAN.
date: '2019-08-26'
categories: [package]
tags:
  - gmailr
  - r-lib
photo:
  url: https://unsplash.com/photos/fb7yNPbT0l8
  author: Mathyas Kurmann
---



## Introduction

gmailr v1.0.0 (<https://gmailr.r-lib.org>) is now on CRAN!

gmailr wraps the [Gmail REST API v3](https://developers.google.com/gmail/). It provides a variety of funcitons to query your mailbox and create and send new email messages. You can retrieve, create and send emails and drafts, manage email labels, trash and untrash emails, and delete messages, drafts and threads. 

The tidyverse team uses gmailr most often to send emails to the maintainers of packages which depend on our packages, to inform them when a new package release is imminent or if any of our changes require action on their part.

Install gmailr with:


```r
install.packages("gmailr")
```

The release of version 1.0.0 marks three events:

  * There are changes in the auth interface that are not backwards compatible.
  * The built-in application has been removed.
  * The functions have all been prefixed with `gm_()`, to avoid name conflicts with functions in other packages (including the base package).
  
There is also new functionality that make writing emails with non-ASCII characters more robust, and improved documentation. See the [changelog](http://gmailr.r-lib.org/news/index.html#gmailr-1-0-0) for the full details on this release.

## Auth from gargle

gmailr's auth functionality now comes from the [gargle package](https://gargle.r-lib.org), which provides R infrastructure to work with Google APIs, in general. We've just [blogged about gargle's initial release](https://www.tidyverse.org/articles/2019/08/gargle-hello-world/), so check out that post for more details.

We're adopting gargle for auth in several other packages, such as [bigrquery](https://bigrquery.r-dbi.org) (>= v1.2.0), [googledrive](https://googledrive.r-lib.org)  (>= v1.0.0), and [googlesheets4](https://googlesheets4.tidyverse.org) (currently GitHub-only, successor of googlesheets). This makes new token flows available in these packages, such as [Application Default Credentials](https://www.jhanley.com/google-cloud-application-default-credentials/), and makes auth less idiosyncratic.

### Auth changes the typical user will notice

The functions used for authentication have changed. Use `gm_auth_configure()` to configure your application and then `gm_auth()` to actually authenticate your user with the application.

> OAuth2 tokens are now cached at the user level, by default, instead of in `.httr-oauth` in the current project. We will ask if it's OK to create a new folder to hold your OAuth tokens. We recommend that you delete any vestigial `.httr-oauth` files lying around your gmailr projects and re-authorize gmailr, i.e. get a new token, stored in the new way.

The new strategy makes it harder to accidentally push your tokens to the cloud, easier to use multiple Google identities, and easier to share tokens across projects and packages.

Overall, gmailr has gotten more careful about getting your permission to use a cached token. See the gargle vignette [Non-interactive auth](https://gargle.r-lib.org/articles/non-interactive-auth.html) to learn how to prevent attempts to interact with you, especially the section ["Arrange for an oauth token to be re-discovered"](https://gargle.r-lib.org/articles/non-interactive-auth.html#arrange-for-an-oauth-token-to-be-re-discovered).

gmailr also removes the built-in OAuth "app". This was nessesary to comply with [stricter rules and enforcement](https://developers.google.com/terms/api-services-user-data-policy#additional-requirements-for-specific-api-scopes) by google for Gmail API applications. It was not possible to comply with these rules and continue to have a default application embedded in gmailr. See the [setup](http://gmailr.r-lib.org/#setup) section of the readme for how to create a new project and authenticate it with only a few steps. gmailr operates under the same [Privacy Policy](https://www.tidyverse.org/google_privacy_policy/) as other tidyverse API packages, the most relevant bit for users is 'The packages only communicate with Google APIs. No user data is shared with the owners of the Tidyverse API Packages, RStudio, or any other servers.'

## Preventing name conflicts

Historically functions in gmailr did not attempt to avoid conflicts, including common functions in the base package like `body()` and `message()`. It was assumed users would use namespaced calls, e.g. `gmailr::body()` if there were issues. However this inadvertantly causes confusing errors for users. All of the functions are now prefixed with `gm_()` to solve this conflict. This also increases function discoverability via auto-complete.

The un-exported function `gmailr:::gm_convert_file()` converts existing scripts to use the new functions. Use `gmailr:::gm_convert_file(list.files(pattern = "[.]R$", recursive = TRUE))` to convert all of your R scripts in the current directory and below. (Be sure to inspect the changes manually!)

## Shared workflows 

The shared use of gargle allows us to create centralized articles for several workflows that can be tricky for users:

  * [Non-interactive auth](https://gargle.r-lib.org/articles/non-interactive-auth.html)
  * [Auth when using R in the browser](https://gargle.r-lib.org/articles/auth-from-web.html)
  * [Managing tokens securely](https://gargle.r-lib.org/articles/articles/managing-tokens-securely.html)
  * [How to get your own API credentials](https://gargle.r-lib.org/articles/get-api-credentials.html)

## Thanks!

Thanks to the 58 people who contributed issues, code, and comments to this release!

[&#x0040;abhishek1608](https://github.com/abhishek1608), [&#x0040;alansz](https://github.com/alansz), [&#x0040;alkashef](https://github.com/alkashef), [&#x0040;ascheinwald](https://github.com/ascheinwald), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;Btibert3](https://github.com/Btibert3), [&#x0040;choisy](https://github.com/choisy), [&#x0040;coatless](https://github.com/coatless), [&#x0040;csalgads](https://github.com/csalgads), [&#x0040;ctbrown](https://github.com/ctbrown), [&#x0040;eluerken](https://github.com/eluerken), [&#x0040;EricGoldsmith](https://github.com/EricGoldsmith), [&#x0040;fiol92](https://github.com/fiol92), [&#x0040;grepinsight](https://github.com/grepinsight), [&#x0040;hadley](https://github.com/hadley), [&#x0040;Hellengeremias](https://github.com/Hellengeremias), [&#x0040;hopeful-coder](https://github.com/hopeful-coder), [&#x0040;howard-gu](https://github.com/howard-gu), [&#x0040;jamespmcguire](https://github.com/jamespmcguire), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jim0wheel](https://github.com/jim0wheel), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jlegewie](https://github.com/jlegewie), [&#x0040;jnolis](https://github.com/jnolis), [&#x0040;josibake](https://github.com/josibake), [&#x0040;kazuya030](https://github.com/kazuya030), [&#x0040;kevin-dyrland](https://github.com/kevin-dyrland), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;lawremi](https://github.com/lawremi), [&#x0040;lmmx](https://github.com/lmmx), [&#x0040;lwasser](https://github.com/lwasser), [&#x0040;maaraaj](https://github.com/maaraaj), [&#x0040;marco-vene](https://github.com/marco-vene), [&#x0040;martijnvv](https://github.com/martijnvv), [&#x0040;matt-negrin](https://github.com/matt-negrin), [&#x0040;mattbaggott](https://github.com/mattbaggott), [&#x0040;msgoussi](https://github.com/msgoussi), [&#x0040;msrodrigues](https://github.com/msrodrigues), [&#x0040;MST2803](https://github.com/MST2803), [&#x0040;nicocriscuolo](https://github.com/nicocriscuolo), [&#x0040;obarisk](https://github.com/obarisk), [&#x0040;paddytobias](https://github.com/paddytobias), [&#x0040;prithajnath](https://github.com/prithajnath), [&#x0040;RockScience](https://github.com/RockScience), [&#x0040;RozennGZ](https://github.com/RozennGZ), [&#x0040;rpietro](https://github.com/rpietro), [&#x0040;scottgrimes](https://github.com/scottgrimes), [&#x0040;SimonCoulombe](https://github.com/SimonCoulombe), [&#x0040;slomanl1](https://github.com/slomanl1), [&#x0040;songyurita](https://github.com/songyurita), [&#x0040;sumxf](https://github.com/sumxf), [&#x0040;TheKashe](https://github.com/TheKashe), [&#x0040;tingmar](https://github.com/tingmar), [&#x0040;tmamiya](https://github.com/tmamiya), [&#x0040;Vestaxis](https://github.com/Vestaxis), [&#x0040;vikram-rawat](https://github.com/vikram-rawat), [&#x0040;williamgunn](https://github.com/williamgunn), and [&#x0040;xhudik](https://github.com/xhudik)
