---
output:
  hugodown::md_document

slug: pak-0-6-0
title: pak 0.6.0
date: 2023-08-28
author: Gábor Csárdi
description: >
    pak installs R packages from various sources.
    This post shows the improvements in system requirements installation
    on Linux, in the just released pak 0.6.0 version.

photo:
  url: https://www.pexels.com/photo/blue-white-orange-and-brown-container-van-163726/
  author: Pixabay

# one of: "deep-dive", "learn", "package", "programming", "roundup", or "other"
categories: [package]
tags: []
rmd_hash: cd7f2c7091e7b695

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

We're delighted to announce the release of [pak](https://pak.r-lib.org) 0.6.0. pak helps with the installation of R packages, and many related tasks.

You can install pak from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"pak"</span><span class='o'>)</span></span></code></pre>

</div>

This blog post focuses on the exciting new improvements in the matching and installation of system requirements on Linux systems.

You can see a full list of changes in the [release notes](https://github.com/r-lib/pak/releases/tag/v0.6.0)

## System requirements

Many R packages require the installation of external software, otherwise they do not work, or not even load. For example the RPostgres R package the PostgreSQL client library, and by default dynamically links to it on Linux systems. This means that you (or the administrators of your system) need to install this library, typically in the form of a system package: `libpq-dev` on Ubuntu and Debian systems, or `postgresql-server-devel` or `postgresql-devel` on Red Hat, Fedora, etc. systems.

The good news is that pak helps you with this:

-   it looks up the required system packages when installing R packages,
-   it checks if the required system packages are installed, and
-   it installs them automatically, if you are a superuser, or if you can use password-less `sudo` to start a superuser shell.

In addition, pak now also has some functions to query system requirements and system packages.

## Supported platforms

pak 0.6.0 supports the following Linux systems currently:

-   Ubuntu Linux,
-   Debian Linux,
-   Red Hat Enterprise Linux,
-   SUSE Linux Enterprise,
-   OpenSUSE,
-   CentOS,
-   Rocky Linux,
-   Fedora Linux.

Call [`pak::sysreqs_platforms()`](http://pak.r-lib.org/reference/sysreqs_platforms.html) to query the current list of supported platforms:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='http://pak.r-lib.org/reference/sysreqs_platforms.html'>sysreqs_platforms</a></span><span class='o'>(</span><span class='o'>)</span><span class='o'>[</span>,<span class='m'>1</span><span class='o'>:</span><span class='m'>3</span><span class='o'>]</span></span>
<span><span class='c'>#&gt;                        name    os distribution</span></span>
<span><span class='c'>#&gt; 1              Ubuntu Linux linux       ubuntu</span></span>
<span><span class='c'>#&gt; 2              Debian Linux linux       debian</span></span>
<span><span class='c'>#&gt; 3              CentOS Linux linux       centos</span></span>
<span><span class='c'>#&gt; 4               Rocky Linux linux   rockylinux</span></span>
<span><span class='c'>#&gt; 5  Red Hat Enterprise Linux linux       redhat</span></span>
<span><span class='c'>#&gt; 6  Red Hat Enterprise Linux linux       redhat</span></span>
<span><span class='c'>#&gt; 7  Red Hat Enterprise Linux linux       redhat</span></span>
<span><span class='c'>#&gt; 8              Fedora Linux linux       fedora</span></span>
<span><span class='c'>#&gt; 9            openSUSE Linux linux     opensuse</span></span>
<span><span class='c'>#&gt; 10    SUSE Linux Enterprise linux          sle</span></span>
<span></span></code></pre>

</div>

Call [`pak::system_r_platform()`](http://pak.r-lib.org/reference/system_r_platform.html) to check if pak has detected your platform correctly, and [`pak::sysreqs_is_supported()`](http://pak.r-lib.org/reference/sysreqs_is_supported.html) to see if it is supported:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='http://pak.r-lib.org/reference/system_r_platform.html'>system_r_platform</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] "x86_64-pc-linux-gnu-ubuntu-22.04"</span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='http://pak.r-lib.org/reference/sysreqs_is_supported.html'>sysreqs_is_supported</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; [1] TRUE</span></span>
<span></span></code></pre>

</div>

## R package installation

If you are using pak as the `root` user, on a supported platform, then during package installation pak will look up the required system packages, and will install the missing ones. Here is an example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='http://pak.r-lib.org/reference/pkg_install.html'>pkg_install</a></span><span class='o'>(</span><span class='s'>"RPostgres"</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Loading metadata database<span style='color: #00BB00;'>v</span> Loading metadata database ... done</span></span>
<span><span class='c'>#&gt;  </span></span>
<span><span class='c'>#&gt; &gt; Will <span style='font-style: italic;'>install</span> 12 packages.</span></span>
<span><span class='c'>#&gt; &gt; Will <span style='font-style: italic;'>download</span> 12 packages with unknown size.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>DBI</span>          1.1.3  [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>RPostgres</span>    1.4.5  [dl]<span style='color: #555555;'> + </span><span style='color: #BB0000;'>x</span><span style='color: #00BBBB;'> libpq-dev</span></span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>Rcpp</span>         1.0.11 [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>bit</span>          4.0.5  [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>bit64</span>        4.0.5  [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>blob</span>         1.2.4  [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>generics</span>     0.1.3  [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>hms</span>          1.1.3  [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>lubridate</span>    1.9.2  [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>pkgconfig</span>    2.0.3  [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>timechange</span>   0.2.0  [dl]</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>withr</span>        2.5.0  [dl]</span></span>
<span><span class='c'>#&gt; &gt; Will <span style='font-style: italic;'>install</span> 1 system package:</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #00BBBB;'>libpq-dev</span>  <span style='color: #555555;'>- </span><span style='color: #0000BB;'>RPostgres</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Getting 12 pkgs with unknown sizes</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>blob</span> 1.2.4 (x86_64-pc-linux-gnu-ubuntu-22.04) (45.94 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>generics</span> 0.1.3 (x86_64-pc-linux-gnu-ubuntu-22.04) (76.24 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>hms</span> 1.1.3 (x86_64-pc-linux-gnu-ubuntu-22.04) (98.35 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>RPostgres</span> 1.4.5 (x86_64-pc-linux-gnu-ubuntu-22.04) (455.11 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>bit64</span> 4.0.5 (x86_64-pc-linux-gnu-ubuntu-22.04) (475.41 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>pkgconfig</span> 2.0.3 (x86_64-pc-linux-gnu-ubuntu-22.04) (17.58 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>timechange</span> 0.2.0 (x86_64-pc-linux-gnu-ubuntu-22.04) (169.26 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>DBI</span> 1.1.3 (x86_64-pc-linux-gnu-ubuntu-22.04) (759.31 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>withr</span> 2.5.0 (x86_64-pc-linux-gnu-ubuntu-22.04) (228.73 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>bit</span> 4.0.5 (x86_64-pc-linux-gnu-ubuntu-22.04) (1.13 MB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>lubridate</span> 1.9.2 (x86_64-pc-linux-gnu-ubuntu-22.04) (980.37 kB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Got <span style='color: #0000BB;'>Rcpp</span> 1.0.11 (x86_64-pc-linux-gnu-ubuntu-22.04) (2.15 MB)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Installing system requirements</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Executing `sh -c apt-get -y update`</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Executing `sh -c apt-get -y install libpq-dev`</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>DBI</span> 1.1.3  <span style='color: #9E9E9E;'>(1.1s)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>RPostgres</span> 1.4.5  <span style='color: #9E9E9E;'>(1.1s)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>Rcpp</span> 1.0.11  <span style='color: #9E9E9E;'>(1.2s)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>bit</span> 4.0.5  <span style='color: #9E9E9E;'>(1.2s)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>bit64</span> 4.0.5  <span style='color: #9E9E9E;'>(126ms)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>blob</span> 1.2.4  <span style='color: #9E9E9E;'>(86ms)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>generics</span> 0.1.3  <span style='color: #9E9E9E;'>(83ms)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>hms</span> 1.1.3  <span style='color: #9E9E9E;'>(59ms)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>lubridate</span> 1.9.2  <span style='color: #9E9E9E;'>(1.1s)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>pkgconfig</span> 2.0.3  <span style='color: #9E9E9E;'>(1.1s)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>timechange</span> 0.2.0  <span style='color: #9E9E9E;'>(63ms)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>withr</span> 2.5.0  <span style='color: #9E9E9E;'>(1.1s)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> 1 pkg + 16 deps: kept 5, added 12, dld 12 (6.58 MB) <span style='color: #B2B2B2;'>[17.1s]</span></span></span>
<span></span></code></pre>

</div>

### Running R as a regular user

If you don't want to use R as the superuser, but you can set up `sudo` without a password, that works as well. pak will detect the password-less `sudo` capability, and use it to install system packages, as needed.

If you run R as a regular (not root) user, and password-less `sudo` is not available, then pak will print the system requirements, but it will not try to install or update them.

If you are compiling R packages from source, and they need to link to system libraries, then their installation will probably fail, until you install these system packages.

If you are installing binary R packages (e.g. from [P3M](https://packagemanager.posit.co/client/#/)), then the installation typically succeeds, but you won't be able to load these packages into R, until you install the required system packages.

To demonstrate this, let's remove the system package for the PostgreSQL client library:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'><a href='https://rdrr.io/r/base/system.html'>system</a></span><span class='o'>(</span><span class='s'>"apt-get remove -y libpq5"</span><span class='o'>)</span></span></code></pre>

</div>

If now we (re)install the binary RPostgres R package, the installation will succeed, but then [`library()`](https://rdrr.io/r/base/library.html) fails because of the missing system package. (We will the broken R package below.)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Loading metadata database<span style='color: #00BB00;'>v</span> Loading metadata database ... done</span></span>
<span><span class='c'>#&gt;  </span></span>
<span><span class='c'>#&gt; &gt; Will <span style='font-style: italic;'>install</span> 1 package.</span></span>
<span><span class='c'>#&gt; &gt; Will <span style='font-style: italic;'>download</span> 1 package with unknown size.</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #0000BB;'>RPostgres</span>   1.4.5 [dl]<span style='color: #555555;'> + </span><span style='color: #BB0000;'>x</span><span style='color: #00BBBB;'> libpq-dev</span></span></span>
<span><span class='c'>#&gt; <span style='color: #BB0000;'>x</span> Missing 1 system package. You'll probably need to install it manually:</span></span>
<span><span class='c'>#&gt; <span style='color: #555555;'>+ </span><span style='color: #00BBBB;'>libpq-dev</span>  <span style='color: #555555;'>- </span><span style='color: #0000BB;'>RPostgres</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Getting 1 pkg with unknown size</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Cached copy of <span style='color: #0000BB;'>RPostgres</span> 1.4.5 (x86_64-pc-linux-gnu-ubuntu-22.04) is the latest build</span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> Installed <span style='color: #0000BB;'>RPostgres</span> 1.4.5  <span style='color: #9E9E9E;'>(1.1s)</span></span></span>
<span><span class='c'>#&gt; <span style='color: #00BB00;'>v</span> 1 pkg + 16 deps: kept 16, added 1 <span style='color: #B2B2B2;'>[5.7s]</span></span></span>
<span></span></code></pre>

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rpostgres.r-dbi.org'>RPostgres</a></span><span class='o'>)</span></span>
<span><span class='c'>#&gt; Error: package or namespace load failed for 'RPostgres' in dyn.load(file, DLLpath = DLLpath, ...):</span></span>
<span><span class='c'>#&gt;  unable to load shared object '/root/R/x86_64-pc-linux-gnu-library/4.3/RPostgres/libs/RPostgres.so':</span></span>
<span><span class='c'>#&gt;   libpq.so.5: cannot open shared object file: No such file or directory</span></span>
<span><span class='c'>#&gt; Execution halted</span></span>
<span></span></code></pre>

</div>

## System requirements queries

pak 0.6.0 also has a number of functions to query system requirements and system packages. The [`pak::pkg_sysreqs()`](http://pak.r-lib.org/reference/pkg_sysreqs.html) function is similar to [`pak::pkg_deps()`](http://pak.r-lib.org/reference/pkg_deps.html) but in addition to looking up package dependencies, it also looks up system dependencies, and only reports the latter:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='http://pak.r-lib.org/reference/pkg_sysreqs.html'>pkg_sysreqs</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"curl"</span>, <span class='s'>"r-lib/xml2"</span>, <span class='s'>"devtools"</span>, <span class='s'>"CHRONOS"</span><span class='o'>)</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Loading metadata database<span style='color: #00BB00;'>v</span> Loading metadata database ... done</span></span>
<span><span class='c'>#&gt; -- Install scripts --------------------------------------------- Ubuntu 22.04 --</span></span>
<span><span class='c'>#&gt; apt-get -y update</span></span>
<span><span class='c'>#&gt; apt-get -y install libcurl4-openssl-dev libssl-dev git make libgit2-dev \</span></span>
<span><span class='c'>#&gt;   zlib1g-dev pandoc libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev \</span></span>
<span><span class='c'>#&gt;   libicu-dev libfontconfig1-dev libfribidi-dev libharfbuzz-dev libxml2-dev \</span></span>
<span><span class='c'>#&gt;   libglpk-dev libgmp3-dev default-jdk</span></span>
<span><span class='c'>#&gt; R CMD javareconf</span></span>
<span><span class='c'>#&gt; R CMD javareconf</span></span>
<span><span class='c'>#&gt; </span></span>
<span><span class='c'>#&gt; -- Packages and their system dependencies --------------------------------------</span></span>
<span><span class='c'>#&gt; CHRONOS     -- default-jdk, pandoc</span></span>
<span><span class='c'>#&gt; credentials -- git</span></span>
<span><span class='c'>#&gt; curl        -- libcurl4-openssl-dev, libssl-dev</span></span>
<span><span class='c'>#&gt; fs          -- make</span></span>
<span><span class='c'>#&gt; gert        -- libgit2-dev</span></span>
<span><span class='c'>#&gt; gitcreds    -- git</span></span>
<span><span class='c'>#&gt; httpuv      -- make, zlib1g-dev</span></span>
<span><span class='c'>#&gt; igraph      -- libglpk-dev, libgmp3-dev, libxml2-dev</span></span>
<span><span class='c'>#&gt; knitr       -- pandoc</span></span>
<span><span class='c'>#&gt; openssl     -- libssl-dev</span></span>
<span><span class='c'>#&gt; pkgdown     -- pandoc</span></span>
<span><span class='c'>#&gt; png         -- libpng-dev</span></span>
<span><span class='c'>#&gt; ragg        -- libfreetype6-dev, libjpeg-dev, libpng-dev, libtiff-dev</span></span>
<span><span class='c'>#&gt; RCurl       -- libcurl4-openssl-dev, make</span></span>
<span><span class='c'>#&gt; remotes     -- git</span></span>
<span><span class='c'>#&gt; rJava       -- default-jdk, make</span></span>
<span><span class='c'>#&gt; rmarkdown   -- pandoc</span></span>
<span><span class='c'>#&gt; sass        -- make</span></span>
<span><span class='c'>#&gt; stringi     -- libicu-dev</span></span>
<span><span class='c'>#&gt; systemfonts -- libfontconfig1-dev, libfreetype6-dev</span></span>
<span><span class='c'>#&gt; textshaping -- libfreetype6-dev, libfribidi-dev, libharfbuzz-dev</span></span>
<span><span class='c'>#&gt; XML         -- libxml2-dev</span></span>
<span><span class='c'>#&gt; xml2        -- libxml2-dev</span></span>
<span></span></code></pre>

</div>

See the manual of [`pak::pkg_sysreqs()`](http://pak.r-lib.org/reference/pkg_sysreqs.html) to learn how to programmatically extract information from its return value.

[`pak::sysreqs_check_installed()`](http://pak.r-lib.org/reference/sysreqs_check_installed.html) is a handy function that checks if all system requirements are installed for some or all R packages in your library. This should report our broken RPostgres package:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='http://pak.r-lib.org/reference/sysreqs_check_installed.html'>sysreqs_check_installed</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; system package installed required by</span></span>
<span><span class='c'>#&gt; -------------- --        -----------</span></span>
<span><span class='c'>#&gt; libpq-dev      <span style='color: #BB0000;'>x</span>         RPostgres</span></span>
<span></span></code></pre>

</div>

[`pak::sysreqs_fix_installed()`](http://pak.r-lib.org/reference/sysreqs_check_installed.html) goes one step further and also tries to install the missing system requirements:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='nf'>pak</span><span class='nf'>::</span><span class='nf'><a href='http://pak.r-lib.org/reference/sysreqs_check_installed.html'>sysreqs_fix_installed</a></span><span class='o'>(</span><span class='o'>)</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Need to install 1 system package.</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Installing system requirements</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Executing `sh -c apt-get -y update`</span></span>
<span><span class='c'>#&gt; <span style='color: #00BBBB;'>i</span> Executing `sh -c apt-get -y install libpq-dev`</span></span>
<span></span></code></pre>

</div>

Now we can load RPostgres again:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://rpostgres.r-dbi.org'>RPostgres</a></span><span class='o'>)</span></span>
<span></span></code></pre>

</div>

## Configuration

There are several pak configuration options you can use to adjust how system requirements are handled. See the complete list in the `config?pak` manual page.

## Other related pak functions

-   [`pak::sysreqs_db_list()`](http://pak.r-lib.org/reference/sysreqs_db_list.html), `pak::sysreqs_dbmatch()` and [`pak::sysreqs_db_update()`](http://pak.r-lib.org/reference/sysreqs_db_update.html) list, query and update the built-in system requirements database.
-   [`pak::sysreqs_list_system_packages()`](http://pak.r-lib.org/reference/sysreqs_list_system_packages.html) lists system packages, including virtual packages and the features they provide.

## More information

-   [pak documentation](https://pak.r-lib.org/)
-   [System requirements manual page](https://pak.r-lib.org/dev/reference/sysreqs.html)
-   [System requirements database](https://github.com/rstudio/r-system-requirements)

## Acknowledgements

A big thank you to all those who have contributed to pak, or one of its workhorse packages since the v0.5.1 release:

[@alexpate30](https://github.com/alexpate30), [@averissimo](https://github.com/averissimo), [@ArnaudKunzi](https://github.com/ArnaudKunzi), [@billdenney](https://github.com/billdenney), [@Darxor](https://github.com/Darxor), [@drmowinckels](https://github.com/drmowinckels), [@Fan-iX](https://github.com/Fan-iX), [@gongyh](https://github.com/gongyh), [@hadley](https://github.com/hadley), [@idavydov](https://github.com/idavydov), [@jefferis](https://github.com/jefferis), [@joan-yanqiong](https://github.com/joan-yanqiong), [@kevinushey](https://github.com/kevinushey), [@kkmann](https://github.com/kkmann), [@klmr](https://github.com/klmr), [@krlmlr](https://github.com/krlmlr), [@lgaborini](https://github.com/lgaborini), [@maelle](https://github.com/maelle), [@maxheld83](https://github.com/maxheld83), [@maximsmol](https://github.com/maximsmol), [@michaelmayer2](https://github.com/michaelmayer2), [@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [@olivroy](https://github.com/olivroy), [@pascalgulikers](https://github.com/pascalgulikers), [@pawelru](https://github.com/pawelru), [@royfrancis](https://github.com/royfrancis), [@tanho63](https://github.com/tanho63), [@thomasyu888](https://github.com/thomasyu888), [@vincent-hanlon](https://github.com/vincent-hanlon), and [@VincentGuyader](https://github.com/VincentGuyader).
