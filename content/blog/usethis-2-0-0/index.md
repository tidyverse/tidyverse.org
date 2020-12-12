---
output: hugodown::hugo_document

slug: usethis-2-0-0
title: usethis 2.0.0
date: 2020-12-10
author: Jennifer Bryan
description: >
    This is a big release aimed at improving usability, especially around Git
    and GitHub functionality.

photo:
  url: https://unsplash.com/photos/knzXwBCtEeM
  author: Kiana Bosman
categories: [package] 
tags: [devtools,r-lib,usethis]
rmd_hash: ad7105b704e65d12

---

We're ecstatic to announce the release of usethis v2.0.0 ([usethis.r-lib.org](https://usethis.r-lib.org/)). usethis is a package that facilitates interactive workflows for R project creation and development. It's mostly focussed on easing day-to-day package development, but many of its functions are also useful for non-package projects.

You can install usethis from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"usethis"</span><span class='o'>)</span>
</code></pre>

</div>

This is a major release, involving lots of change under the hood, and yet there are no big, brand new features. Instead, this release is about making more things "just work" the way you expect. Below, we list many functions and arguments that have been deprecated, because we've been able to deliver the same functionality (actually, a bit more) with a smaller and simpler user interface.

This blog post hits a few highlights, mostly relating to Git and GitHub functionality:

-   We've switched to a new package, gert, for Git operations. This resolves some long-standing difficulties around credential-finding and provides more reliable support for both HTTPS and SSH remotes.
-   Anything that works for github.com should now work for any [GitHub Enterprise](https://github.com/enterprise) deployment.
-   GitHub personal access tokens are now handled in the same way as command line Git. This means we can all manage our tokens more securely and, for example, can have different tokens for different hosts.
-   We've added more functionality for working with GitHub pull requests.
-   A default branch named `main` should be fully supported.

You can see a full list of changes in the [release notes](https://usethis.r-lib.org/news/index.html#usethis-2-0-0-2020-12-10).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://usethis.r-lib.org'>usethis</a></span><span class='o'>)</span>
</code></pre>

</div>

Git/GitHub & credentials, hosts, and protocols
----------------------------------------------

Usethis has various functions that help with Git-related tasks, which break down into two categories:

1.  **Git** tasks, such as clone, push, and pull. These are things you could do with command line Git.
2.  Git**Hub** tasks, such as fork, release, and open an issue or pull request. These are things you could do in the browser or with the GitHub API.

We've switched from git2r to the gert package for Git operations (<https://docs.ropensci.org/gert/>). We continue to use the gh package for GitHub API work (<https://gh.r-lib.org>).

Many real-world goals can only be accomplished through a mix of Git and GitHub operations, therefore many usethis functions make use of both gert and gh. These packages, in turn, might need your credentials to prove to GitHub that you have the permission to do what you're trying to do.

### Finding Git credentials

One of the reasons we switched to the gert package is that it generally discovers the same Git credentials as command line Git, for both the HTTPS and SSH protocols, even on Windows. If things *still* go sideways, gert's approach to credential finding is mercifully explicit and debuggable[^1].

This allows usethis to shed some of the workarounds we have needed in the past, to serve as a remedial "credential valet". As a result, several functions and arguments are no longer needed and have been deprecated:

-   Deprecated functions:
    -   [`use_git_credentials()`](https://usethis.r-lib.org/reference/git_credentials.html)
    -   [`git_credentials()`](https://usethis.r-lib.org/reference/git_credentials.html)
    -   [`github_token()`](https://usethis.r-lib.org/reference/usethis-defunct.html)
-   Functions with (deprecated arguments):
    -   [`create_from_github()`](https://usethis.r-lib.org/reference/create_from_github.html) (`auth_token`, `credentials`)
    -   [`use_github()`](https://usethis.r-lib.org/reference/use_github.html) (`auth_token`, `credentials`)
    -   [`use_github_links()`](https://usethis.r-lib.org/reference/use_github_links.html) (`host`, `auth_token`)
    -   [`use_github_labels()`](https://usethis.r-lib.org/reference/use_github_labels.html) (`repo_spec`, `host`, `auth_token`)
    -   [`use_tidy_labels()`](https://usethis.r-lib.org/reference/use_github_labels.html) (`repo_spec`, `host`, `auth_token`)  
    -   [`use_github_release()`](https://usethis.r-lib.org/reference/use_github_release.html) (`host`, `auth_token`)

If you have any of these in your `.Rprofile` or muscle memory, you can let go of that now. (We'll say more about `host` and `auth_token` below.)

### Host and GitHub Enterprise

Many companies and universities run their own instance of GitHub, using a pro product called GitHub Enterprise (GHE), that walks and talks just like github.com. It's been frustrating that many usethis functions didn't *quite* work for GHE. We had partial support for GHE, by adding a `host` argument to some functions, but that created new headaches around juggling personal access tokens.

We've completely refactored the "GitHub host" logic in usethis and GHE should be fully supported now. In an existing repo, usethis consults the configured Git remotes, filters for remotes that smell like a GitHub deployment, and deduces the target `host`. As a result, we've deprecated the `host` argument in several functions:

-   [`use_github_links()`](https://usethis.r-lib.org/reference/use_github_links.html)
-   [`use_github_labels()`](https://usethis.r-lib.org/reference/use_github_labels.html), [`use_tidy_labels()`](https://usethis.r-lib.org/reference/use_github_labels.html)
-   [`use_github_release()`](https://usethis.r-lib.org/reference/use_github_release.html)

In [`use_github()`](https://usethis.r-lib.org/reference/use_github.html) and [`create_from_github()`](https://usethis.r-lib.org/reference/create_from_github.html), we still have a `host` argument, but there are also other ways to specify the `host`:

-   usethis no longer inserts its own opinion about the default `host`. This means we no longer get in the way of the existing default behaviour of the gh package, which is to consult the `GITHUB_API_URL` environment variable, if it is set.
-   A couple functions now accept a full URL as the `repo_spec` and, if you do that, we discover the `host` from the URL.

#### Give me your full URLs!

The last point above is a nice quality-of-life improvement even when working on github.com. It means you can copy a URL straight from your browser and, as long as it points somewhere within the target repo, all will be well. For example, if you decide to clone Matt Lincoln's clipr package while perusing its issues, you can just copy the url directly from your browser:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://usethis.r-lib.org/reference/create_from_github.html'>create_from_github</a></span><span class='o'>(</span><span class='s'>"https://github.com/mdlincoln/clipr/issues"</span><span class='o'>)</span>
<span class='c'>#&gt; ℹ Defaulting to https Git protocol</span>
<span class='c'>#&gt; ✓ Setting `fork = TRUE`</span>
<span class='c'>#&gt; ✓ Creating '/Users/jenny/Desktop/clipr/'</span>
<span class='c'>#&gt; ✓ Forking 'mdlincoln/clipr'</span>
<span class='c'>#&gt; ✓ Cloning repo from 'https://github.com/jennybc/clipr.git' into '/Users/jenny/Desktop/clipr'</span>
<span class='c'>#&gt; ✓ Setting active project to '/Users/jenny/Desktop/clipr'</span>
<span class='c'>#&gt; ℹ Default branch is 'master'</span>
<span class='c'>#&gt; ✓ Adding 'upstream' remote: 'https://github.com/mdlincoln/clipr.git'</span>
<span class='c'>#&gt; ✓ Pulling changes from 'upstream/master' (default branch of source repo)</span>
<span class='c'>#&gt; ✓ Setting remote tracking branch for local 'master' branch to 'upstream/master'</span>
</code></pre>

</div>

URLs are supported by the `repo_spec` argument of [`create_from_github()`](https://usethis.r-lib.org/reference/create_from_github.html) and [`use_tidy_thanks()`](https://usethis.r-lib.org/reference/use_tidy_thanks.html). In addition to browser URLs, you can also use HTTPS and SSH Git remote URLs.

### Personal access tokens (PATs)

This diagram shows the different ways that usethis might interact with GitHub:

1.  As a Git server, via gert, using either the HTTPS or SSH protocol
2.  As a web service, via gh, using HTTPS (and OAuth)

<div class="highlight">

<img src="pat-kills-both-birds.png" width="80%" style="display: block; margin: auto;" />

</div>

The cheerful orange ovals indicate why we recommend HTTPS as your Git protocol: Once you set up your GitHub personal access token (PAT), usethis, gert, and gh (and possibly other packages) will all be able to find and use this common credential. (If you are an SSH person, you need to set up a GitHub PAT for work that involves the GitHub API, in addition to the SSH keys needed for Git work.)

You may have noticed that command line Git remembers your HTTPS credentials, after you've provided them once[^2]. Git has an internal interface for storing and retrieving HTTPS credentials from system-specific helpers, such as the macOS Keychain and Windows Credential Manager. This interface is exposed for use by other applications in the [`git credential`](https://git-scm.com/docs/git-credential) utility Both gert and gh (and, therefore, usethis) now use this utility to retrieve a PAT suitable for a specific `host`.

In the previous section, we explained how the `host` is now automatically discovered from Git remotes. And we've just explained that we now look up the PAT based on the `host`. Together, this means usethis no longer needs any explicit PAT management and finishes explaining why so many credential-, token-, and host-related functions and arguments have been deprecated. This is also a major reason why GitHub Enterprise "just works" now.

The new connection to the system-specific Git credential store also means we no longer need to set `GITHUB_PAT` in our `.Renviron` startup files. It is a better security practice anyway to avoid storing such secrets in plain text, whenever possible.

    BLAH=foo
    GITHUB_PAT=xyz  # <-- WE SUGGEST YOU REMOVE THIS LINE FROM .Renviron
    WUT=yo
    OTHER_WEB_SERVICE=super-secret-very-powerful-token

The `host`-specific PAT is now retrieved from the Git credential store upon first need. Note that the PAT **is** still cached in an environment variable for reuse during the remainder of the current R session.

Our full recommendations for getting and configuring a PAT are in the new vignette [Managing Git(Hub) Credentials](https://usethis.r-lib.org/articles/articles/git-credentials.html).

### Git protocol

When usethis configures a new Git remote, it must choose a protocol, either HTTPS or SSH. The new default in this situation is HTTPS, because as we explained above, we think HTTPS is the best choice for most users and projects.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://usethis.r-lib.org/reference/git_protocol.html'>git_protocol</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'>#&gt; <span style='color: #BBBB00;'>ℹ</span><span> Defaulting to https Git protocol</span></span>

<span class='c'>#&gt; [1] "https"</span>
</code></pre>

</div>

As always, you can specify the default protocol for a single session with [`use_git_protocol()`](https://usethis.r-lib.org/reference/git_protocol.html) or for all sessions via the `usethis.protocol` option. Those who prefer SSH may want to set this option in `.Rprofile` going forward.

Pull request helpers
--------------------

The team that maintains the tidyverse and r-lib packages makes heavy use of GitHub pull requests for managing internal and external contributions. The `pr_*()` family of functions supports pull request workflows, for maintainers and contributors. This family has gained a couple of new functions and some improvements to existing functions:

-   [`pr_resume()`](https://usethis.r-lib.org/reference/pull-requests.html) resumes work on an existing local PR branch. It can be called argument-less, to select a branch interactively.

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'>> pr_resume()
      ℹ No branch specified ... looking up local branches and associated PRs
      Which branch do you want to checkout? (0 to exit) 

      1: avalcarcel9-add_use_author --> #833 ('@avalcarcel9'): Add use author
      2:                 latex-hell
      3:                     holder
      4:            patch-for-withr

      Selection: 
      </code></pre>

    </div>

-   [`pr_forget()`](https://usethis.r-lib.org/reference/pull-requests.html) abandons a PR you initiated locally or fetched from GitHub. It only does local clean up and will never delete a remote branch or close a PR.

-   [`pr_fetch()`](https://usethis.r-lib.org/reference/pull-requests.html) and [`pr_view()`](https://usethis.r-lib.org/reference/pull-requests.html) also present an interactive choice, when the target PR is not specified or implied.

Other goodies
-------------

The `use_*_license()` functions have gotten a general overhaul and also now work for projects, not just for packages. This was part of a bigger effort related re-licensing some tidyverse/r-lib packages and updating the [licensing chapter of R Packages](https://r-pkgs.org/license.html) for its future second edition.

Here's a selection of other new features:

-   A default Git branch named `main` now works. [`git_branch_default()`](https://usethis.r-lib.org/reference/git_branch_default.html) is a new function that tries to discover the default branch from the local or remote Git repo. Internally, it is used everywhere that we previously assumed a default branch named `master`.

-   [`use_github_pages()`](https://usethis.r-lib.org/reference/use_github_pages.html) and [`use_tidy_pkgdown()`](https://usethis.r-lib.org/reference/tidyverse.html) are great for turning on GitHub Pages and for using GitHub Actions to build and deploy a pkgdown site.

-   usethis knows that RStudio \>= 1.3 stores user preferences in a file, which means that [`use_blank_slate()`](https://usethis.r-lib.org/reference/use_blank_slate.html) can be used to opt in to the "never save to or restore `.RData`" lifestyle, globally, for a user.

-   [`browse_package()`](https://usethis.r-lib.org/reference/browse-this.html) and [`browse_project()`](https://usethis.r-lib.org/reference/browse-this.html) are new additions to the `browse_*()` family that let the user choose from a list of URLs derived from local Git remotes and DESCRIPTION (local or possibly on CRAN).

    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'>> browse_package()
    Which URL do you want to visit? (0 to exit) 

    1: https://github.com/r-lib/usethis        ('origin' remote)
    2: https://github.com/avalcarcel9/usethis  ('avalcarcel9' remote)
    3: https://usethis.r-lib.org               (URL field in DESCRIPTION)
    4: https://github.com/r-lib/usethis        (URL field in DESCRIPTION)
    5: https://github.com/r-lib/usethis/issues (BugReports field in DESCRIPTION)

    Selection: 
    </code></pre>

    </div>

Acknowledgements
----------------

A big thanks to everyone who helped with this release by reporting bugs, discussing issues, and contributing code: [@albersonmiranda](https://github.com/albersonmiranda), [@andrader](https://github.com/andrader), [@arashHaratian](https://github.com/arashHaratian), [@Athanasiamo](https://github.com/Athanasiamo), [@batpigandme](https://github.com/batpigandme), [@cderv](https://github.com/cderv), [@cstepper](https://github.com/cstepper), [@dmenne](https://github.com/dmenne), [@friep](https://github.com/friep), [@hadley](https://github.com/hadley), [@ijlyttle](https://github.com/ijlyttle), [@jamesmyatt](https://github.com/jamesmyatt), [@jennybc](https://github.com/jennybc), [@jeroen](https://github.com/jeroen), [@jimhester](https://github.com/jimhester), [@jtr13](https://github.com/jtr13), [@KoderKow](https://github.com/KoderKow), [@krlmlr](https://github.com/krlmlr), [@lionel-](https://github.com/lionel-), [@maelle](https://github.com/maelle), [@malcolmbarrett](https://github.com/malcolmbarrett), [@maurolepore](https://github.com/maurolepore), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@mrcaseb](https://github.com/mrcaseb), [@vinhtantran](https://github.com/vinhtantran), and [@whtns](https://github.com/whtns).

[^1]: gert uses a dedicated, standalone package: <https://docs.ropensci.org/credentials/>

[^2]: In our experience, on both macOS and Windows, recent Git versions come with credential caching that works out-of-the-box. If this is not your experience, it's a good reason to update Git.

