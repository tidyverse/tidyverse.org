---
title: devtools 2.0.0
date: 2018-10-26
slug: devtools-2-0-0
author: Jim Hester
categories: [package]
description: >
    Make package development easier by providing R functions that simplify and expedite common tasks.
photo:
  url: https://unsplash.com/photos/wEJK4q_YlNQ
  author: Hunter Haley
---

## Introduction

[devtools](https://cran.r-project.org/package=devtools) 2.0.0 is now on CRAN.

devtools makes package development easier by providing R functions that
simplify and expedite common tasks. [R Packages] is a book based around this
workflow.

devtools 2.0.0 is a major release that contains work from the past year and a
half, since the major devtools release (1.13.0).

## Breaking changes

There are a handful of breaking changes in this release, mainly done in the
interest of simplifying and standardizing the function APIs.

The changes should affect relatively little user code, but have required
developers to make changes. Common errors and ways to work around them
as well as the full list of changes can be found in the [Breaking
changes](https://github.com/r-lib/devtools/blob/master/NEWS.md#breaking-changes)
section of devtools'
[NEWS](https://github.com/r-lib/devtools/blob/master/NEWS.md). If you
discover something missing, please let us know so we can add it.

## Conscious uncoupling

This release splits the functionality in devtools into a number of smaller
packages which are simpler to develop and also easier for other packages to
depend on. In particular the following packages have been spun off in what we
are calling the [conscious uncoupling] of devtools.

* [remotes](https://github.com/r-lib/remotes): Installing packages (i.e.
  `install_github()`).
* [pkgbuild](https://github.com/r-lib/pkgbuild): Building binary packages
  (including checking if build tools are available) (i.e. `build()`).
* [pkgload](https://github.com/r-lib/pkgload): Simulating package loading (i.e.
  `load_all()`).
* [rcmdcheck](https://github.com/r-lib/rcmdcheck): Running R CMD check and
  reporting the results (i.e. `check()`).
* [revdepcheck](https://github.com/r-lib/revdepcheck): Running R CMD check on
  all reverse dependencies, and figuring out what's changed since the last CRAN
  release (i.e. `revdep_check()`).
* [sessioninfo](https://github.com/r-lib/sessioninfo): R session info (i.e.
  `session_info()`).
* [usethis](https://github.com/r-lib/usethis): Automating package setup (i.e.
  `use_test()`).

devtools will remain the main package developers will interact with when
writing R packages; it will just rely on these other packages internally
for most of the functionality.

Generally, you should not need to worry about these different packages, because
devtools installs them all automatically. You will need to care, however, if
you're filing a bug because reporting it at the correct place will lead to a
speedier resolution.

Package developers who wish to depend on devtools features should also pay
attention to which package the functionality is coming from and depend on that
rather than devtools. In most cases packages should not depend on devtools
directly.

## New features

The majority of the work for this release was related to bugfixes and
infrastructure improvements, but there are also some new features you may
notice.

As always a complete list of all the changes is available in the package
[Changelog](http://devtools.r-lib.org/news/index.html).

### Upgrade menu

All of the install functions (e.g. `install_github()`) now prompt the user with
a menu if there are dependencies of the package being installed which are
outdated. This allows the user to pick which if any they would like to upgrade.
Previous versions of devtools always upgraded these packages automatically by
default, which sometimes was frustrating when you simply wanted to install one
package.

<p align="center">
<img src="/images/devtools-2.0.0/upgrade-menu.png" alt="upgrade menu">
</p>

The menu respects the `menu.graphics` option, so set `options(menu.graphics =
FALSE)` in your .Rprofile if you prefer text based menus, or `TRUE` if you
prefer graphical widgets.

### Improved check output

`check()` now uses the [rcmdcheck] package, which has much richer (and
colorful) output to the check results, which makes finding where a check fail
much easier.

<p align="center">
<a href="https://github.com/r-lib/rcmdcheck">
<img src="https://raw.githubusercontent.com/r-lib/rcmdcheck/master/inst/rcmdcheck.gif" alt="rcmdcheck output" width="700">
</a>
</p>

### Testing single files

devtools now includes functions (`test_file()` and `test_coverage_file()`) to
improve development of a single file. Rather than running all
tests, or manually supplying a `filter` argument to restrict the tests
`test_file()` automatically runs the corresponding tests for a given source
file. These functions make the feedback loop when developing new features
quicker as you only run the relevant tests for the file you are editing.

This requires you use a standard naming convention for your tests, e.g. if
you have a source file `R/featureA.R` the corresponding test file would be
`tests/testthat/test-featureR.R`.

The tests file to run is automatically detected from the open file in RStudio (if
available), so you can call `test_file()` with either the source file or
the test file open. There is also a corresponding `test_coverage_file()` function, to show the test
code coverage for a single source file, which works in the same way as
`test_file()`.

There are also RStudio addins for these functions so you can bind them to shortcut keys.
We recommend

- TODO for `test_file()`
- TODO for `test_coverage_file()`

### Spell checking

`spell_check()` can be used to check the spelling of package documentation
using the [spelling] package. We have found checking spelling before a release
often finds errors so it is highly encouraged. For more details on features of
the spelling package see the [rOpenSci
post](https://ropensci.org/technotes/2017/09/07/spelling-release/) of the 1.0.0
release.

## Acknowledgements

This release was truly a team effort. Much of the work in the uncoupled
packages, particularly the remotes, rcmdcheck, revdepcheck and sessioninfo
packages was done by Gábor Csárdi. Hadley Wickham worked extensively on
pkgbuild, pkgload and usethis (as well as being responsible for most of the
original code in devtools) and Jenny Bryan had major contributions to the
usethis package.





The work over 8 packages (devtools + the uncoupled packages) for this release
includes 1,579 commits, 1,487 closed issues and 107 different contributors, it
was truly a team effort!



We're grateful to all of the *391* people who contributed issues, code and comments for this release:

[&#x0040;ankane](https://github.com/ankane), [&#x0040;ashiklom](https://github.com/ashiklom), [&#x0040;bleutner](https://github.com/bleutner), [&#x0040;coatless](https://github.com/coatless), [&#x0040;dandelo](https://github.com/dandelo), [&#x0040;dleutnant](https://github.com/dleutnant), [&#x0040;dpprdan](https://github.com/dpprdan), [&#x0040;evanbiederstedt](https://github.com/evanbiederstedt), [&#x0040;gaborcsardi](https://github.com/gaborcsardi), [&#x0040;glin](https://github.com/glin), [&#x0040;gungne](https://github.com/gungne), [&#x0040;hadley](https://github.com/hadley), [&#x0040;heavywatal](https://github.com/heavywatal), [&#x0040;imanuelcostigan](https://github.com/imanuelcostigan), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jogrue](https://github.com/jogrue), [&#x0040;jonasfoe](https://github.com/jonasfoe), [&#x0040;joshuaulrich](https://github.com/joshuaulrich), [&#x0040;KasperSkytte](https://github.com/KasperSkytte), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;LiNk-NY](https://github.com/LiNk-NY), [&#x0040;lorenzwalthert](https://github.com/lorenzwalthert), [&#x0040;nbenn](https://github.com/nbenn), [&#x0040;overmar](https://github.com/overmar), [&#x0040;paulobrecht](https://github.com/paulobrecht), [&#x0040;pgensler](https://github.com/pgensler), [&#x0040;profandyfield](https://github.com/profandyfield), [&#x0040;rcannood](https://github.com/rcannood), [&#x0040;richfitz](https://github.com/richfitz), [&#x0040;robertdj](https://github.com/robertdj), [&#x0040;rtobar](https://github.com/rtobar), [&#x0040;surmann](https://github.com/surmann), [&#x0040;trinker](https://github.com/trinker), [&#x0040;VincentGuyader](https://github.com/VincentGuyader), [&#x0040;vsabarly](https://github.com/vsabarly), [&#x0040;vspinu](https://github.com/vspinu), [&#x0040;wch](https://github.com/wch), [&#x0040;wibeasley](https://github.com/wibeasley), [&#x0040;yutannihilation](https://github.com/yutannihilation), [&#x0040;eddelbuettel](https://github.com/eddelbuettel), [&#x0040;helix123](https://github.com/helix123), [&#x0040;HughParsonage](https://github.com/HughParsonage), [&#x0040;jrosen48](https://github.com/jrosen48), [&#x0040;noamross](https://github.com/noamross), [&#x0040;pat-s](https://github.com/pat-s), [&#x0040;wlandau-lilly](https://github.com/wlandau-lilly), [&#x0040;baptiste](https://github.com/baptiste), [&#x0040;bbolker](https://github.com/bbolker), [&#x0040;benjaminhlina](https://github.com/benjaminhlina), [&#x0040;colearendt](https://github.com/colearendt), [&#x0040;HenrikBengtsson](https://github.com/HenrikBengtsson), [&#x0040;jeroen](https://github.com/jeroen), [&#x0040;kevinushey](https://github.com/kevinushey), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;nitisethi28](https://github.com/nitisethi28), [&#x0040;schloerke](https://github.com/schloerke), [&#x0040;topepo](https://github.com/topepo), [&#x0040;lcolladotor](https://github.com/lcolladotor), [&#x0040;llrs](https://github.com/llrs), [&#x0040;patperry](https://github.com/patperry), [&#x0040;bgoodri](https://github.com/bgoodri), [&#x0040;dpastoor](https://github.com/dpastoor), [&#x0040;karldw](https://github.com/karldw), [&#x0040;kylebmetrum](https://github.com/kylebmetrum), [&#x0040;njtierney](https://github.com/njtierney), [&#x0040;richierocks](https://github.com/richierocks), [&#x0040;sangeetabhatia03](https://github.com/sangeetabhatia03), [&#x0040;theGreatWhiteShark](https://github.com/theGreatWhiteShark), [&#x0040;benmarwick](https://github.com/benmarwick), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;Dripdrop12](https://github.com/Dripdrop12), [&#x0040;friendly](https://github.com/friendly), [&#x0040;isteves](https://github.com/isteves), [&#x0040;mb706](https://github.com/mb706), [&#x0040;pitakakariki](https://github.com/pitakakariki), [&#x0040;prosoitos](https://github.com/prosoitos), [&#x0040;tetron](https://github.com/tetron), [&#x0040;yiufung](https://github.com/yiufung), [&#x0040;adomingues](https://github.com/adomingues), [&#x0040;alexholcombe](https://github.com/alexholcombe), [&#x0040;alexpghayes](https://github.com/alexpghayes), [&#x0040;andrie](https://github.com/andrie), [&#x0040;atheriel](https://github.com/atheriel), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;behrman](https://github.com/behrman), [&#x0040;bestdan](https://github.com/bestdan), [&#x0040;bfgray3](https://github.com/bfgray3), [&#x0040;bhaskarvk](https://github.com/bhaskarvk), [&#x0040;boshek](https://github.com/boshek), [&#x0040;cboettig](https://github.com/cboettig), [&#x0040;cderv](https://github.com/cderv), [&#x0040;chris-billingham](https://github.com/chris-billingham), [&#x0040;Chris-Engelhardt](https://github.com/Chris-Engelhardt), [&#x0040;chris-prener](https://github.com/chris-prener), [&#x0040;CorradoLanera](https://github.com/CorradoLanera), [&#x0040;dchiu911](https://github.com/dchiu911), [&#x0040;dirkschumacher](https://github.com/dirkschumacher), [&#x0040;dougmet](https://github.com/dougmet), [&#x0040;dragosmg](https://github.com/dragosmg), [&#x0040;duckmayr](https://github.com/duckmayr), [&#x0040;echasnovski](https://github.com/echasnovski), [&#x0040;eheinzen](https://github.com/eheinzen), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;GregorDeCillia](https://github.com/GregorDeCillia), [&#x0040;gvegayon](https://github.com/gvegayon), [&#x0040;gvelasq](https://github.com/gvelasq), [&#x0040;hafen](https://github.com/hafen), [&#x0040;HanjoStudy](https://github.com/HanjoStudy), [&#x0040;ijlyttle](https://github.com/ijlyttle), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;jackwasey](https://github.com/jackwasey), [&#x0040;jasonserviss](https://github.com/jasonserviss), [&#x0040;jayhesselberth](https://github.com/jayhesselberth), [&#x0040;jdblischak](https://github.com/jdblischak), [&#x0040;jjchern](https://github.com/jjchern), [&#x0040;jmgirard](https://github.com/jmgirard), [&#x0040;jonocarroll](https://github.com/jonocarroll), [&#x0040;jsta](https://github.com/jsta), [&#x0040;karawoo](https://github.com/karawoo), [&#x0040;katrinleinweber](https://github.com/katrinleinweber), [&#x0040;kiwiroy](https://github.com/kiwiroy), [&#x0040;lbusett](https://github.com/lbusett), [&#x0040;lwjohnst86](https://github.com/lwjohnst86), [&#x0040;maelle](https://github.com/maelle), [&#x0040;maislind](https://github.com/maislind), [&#x0040;malcolmbarrett](https://github.com/malcolmbarrett), [&#x0040;markdly](https://github.com/markdly), [&#x0040;martinjhnhadley](https://github.com/martinjhnhadley), [&#x0040;maurolepore](https://github.com/maurolepore), [&#x0040;mdlincoln](https://github.com/mdlincoln), [&#x0040;mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [&#x0040;mixtrak](https://github.com/mixtrak), [&#x0040;muschellij2](https://github.com/muschellij2), [&#x0040;PeteHaitch](https://github.com/PeteHaitch), [&#x0040;rdrivers](https://github.com/rdrivers), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;rorynolan](https://github.com/rorynolan), [&#x0040;s-fleck](https://github.com/s-fleck), [&#x0040;seankross](https://github.com/seankross), [&#x0040;strboul](https://github.com/strboul), [&#x0040;tjmahr](https://github.com/tjmahr), [&#x0040;uribo](https://github.com/uribo), [&#x0040;vnijs](https://github.com/vnijs), and [&#x0040;webbedfeet](https://github.com/webbedfeet)

[R Packages]: http://r-pkgs.had.co.nz/
[Conscious uncoupling]: https://web.archive.org/web/20140326060230/http://www.goop.com/journal/be/conscious-uncoupling
[rcmdcheck]: https://cran.r-project.org/package=rcmdcheck
[spelling]: https://cran.r-project.org/package=spelling
