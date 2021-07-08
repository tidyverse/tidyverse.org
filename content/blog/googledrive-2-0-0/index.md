---
output: hugodown::hugo_document

slug: googledrive-2-0-0
title: googledrive 2.0.0
date: 2021-07-08
author: Jenny Bryan
description: >
    googledrive 2.0.0 adapts to Drive's pivot from Team Drives to shared drives
    and its shift to a "single parent" model of file organization.

photo:
  url: https://unsplash.com/photos/Uf-c4u1usFQ
  author: Tim Evans

categories: [package]
tags: [googledrive]
rmd_hash: a27ef2e070b9118d

---

We're jazzed to announce the release of googledrive 2.0.0 (<https://googledrive.tidyverse.org>).

googledrive wraps the [Drive REST API v3](https://developers.google.com/drive/). The most common file operations are implemented in high-level functions designed for ease of use. You can find, list, create, trash, delete, rename, move, copy, browse, download, read, share and publish Drive files, including those on shared drives.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"googledrive"</span><span class='o'>)</span></code></pre>

</div>

Version 2.0.0 is mostly motivated by the need to react to changes to Google Drive and Drive API itself. We're also bumping the required version of the gargle package (<https://gargle.r-lib.org>), which handles everything around auth.

You can see a full list of changes in the [release notes](https://googledrive.tidyverse.org/news/index.html).

## Auth updates

If you are generally fairly passive about googledrive auth, then you should just sit back and let things happen organically during usage. If you've used googledrive before, you can expect to see some messages about cleaning and relocating the token cache when you first use v2.0.0. You can also expect to re-authenticate yourself with Google and re-authorize the "Tidyverse API Packages" to work with your files. This is all due to changes in gargle.

If your usage requires you to be more proactive about auth, read the [blog post for gargle's recent v1.2.0 release](https://www.tidyverse.org/blog/2021/07/gargle-1-2-0/). A key point is that we have rolled the built-in OAuth client, which is why those relying on it will need to re-auth.

**If the rolling of the tidyverse OAuth client is highly disruptive to your workflow, consider this a wake-up call** that you should be using your own OAuth client or, quite possibly, an entirely different method of auth. Our credential rolling will have no impact on users who use their own OAuth client or service account tokens.

## Team Drives are dead! Long live shared drives!

Google Drive has rebranded Team Drives as **shared drives**. While anyone can have a **My Drive**, shared drives are only available for Google Workspace (previously known as G Suite). This generally means a Google account you have through your employer or school, as opposed to a personal one. Shared drives and the files within are owned by a team or organization, as opposed to an individual.

The transition from Team Drives to shared drives appears to be more about vocabulary than changes in behaviour. Inside googledrive, this required some housekeeping work, but users won't notice much other than the obvious changes to function and argument names.

All `team_drive_*()` functions have been deprecated, in favor of their `shared_drive_*()` successors. Likewise, any `team_drive` argument has been deprecated, in favor of a new `shared_drive` argument. The terms used to describe search collections have also changed slightly, with `"allDrives"` replacing `"all"`. This applies to the `corpus` argument of [`drive_find()`](https://googledrive.tidyverse.org/reference/drive_find.html) and [`drive_get()`](https://googledrive.tidyverse.org/reference/drive_get.html).

## Single parenting and shortcuts

As of 2020-09-30, Drive no longer allows a file to be placed in multiple folders, which, frankly, is a big relief! Going forward, every file will have exactly 1 parent folder. In many cases that parent is just the top-level or root folder of your "My Drive" or of a shared drive.

This change has been accompanied by the introduction of file **shortcuts**, which function much like symbolic or "soft" links. Shortcuts are the new way to make a file appear to be in more than one place. A shortcut is a special type of Drive file, characterized by the `application/vnd.google-apps.shortcut` MIME type.

You can make a shortcut to any Drive file, including to a Drive folder, with [`shortcut_create()`](https://googledrive.tidyverse.org/reference/shortcut_create.html). Here we also use [`drive_example_remote()`](https://googledrive.tidyverse.org/reference/drive_examples.html) to access one of our new persistent, world-readable example files.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://googledrive.tidyverse.org'>googledrive</a></span><span class='o'>)</span>

<span class='c'># Target one of the official example files</span>
<span class='o'>(</span><span class='nv'>src_file</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://googledrive.tidyverse.org/reference/drive_examples.html'>drive_example_remote</a></span><span class='o'>(</span><span class='s'>"chicken.csv"</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; # A dribble: 1 x 3</span>
<span class='c'>#&gt;   name        id                                drive_resource   </span>
<span class='c'>#&gt;   &lt;chr&gt;       &lt;drv_id&gt;                          &lt;list&gt;           </span>
<span class='c'>#&gt; 1 chicken.csv 1VOh6wWbRfuQLxbLg87o58vxJt95SIiZ7 &lt;named list [37]&gt;</span>

<span class='nv'>sc</span> <span class='o'>&lt;-</span> <span class='nv'>src_file</span> <span class='o'><a href='https://googledrive.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://googledrive.tidyverse.org/reference/shortcut_create.html'>shortcut_create</a></span><span class='o'>(</span>name <span class='o'>=</span> <span class='s'>"chicken_sheet_shortcut"</span><span class='o'>)</span>
<span class='c'>#&gt; Created Drive file:</span>
<span class='c'>#&gt; • 'chicken_sheet_shortcut' &lt;id: 1YAPexlK3b3o7Mk-xadahXMYbMGLvScea&gt;</span>
<span class='c'>#&gt; With MIME type:</span>
<span class='c'>#&gt; • 'application/vnd.google-apps.shortcut'</span></code></pre>

</div>

Use [`shortcut_resolve()`](https://googledrive.tidyverse.org/reference/shortcut_resolve.html) to dereference a shortcut, i.e. resolve it to its target file id. Here we also demonstrate the new [`drive_read_string()`](https://googledrive.tidyverse.org/reference/drive_read_string.html) function that is handy for reading file content directly into R.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>sc</span> <span class='o'><a href='https://googledrive.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'><a href='https://googledrive.tidyverse.org/reference/shortcut_resolve.html'>shortcut_resolve</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://googledrive.tidyverse.org/reference/pipe.html'>%&gt;%</a></span>
  <span class='nf'><a href='https://googledrive.tidyverse.org/reference/drive_read_string.html'>drive_read_string</a></span><span class='o'>(</span><span class='o'>)</span> <span class='o'><a href='https://googledrive.tidyverse.org/reference/pipe.html'>%&gt;%</a></span> 
  <span class='nf'>readr</span><span class='nf'>::</span><span class='nf'><a href='https://readr.tidyverse.org/reference/read_delim.html'>read_csv</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; ℹ Resolved 1 shortcut found in 1 file:</span>
<span class='c'>#&gt; • 'chicken_sheet_shortcut' &lt;id: 1YAPexlK3b3o7Mk-xadahXMYbMGLvScea&gt; -&gt;</span>
<span class='c'>#&gt;   'chicken.csv' &lt;id: 1VOh6wWbRfuQLxbLg87o58vxJt95SIiZ7&gt;</span>
<span class='c'>#&gt; No encoding supplied: defaulting to UTF-8.</span>
<span class='c'>#&gt; # A tibble: 5 x 4</span>
<span class='c'>#&gt;   chicken            breed         sex    motto                                 </span>
<span class='c'>#&gt;   &lt;chr&gt;              &lt;chr&gt;         &lt;chr&gt;  &lt;chr&gt;                                 </span>
<span class='c'>#&gt; 1 Foghorn Leghorn    Leghorn       roost… That's a joke, ah say, that's a joke,…</span>
<span class='c'>#&gt; 2 Chicken Little     unknown       hen    The sky is falling!                   </span>
<span class='c'>#&gt; 3 Ginger             Rhode Island… hen    Listen. We'll either die free chicken…</span>
<span class='c'>#&gt; 4 Camilla the Chick… Chantecler    hen    Bawk, buck, ba-gawk.                  </span>
<span class='c'>#&gt; 5 Ernie The Giant C… Brahma        roost… Put Captain Solo in the cargo hold.</span></code></pre>

</div>

If you just want to see whether a file is a shortcut, use `drive_reveal(dat, "mime_type")` to add a MIME type column to any `dribble`.

Drive has been migrating existing files to the one-parent state, i.e., "single parenting" them. Drive selects the most suitable parent folder to keep, "based on the hierarchy's properties", and replaces any other parent-child relationships with a shortcut.

If you often refer to Drive files by their **filepath** (or name), as opposed to by file id, look in the release notes for more [about how shortcuts are handled within googledrive](https://googledrive.tidyverse.org/news/index.html#single-parenting-and-shortcuts).

## Making googledrive shut up

`googledrive_quiet` is a new option to suppress informational messages from googledrive. Unless it's explicitly set to `TRUE`, the default is to message. [`local_drive_quiet()`](https://googledrive.tidyverse.org/reference/googledrive-configuration.html) and [`with_drive_quiet()`](https://googledrive.tidyverse.org/reference/googledrive-configuration.html) are [withr-style](https://withr.r-lib.org) convenience helpers for setting `googledrive_quiet = TRUE` for some limited scope.

As a result, the `verbose` argument of all googledrive functions is deprecated and will be removed in a future release. In the current release, `verbose = FALSE` is still honored, but generates a warning.

## Everything else

Remember that the [release notes](https://googledrive.tidyverse.org/news/index.html) offer more information.

Here are a few more changes in v2.0.0:

-   The user interface has gotten more stylish, thanks to the cli package (<https://cli.r-lib.org>). All informational messages, warnings, and errors are now emitted via cli, which uses rlang's condition functions under-the-hood.

-   We now share a variety of world-readable, persistent example files on Drive, for use in examples and documentation. These remote example files complement the local example files that were already included in googledrive. Access with [`drive_examples_remote()`](https://googledrive.tidyverse.org/reference/drive_examples.html) and friends.

-   [`drive_read_string()`](https://googledrive.tidyverse.org/reference/drive_read_string.html) and [`drive_read_raw()`](https://googledrive.tidyverse.org/reference/drive_read_string.html) are new functions that read the content of a Drive file directly into R.

-   The `dribble` and `drive_id` classes are implemented using a more modern and effective approach from the vctrs package (<https://vctrs.r-lib.org>).

## Acknowledgements

We'd like to thank everyone who has furthered the development of googledrive, since the last major release (v1.0.0), through their contributions in issues and pull requests:

[@andrie](https://github.com/andrie), [@Arf9999](https://github.com/Arf9999), [@batpigandme](https://github.com/batpigandme), [@ben519](https://github.com/ben519), [@bllittle](https://github.com/bllittle), [@bschilder](https://github.com/bschilder), [@bshor](https://github.com/bshor), [@christopherkn](https://github.com/christopherkn), [@claytonperry](https://github.com/claytonperry), [@cmchuter](https://github.com/cmchuter), [@ctgrubb](https://github.com/ctgrubb), [@DataStrategist](https://github.com/DataStrategist), [@DavidGarciaEstaun](https://github.com/DavidGarciaEstaun), [@Diego-MX](https://github.com/Diego-MX), [@dollarvora](https://github.com/dollarvora), [@douglascm](https://github.com/douglascm), [@drwilkins](https://github.com/drwilkins), [@enricodata](https://github.com/enricodata), [@FedericoTrifoglio](https://github.com/FedericoTrifoglio), [@griswomw](https://github.com/griswomw), [@hadley](https://github.com/hadley), [@hideaki](https://github.com/hideaki), [@ian-adams](https://github.com/ian-adams), [@jcheng5](https://github.com/jcheng5), [@jennybc](https://github.com/jennybc), [@jimhester](https://github.com/jimhester), [@JMKelleher](https://github.com/JMKelleher), [@jobdiogenes](https://github.com/jobdiogenes), [@kongdd](https://github.com/kongdd), [@kpmainali](https://github.com/kpmainali), [@mehrnoushmalek](https://github.com/mehrnoushmalek), [@MichaelTD83](https://github.com/MichaelTD83), [@mitchelloharawild](https://github.com/mitchelloharawild), [@muschellij2](https://github.com/muschellij2), [@paulvern](https://github.com/paulvern), [@pseudorational](https://github.com/pseudorational), [@robertoromor](https://github.com/robertoromor), [@shahab3476](https://github.com/shahab3476), [@smingerson](https://github.com/smingerson), [@spocks](https://github.com/spocks), [@tklebel](https://github.com/tklebel), [@tpbarrette](https://github.com/tpbarrette), [@viquiff92](https://github.com/viquiff92), [@vnijs](https://github.com/vnijs), [@voremargot](https://github.com/voremargot), [@wilvancleve](https://github.com/wilvancleve), [@wuc66](https://github.com/wuc66), and [@xgirouxb](https://github.com/xgirouxb).

