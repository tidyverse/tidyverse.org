---
output: hugodown::hugo_document

slug: gmailr-2-0-0
title: gmailr 2.0.0
date: 2023-06-29
author: Jennifer Bryan
description: >
    gmailr 2.0.0 streamlines the auth process and makes it easier to use gmailr
    in a cloud or deployed context.

photo:
  url: https://unsplash.com/photos/VybzKEUMhbw
  author: Hiroshi Kimura

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package] 
tags: [gmailr, gargle]
rmd_hash: d4b043eeb04d9649

---

We're chuffed to announce the release of [gmailr](https://gmailr.r-lib.org/) 2.0.0. gmailr exposes the [Gmail API](https://developers.google.com/gmail/api/guides) from R.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"gmailr"</span><span class='o'>)</span></span></code></pre>

</div>

The main goal of version 2.0.0 is to improve the ergonomics around auth. There is less need for fussy code around configuring an OAuth client and it's easier to use gmailr in a non-interactive or deployed setting. There is also a major advance in the process of replacing legacy functions with versions that have a `gm_` prefix. The legacy functions still exist, but are now hard deprecated. Finally, gmailr no longer re-exports `%>%`, the magrittr pipe, now that we have `|>` in base R.

You can see a full list of changes in the [release notes](https://github.com/r-lib/gmailr/releases/tag/v2.0.0).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://gmailr.r-lib.org'>gmailr</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; Attaching package: 'gmailr'</span></span>
<span></span><span><span class='c'>#&gt; The following object is masked from 'package:utils':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     history</span></span>
<span></span><span><span class='c'>#&gt; The following objects are masked from 'package:base':</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt;     body, date, labels, message</span></span>
<span></span></code></pre>

</div>

😬 *Ouch! These name collisions are **exactly** why gmailr added a universal `gm_` prefix to all of its functions starting in v1.0.0. One day in the not-too-distant future we can remove the troublesome legacy functions.*

## OAuth client

The Gmail API is more challenging to wrap, in terms of auth, than the APIs for Sheets, Drive, or BigQuery. That's because the scopes (think: "permissions") needed for the Gmail API are [regarded as extremely sensitive](https://developers.google.com/gmail/api/auth/scopes#scopes), as well they should be. If a bad actor gains the ability to read and send email as you, that is considerably more damaging than them being able to modify your spreadsheets (which is also bad, to be sure, but considerably less bad). Email is particularly important, because most other services allow you to reset your password via email; if someone gets access to your email, they can quickly use that to access every other service you have a log in for.

The heightened security around the Gmail API means that a wrapper package like gmailr can't make auth "just work" as easily we can in other packages, such as googledrive. In particular, R users who want to use gmailr absolutely must provide their own *OAuth client*. In other packages, we can make this optional.

gmailr v2.0.0 includes new features and documentation to reduce the pain around the OAuth client as much as possible:

-   [Set up an OAuth client](https://gmailr.r-lib.org/articles/oauth-client.html) is a new article with detailed instructions for creating and configuring an OAuth client. You might even say this provides an excruciating level of detail, but this process has proven to be tricky for many users.

-   There is now a default location for the JSON file that represents the OAuth client. It's the location returned by `rappdirs::user_data_dir("gmailr")`. If you put the JSON file there, gmailr will find it automagically.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>rappdirs</span><span class='nf'>::</span><span class='nf'><a href='https://rappdirs.r-lib.org/reference/user_data_dir.html'>user_data_dir</a></span><span class='o'>(</span><span class='s'>"gmailr"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
    <span>  <span class='nf'><a href='https://rdrr.io/r/base/list.files.html'>list.files</a></span><span class='o'>(</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "client_secret_xxx-yyy.apps.googleusercontent.com.json"</span></span>
    <span></span>
    <span><span class='nf'><a href='https://gmailr.r-lib.org/reference/gmailr-configuration.html'>gm_default_oauth_client</a></span><span class='o'>(</span><span class='o'>)</span></span>
    <span><span class='c'>#&gt; [1] "/Users/jenny/Library/Application Support/gmailr/client_secret_xxx-yyy.apps.googleusercontent.com.json"</span></span></code></pre>

    </div>

    [`gm_default_oauth_client()`](https://gmailr.r-lib.org/reference/gmailr-configuration.html) is the new function that implements this new feature as well as pre-existing support for providing this path via an environment variable.

-   If the OAuth client is configured for auto-discovery, it is no longer necessary to call [`gm_auth_configure()`](https://gmailr.r-lib.org/reference/gm_auth_configure.html) explicitly. That is taken care of internally, inside [`gm_auth()`](https://gmailr.r-lib.org/reference/gm_auth.html).

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'>> library(gmailr)
    > 
    > # 😲 OMG no more need to call gm_auth_configure() here! 🎉
    > 
    > gm_threads()
    The gmailr package is requesting access to your Google account.
    Enter '1' to start a new auth process or select a pre-authorized account.
    1: Send me to the browser for a new auth process.
    2: jenny@posit.co
    Selection: 2
    </code></pre>

    </div>

-   Conversely, if you happen to be providing an explicit user or service account token, `gm_auth(token =)` and `gm_auth(path =, subject =)`[^1] no longer error if the OAuth client is not configured.

## Auth in a deployed or other non-interactive setting

The Gmail API is primarily intended for use on behalf of a regular Google user account. The gmailr package is designed to guide an interactive R user through a process in which they authenticate themselves to Google and authorize Gmail activities initiated from R. This is sometimes referred to as the "OAuth dance".[^2]

But what about settings where there is no interactive user sitting around to do this dance, i.e. when gmailr-using code is deployed to a remote server or otherwise runs unattended? For most Google APIs, the standard advice is "use a service account". But the Gmail API is special. To use a service account with the Gmail API basically requires that the service account has been delegated domain-wide authority. This is tricky for at least two reasons. First, this is only possible within a Google Workspace, i.e. it's not available to personal Google accounts. Second, most Google Workspace admins will refuse to do this, for security reasons.

Therefore, if you want to deploy a data product that uses gmailr, it's extremely likely that you really do need to use a user token. This workflow has gotten dramatically easier in gmailr v2.0.0:

-   [Deploy a token](https://gmailr.r-lib.org/articles/deploy-a-token.html) is a new article describing how to capture a token interactively, then use it later, non-interactively.
-   [`gm_token_write()`](https://gmailr.r-lib.org/reference/gm_token_write.html) + [`gm_token_read()`](https://gmailr.r-lib.org/reference/gm_token_write.html) is a new matched pair of functions that facilitate writing an obfuscated token to disk then reloading that token in a deployed data product or in CI.
-   gmailr ships with example code that uses this technique in a small Shiny app that sends email from a specific user account. See the contents of `system.file("deployed-token-demo", package = "gmailr")`.

The heart of this approach is to first capture a token in an interactive session:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://gmailr.r-lib.org/reference/gm_auth.html'>gm_auth</a></span><span class='o'>(</span><span class='s'>"user@example.com"</span>, cache <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></span>
<span><span class='c'># interactive OAuth dance in the browser happens HERE</span></span>
<span><span class='nf'><a href='https://gmailr.r-lib.org/reference/gm_token_write.html'>gm_token_write</a></span><span class='o'>(</span></span>
<span>  path <span class='o'>=</span> <span class='s'>".secrets/gmailr-token.rds"</span>,</span>
<span>  key <span class='o'>=</span> <span class='s'>"SUPER_SECRET_ENCRYPTION_KEY"</span></span>
<span><span class='o'>)</span></span></code></pre>

</div>

then reload it in a subsequent non-interactive session:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://gmailr.r-lib.org/reference/gm_auth.html'>gm_auth</a></span><span class='o'>(</span>token <span class='o'>=</span> <span class='nf'><a href='https://gmailr.r-lib.org/reference/gm_token_write.html'>gm_token_read</a></span><span class='o'>(</span></span>
<span>  <span class='s'>".secrets/gmailr-token.rds"</span>,</span>
<span>  key <span class='o'>=</span> <span class='s'>"SUPER_SECRET_ENCRYPTION_KEY"</span></span>
<span><span class='o'>)</span><span class='o'>)</span></span></code></pre>

</div>

## Progress on The Great Renaming

Unfortunately, there is considerable overlap between some obvious function names in an email-related package (e.g. "body", "date", "message") and pre-existing functions in base R (e.g. [`body()`](https://gmailr.r-lib.org/reference/gmailr-deprecated.html), [`date()`](https://gmailr.r-lib.org/reference/gmailr-deprecated.html), [`message()`](https://gmailr.r-lib.org/reference/gmailr-deprecated.html)). From very early on, gmailr exported several functions with regrettable name collisions, as evidenced at the beginning of this post when we called [`library(gmailr)`](https://gmailr.r-lib.org).

In version 1.0.0 (released 2019-08-30), the process of addressing this problem kicked off. At that time, gmailr adopted a universal `gm_` prefix for its functions and soft deprecated the legacy functions. Here's an indicative sample of the function replacements:

-   [`body()`](https://gmailr.r-lib.org/reference/gmailr-deprecated.html) ➡️ [`gm_body()`](https://gmailr.r-lib.org/reference/gm_body.html)
-   [`date()`](https://gmailr.r-lib.org/reference/gmailr-deprecated.html) ➡️ [`gm_date()`](https://gmailr.r-lib.org/reference/accessors.html)
-   [`message()`](https://gmailr.r-lib.org/reference/gmailr-deprecated.html) ➡️ [`gm_message()`](https://gmailr.r-lib.org/reference/gm_message.html)

In version 2.0.0, the legacy functions are hard deprecated and you should expect them to be removed in the next release of gmailr. I don't expect there to be much (any?) surviving usage of these functions, but it's definitely time to eliminate any remaining usage.

## Use the native pipe

gmailr is designed to be very pipe friendly and it leads to very natural code that builds up a message from its parts:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nv'>msg</span> <span class='o'>&lt;-</span></span>
<span>  <span class='nf'><a href='https://gmailr.r-lib.org/reference/gm_mime.html'>gm_mime</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://gmailr.r-lib.org/reference/accessors.html'>gm_to</a></span><span class='o'>(</span><span class='s'>"recipient@example.com"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://gmailr.r-lib.org/reference/accessors.html'>gm_from</a></span><span class='o'>(</span><span class='s'>"sender@example.com"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://gmailr.r-lib.org/reference/accessors.html'>gm_subject</a></span><span class='o'>(</span><span class='s'>"Hello, world!"</span><span class='o'>)</span> <span class='o'>|&gt;</span></span>
<span>  <span class='nf'><a href='https://gmailr.r-lib.org/reference/gm_mime.html'>gm_text_body</a></span><span class='o'>(</span><span class='s'>"I come in peace."</span><span class='o'>)</span></span></code></pre>

</div>

gmailr predates the introduction of the native pipe, in R 4.1, and therefore, historically, it has re-exported `%>%`, the magrittr pipe, for user convenience. The magrittr pipe also featured heavily in gmailr's documentation.

In the v2.0.0 release, I've removed the magrittr dependency and now use the native pipe operator `|>` in all documentation (gmailr never used the pipe internally). The purrr package pioneered this maneuver, within the tidyverse, and gmailr uses the same techniques to resolve the tension between the new usage of the base pipe and the tidyverse policy of supporting older R versions. You can learn more about the pipe transition in the blog post [Differences between the base R and magrittr pipes](https://www.tidyverse.org/blog/2023/04/base-vs-magrittr-pipe/).

## Acknowledgements

A big thank you to all those who have contributed to gmailr since the v1.0.0 release:

[@absuag](https://github.com/absuag), [@aeburger](https://github.com/aeburger), [@andresxmv](https://github.com/andresxmv), [@batpigandme](https://github.com/batpigandme), [@beib](https://github.com/beib), [@careercoachme](https://github.com/careercoachme), [@chuagh74](https://github.com/chuagh74), [@cstangor](https://github.com/cstangor), [@EeethB](https://github.com/EeethB), [@enricodata](https://github.com/enricodata), [@FJCC](https://github.com/FJCC), [@hadley](https://github.com/hadley), [@HadyShaaban](https://github.com/HadyShaaban), [@ismayc](https://github.com/ismayc), [@j450h1](https://github.com/j450h1), [@janebunr](https://github.com/janebunr), [@jcheng5](https://github.com/jcheng5), [@JeffreyCHoover](https://github.com/JeffreyCHoover), [@jennybc](https://github.com/jennybc), [@jimhester](https://github.com/jimhester), [@jonmichael-caldwell](https://github.com/jonmichael-caldwell), [@jreid88](https://github.com/jreid88), [@Karlheinzniebuhr](https://github.com/Karlheinzniebuhr), [@kputschko](https://github.com/kputschko), [@KryeKuzhinieri](https://github.com/KryeKuzhinieri), [@laurenmarietta](https://github.com/laurenmarietta), [@lwjohnst86](https://github.com/lwjohnst86), [@maelle](https://github.com/maelle), [@majazaloznik](https://github.com/majazaloznik), [@maticabgd](https://github.com/maticabgd), [@MCOtto](https://github.com/MCOtto), [@meheszlev](https://github.com/meheszlev), [@Mr-Hadoop-Hotshot](https://github.com/Mr-Hadoop-Hotshot), [@Niekuba](https://github.com/Niekuba), [@norcalbiostat](https://github.com/norcalbiostat), [@Patrikios](https://github.com/Patrikios), [@pschloss](https://github.com/pschloss), [@pythiantech](https://github.com/pythiantech), [@randy3k](https://github.com/randy3k), [@ratnexa](https://github.com/ratnexa), [@sanjmeh](https://github.com/sanjmeh), [@sdisav](https://github.com/sdisav), [@sommerhd-royals](https://github.com/sommerhd-royals), [@statnmap](https://github.com/statnmap), [@tariuk](https://github.com/tariuk), [@tvroylandt](https://github.com/tvroylandt), [@vinaybugz](https://github.com/vinaybugz), and [@VincentGuyader](https://github.com/VincentGuyader).

[^1]: The `subject` argument of [`gm_auth()`](https://gmailr.r-lib.org/reference/gm_auth.html) is also new and facilitates the use of a service account to impersonate a user.

[^2]: The full OAuth dance is not necessary in subsequent R sessions, though, by default gmailr is very conservative and asks for permission to use and refresh an existing token. This is, of course, configurable.

