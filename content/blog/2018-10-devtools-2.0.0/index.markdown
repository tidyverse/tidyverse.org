---
title: devtools 2.0.0
date: 2018-10-30
slug: devtools-2-0-0
author: Jim Hester
categories: [package]
tags:
  - devtools
  - r-lib
description: >
    Make package development easier by providing R functions that simplify and expedite common tasks.
photo:
  url: https://unsplash.com/photos/wEJK4q_YlNQ
  author: Hunter Haley
---

## Introduction

[devtools] 2.0.0 is now on CRAN!

devtools makes package development easier by providing R functions that
simplify and expedite common tasks. [R Packages] is a book based around this
workflow.

devtools 2.0.0 is a major release! It contains all work from the last major
release (1.13.0) more than a year and a half ago!

## Breaking changes

There are a handful of breaking changes in this release, mainly done in the
interest of simplifying and standardizing the function APIs.

The changes should affect relatively little user code, but have required
developers to make changes. Common errors and ways to work around them
as well as the full list of changes can be found in the [Breaking
changes](https://devtools.r-lib.org/news/index.html#breaking-changes)
section of devtools'
[NEWS](https://github.com/r-lib/devtools/blob/master/NEWS.md). If you
discover something missing, please let us know so we can add it.

## Conscious uncoupling

This release splits the functionality in devtools into a number of smaller
packages which are simpler to develop and also easier for other packages to
depend on. In particular the following packages have been spun off in what we
are calling the [conscious uncoupling] of devtools.

* [remotes](https://remotes.r-lib.org): Installs packages (e.g.
  `install_github()`).
* [pkgbuild](https://github.com/r-lib/pkgbuild): Builds binary packages
  (including checking if build tools are available) (e.g. `build()`).
* [pkgload](https://github.com/r-lib/pkgload): Simulates package loading (e.g.
  `load_all()`).
* [rcmdcheck](https://github.com/r-lib/rcmdcheck): Runs `R CMD check` and
  reports the results (e.g. `check()`).
* [revdepcheck](https://github.com/r-lib/revdepcheck): Runs `R CMD check` on
  all reverse dependencies, and figures out what has changed since the last CRAN
  release (e.g. `revdep_check()`).
* [sessioninfo](https://github.com/r-lib/sessioninfo): R session info (e.g.
  `session_info()`).
* [usethis](https://usethis.r-lib.org): Automates package setup (e.g.
  `use_test()`).

devtools will remain the primary package developers will interact with when
writing R packages; it will just rely on these other packages internally
for most of the functionality.

Generally, you should not need to worry about these different packages, because
devtools installs them all automatically. You will need to care, however, if
you're filing a bug because reporting it at the correct place will lead to a
speedier resolution.

Package developers who wish to depend on devtools features should also pay
attention to which package the functionality is coming from and depend on that
rather than devtools. In most cases packages should not depend on devtools
directly. This is similar to the situation with the [tidyverse
package](https://www.tidyverse.org/articles/2018/06/tidyverse-not-for-packages/).

## New features

The majority of the work for this release was related to bugfixes and
infrastructure improvements, but there are also some new features you may
notice.

As always a complete list of all the changes is available in the package
[Changelog](https://devtools.r-lib.org/news/index.html).

### Upgrade menu

All of the install functions (e.g. `install_github()`) now prompt the user with
a menu if there are dependencies of the package being installed which are
outdated. This allows the user to pick which if any they would like to upgrade.

Previous versions of devtools always upgraded these packages automatically by
default, which sometimes was frustrating when you simply wanted to install one
package.

When used non-interactively the install functions work like the previous default of
always upgrading outdated packages.

<p align="center">
<img src="/images/devtools-2.0.0/upgrade-menu.png" alt="upgrade menu">
</p>

The menu respects the `menu.graphics` option, so set `options(menu.graphics =
FALSE)` in your .Rprofile if you prefer text based menus, or `TRUE` if you
prefer graphical widgets.

### Improved check output

`check()` now uses the [rcmdcheck] package, which has much richer, more colorful
output to the check results, making check failures much easier to see.

<p align="center">
<a href="https://github.com/r-lib/rcmdcheck">
<img src="https://raw.githubusercontent.com/r-lib/rcmdcheck/e2be6b3111c56ac33a2fb89c773d96eafe6dfa22/tools/rcmdcheck.gif" alt="rcmdcheck output" width="700">
</a>
</p>

### Testing single files

devtools now includes functions (`test_file()` and `test_coverage_file()`) to
improve development of a single file. Rather than running all
tests, or manually supplying a `filter` argument to restrict the tests
`test_file()` automatically runs the corresponding tests for a given source
file. These functions make the feedback loop when developing new features
quicker as you only run the relevant tests for the file you are editing.

This requires you use a [standard naming
convention](https://style.tidyverse.org/tests.html) for your tests, e.g. if you
have a source file `R/featureA.R` the corresponding test file would be
`tests/testthat/test-featureR.R`.

The tests file to run is automatically detected from the open file in RStudio (if
available), so you can call `test_file()` with either the source file or
the test file open. A corresponding `test_coverage_file()`
function shows the test code coverage for a single source file.

There is also a `test_coverage()` function to report test coverage for your
whole package.

These functions have [RStudio addins](https://rstudio.github.io/rstudioaddins/)
which allows you to [ bind them to shortcut
keys](https://rstudio.github.io/rstudioaddins/#keyboard-shorcuts).

Shortcuts we recommend

<style>
kbd {
  border: 1px solid #aaa;
  border-radius: 0.2em;
  background-color: #f9f9f9;
  padding: 0.1em 0.3em;
}
td,th {
  padding: 0.4em;
}
</style>

| Function                 | Windows shortcut                                | macOS shortcut                                        |
| ------------------------ | ------------------------------------------------|------------------------------------------------------ |
| `test_file()`            | <kbd>Ctrl</kbd>+<kbd>T</kbd>                    | <kbd>Command ⌘ </kbd>+<kbd>T</kbd>                    |
| `test_coverage_file()`   | <kbd>Ctrl</kbd>+<kbd>R</kbd>                    | <kbd>Command ⌘ </kbd>+<kbd>R</kbd>                    |
| `test_coverage()`        | <kbd>Ctrl</kbd>+<kbd>Shift ⇧</kbd>+<kbd>R</kbd> | <kbd>Command ⌘ </kbd>+<kbd>Shift ⇧</kbd>+<kbd>R</kbd> |

<br>

### Spell checking

`spell_check()` can be used to check the spelling of package documentation
using the [spelling] package. We have found checking spelling before a release
often catches a number of errors. For more details on features of
the spelling package see the [rOpenSci
spelling release post](https://ropensci.org/technotes/2017/09/07/spelling-release/).

Also see
[usethis::use_spell_check()](https://usethis.r-lib.org/reference/use_spell_check.html)
to have spell checking for the package performed automatically during `devtools::check()`.

## Acknowledgements

This release was truly a team effort! Much of the work in the uncoupled
packages, particularly the remotes, rcmdcheck, revdepcheck and sessioninfo
packages was done by Gábor Csárdi. Hadley Wickham worked extensively on
pkgbuild, pkgload and usethis (as well as being responsible for most of the
original code in devtools) and Jenny Bryan had major contributions to the
usethis package.





The work spanned over 8 packages (devtools + the uncoupled packages) and
includes 1,579 commits, 1,487 closed issues and 107 different code contributors!



We are of course grateful to _all_ of the *336* people who contributed not just code, but also issues and comments for this release:
[&#x0040;ankane](https://github.com/ankane), [&#x0040;ashiklom](https://github.com/ashiklom), [&#x0040;bleutner](https://github.com/bleutner), [&#x0040;coatless](https://github.com/coatless), [&#x0040;dandelo](https://github.com/dandelo), [&#x0040;dleutnant](https://github.com/dleutnant), [&#x0040;dpprdan](https://github.com/dpprdan), [&#x0040;evanbiederstedt](https://github.com/evanbiederstedt), [&#x0040;gaborcsardi](https://github.com/gaborcsardi), [&#x0040;glin](https://github.com/glin), [&#x0040;gungne](https://github.com/gungne), [&#x0040;hadley](https://github.com/hadley), [&#x0040;heavywatal](https://github.com/heavywatal), [&#x0040;imanuelcostigan](https://github.com/imanuelcostigan), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jogrue](https://github.com/jogrue), [&#x0040;jonasfoe](https://github.com/jonasfoe), [&#x0040;joshuaulrich](https://github.com/joshuaulrich), [&#x0040;jsal13](https://github.com/jsal13), [&#x0040;KasperSkytte](https://github.com/KasperSkytte), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;LiNk-NY](https://github.com/LiNk-NY), [&#x0040;lorenzwalthert](https://github.com/lorenzwalthert), [&#x0040;nbenn](https://github.com/nbenn), [&#x0040;overmar](https://github.com/overmar), [&#x0040;paulobrecht](https://github.com/paulobrecht), [&#x0040;pgensler](https://github.com/pgensler), [&#x0040;profandyfield](https://github.com/profandyfield), [&#x0040;r-cheologist](https://github.com/r-cheologist), [&#x0040;rcannood](https://github.com/rcannood), [&#x0040;richfitz](https://github.com/richfitz), [&#x0040;robertdj](https://github.com/robertdj), [&#x0040;rtobar](https://github.com/rtobar), [&#x0040;surmann](https://github.com/surmann), [&#x0040;trinker](https://github.com/trinker), [&#x0040;VincentGuyader](https://github.com/VincentGuyader), [&#x0040;vsabarly](https://github.com/vsabarly), [&#x0040;vspinu](https://github.com/vspinu), [&#x0040;wch](https://github.com/wch), [&#x0040;wibeasley](https://github.com/wibeasley), [&#x0040;yutannihilation](https://github.com/yutannihilation), [&#x0040;aravind-j](https://github.com/aravind-j), [&#x0040;eddelbuettel](https://github.com/eddelbuettel), [&#x0040;helix123](https://github.com/helix123), [&#x0040;HughParsonage](https://github.com/HughParsonage), [&#x0040;jrosen48](https://github.com/jrosen48), [&#x0040;noamross](https://github.com/noamross), [&#x0040;pat-s](https://github.com/pat-s), [&#x0040;wlandau-lilly](https://github.com/wlandau-lilly), [&#x0040;baptiste](https://github.com/baptiste), [&#x0040;bbolker](https://github.com/bbolker), [&#x0040;benjaminhlina](https://github.com/benjaminhlina), [&#x0040;colearendt](https://github.com/colearendt), [&#x0040;HenrikBengtsson](https://github.com/HenrikBengtsson), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;jeroen](https://github.com/jeroen), [&#x0040;kevinushey](https://github.com/kevinushey), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;nitisethi28](https://github.com/nitisethi28), [&#x0040;schloerke](https://github.com/schloerke), [&#x0040;topepo](https://github.com/topepo), [&#x0040;lcolladotor](https://github.com/lcolladotor), [&#x0040;llrs](https://github.com/llrs), [&#x0040;patperry](https://github.com/patperry), [&#x0040;bgoodri](https://github.com/bgoodri), [&#x0040;dpastoor](https://github.com/dpastoor), [&#x0040;karldw](https://github.com/karldw), [&#x0040;kylebmetrum](https://github.com/kylebmetrum), [&#x0040;njtierney](https://github.com/njtierney), [&#x0040;richierocks](https://github.com/richierocks), [&#x0040;sangeetabhatia03](https://github.com/sangeetabhatia03), [&#x0040;theGreatWhiteShark](https://github.com/theGreatWhiteShark), [&#x0040;benmarwick](https://github.com/benmarwick), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;Dripdrop12](https://github.com/Dripdrop12), [&#x0040;friendly](https://github.com/friendly), [&#x0040;isteves](https://github.com/isteves), [&#x0040;mb706](https://github.com/mb706), [&#x0040;pitakakariki](https://github.com/pitakakariki), [&#x0040;prosoitos](https://github.com/prosoitos), [&#x0040;tetron](https://github.com/tetron), [&#x0040;yiufung](https://github.com/yiufung), [&#x0040;adomingues](https://github.com/adomingues), [&#x0040;alexholcombe](https://github.com/alexholcombe), [&#x0040;alexpghayes](https://github.com/alexpghayes), [&#x0040;andrie](https://github.com/andrie), [&#x0040;atheriel](https://github.com/atheriel), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;behrman](https://github.com/behrman), [&#x0040;bestdan](https://github.com/bestdan), [&#x0040;bfgray3](https://github.com/bfgray3), [&#x0040;bhaskarvk](https://github.com/bhaskarvk), [&#x0040;boshek](https://github.com/boshek), [&#x0040;cboettig](https://github.com/cboettig), [&#x0040;cderv](https://github.com/cderv), [&#x0040;chris-billingham](https://github.com/chris-billingham), [&#x0040;Chris-Engelhardt](https://github.com/Chris-Engelhardt), [&#x0040;chris-prener](https://github.com/chris-prener), [&#x0040;CorradoLanera](https://github.com/CorradoLanera), [&#x0040;dchiu911](https://github.com/dchiu911), [&#x0040;dirkschumacher](https://github.com/dirkschumacher), [&#x0040;dougmet](https://github.com/dougmet), [&#x0040;dragosmg](https://github.com/dragosmg), [&#x0040;duckmayr](https://github.com/duckmayr), [&#x0040;echasnovski](https://github.com/echasnovski), [&#x0040;eheinzen](https://github.com/eheinzen), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;GregorDeCillia](https://github.com/GregorDeCillia), [&#x0040;gvegayon](https://github.com/gvegayon), [&#x0040;gvelasq](https://github.com/gvelasq), [&#x0040;hafen](https://github.com/hafen), [&#x0040;HanjoStudy](https://github.com/HanjoStudy), [&#x0040;ijlyttle](https://github.com/ijlyttle), [&#x0040;jackwasey](https://github.com/jackwasey), [&#x0040;jasonserviss](https://github.com/jasonserviss), [&#x0040;jayhesselberth](https://github.com/jayhesselberth), [&#x0040;jdblischak](https://github.com/jdblischak), [&#x0040;jjchern](https://github.com/jjchern), [&#x0040;jmgirard](https://github.com/jmgirard), [&#x0040;jonocarroll](https://github.com/jonocarroll), [&#x0040;jsta](https://github.com/jsta), [&#x0040;karawoo](https://github.com/karawoo), [&#x0040;katrinleinweber](https://github.com/katrinleinweber), [&#x0040;kiwiroy](https://github.com/kiwiroy), [&#x0040;lbusett](https://github.com/lbusett), [&#x0040;lwjohnst86](https://github.com/lwjohnst86), [&#x0040;maelle](https://github.com/maelle), [&#x0040;maislind](https://github.com/maislind), [&#x0040;malcolmbarrett](https://github.com/malcolmbarrett), [&#x0040;markdly](https://github.com/markdly), [&#x0040;martinjhnhadley](https://github.com/martinjhnhadley), [&#x0040;maurolepore](https://github.com/maurolepore), [&#x0040;mdlincoln](https://github.com/mdlincoln), [&#x0040;mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [&#x0040;mixtrak](https://github.com/mixtrak), [&#x0040;muschellij2](https://github.com/muschellij2), [&#x0040;nijibabulu](https://github.com/nijibabulu), [&#x0040;PeteHaitch](https://github.com/PeteHaitch), [&#x0040;rdrivers](https://github.com/rdrivers), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;rorynolan](https://github.com/rorynolan), [&#x0040;s-fleck](https://github.com/s-fleck), [&#x0040;seankross](https://github.com/seankross), [&#x0040;strboul](https://github.com/strboul), [&#x0040;tjmahr](https://github.com/tjmahr), [&#x0040;uribo](https://github.com/uribo), [&#x0040;vnijs](https://github.com/vnijs), [&#x0040;webbedfeet](https://github.com/webbedfeet), [&#x0040;1beb](https://github.com/1beb), [&#x0040;ackleymi](https://github.com/ackleymi), [&#x0040;akubisch](https://github.com/akubisch), [&#x0040;alexilliamson](https://github.com/alexilliamson), [&#x0040;alistaire47](https://github.com/alistaire47), [&#x0040;amilenkovic](https://github.com/amilenkovic), [&#x0040;amstilp](https://github.com/amstilp), [&#x0040;AmundsenJunior](https://github.com/AmundsenJunior), [&#x0040;AndreMikulec](https://github.com/AndreMikulec), [&#x0040;andrewrech](https://github.com/andrewrech), [&#x0040;andriuking](https://github.com/andriuking), [&#x0040;anhqle](https://github.com/anhqle), [&#x0040;Ashilex](https://github.com/Ashilex), [&#x0040;Bandytwin](https://github.com/Bandytwin), [&#x0040;bastistician](https://github.com/bastistician), [&#x0040;BenoitLondon](https://github.com/BenoitLondon), [&#x0040;bgctw](https://github.com/bgctw), [&#x0040;BillPetti](https://github.com/BillPetti), [&#x0040;bioinformatist](https://github.com/bioinformatist), [&#x0040;bioticinteractions](https://github.com/bioticinteractions), [&#x0040;Bustami](https://github.com/Bustami), [&#x0040;carlganz](https://github.com/carlganz), [&#x0040;cbail](https://github.com/cbail), [&#x0040;cdeterman](https://github.com/cdeterman), [&#x0040;cfhammill](https://github.com/cfhammill), [&#x0040;chiarapiccino](https://github.com/chiarapiccino), [&#x0040;ChrisMuir](https://github.com/ChrisMuir), [&#x0040;ck37](https://github.com/ck37), [&#x0040;cklunch](https://github.com/cklunch), [&#x0040;courtiol](https://github.com/courtiol), [&#x0040;crossxwill](https://github.com/crossxwill), [&#x0040;daattali](https://github.com/daattali), [&#x0040;damianooldoni](https://github.com/damianooldoni), [&#x0040;darsoo](https://github.com/darsoo), [&#x0040;dataisdata](https://github.com/dataisdata), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;dbaston](https://github.com/dbaston), [&#x0040;deephoot](https://github.com/deephoot), [&#x0040;dfrankow](https://github.com/dfrankow), [&#x0040;DiogoFerrari](https://github.com/DiogoFerrari), [&#x0040;DivadNojnarg](https://github.com/DivadNojnarg), [&#x0040;djm158](https://github.com/djm158), [&#x0040;djvanderlaan](https://github.com/djvanderlaan), [&#x0040;dmenne](https://github.com/dmenne), [&#x0040;dmurdoch](https://github.com/dmurdoch), [&#x0040;DocOfi](https://github.com/DocOfi), [&#x0040;dracodoc](https://github.com/dracodoc), [&#x0040;dtelad11](https://github.com/dtelad11), [&#x0040;EmilBode](https://github.com/EmilBode), [&#x0040;epurdom](https://github.com/epurdom), [&#x0040;Fazendaaa](https://github.com/Fazendaaa), [&#x0040;feng-li](https://github.com/feng-li), [&#x0040;FilipeamTeixeira](https://github.com/FilipeamTeixeira), [&#x0040;flying-sheep](https://github.com/flying-sheep), [&#x0040;fmichonneau](https://github.com/fmichonneau), [&#x0040;gbouzill](https://github.com/gbouzill), [&#x0040;GeoBosh](https://github.com/GeoBosh), [&#x0040;gilbertocamara](https://github.com/gilbertocamara), [&#x0040;Gioparra91](https://github.com/Gioparra91), [&#x0040;gitter-badger](https://github.com/gitter-badger), [&#x0040;goranbrostrom](https://github.com/goranbrostrom), [&#x0040;guhjy](https://github.com/guhjy), [&#x0040;gwarnes-mdsol](https://github.com/gwarnes-mdsol), [&#x0040;gzagatti](https://github.com/gzagatti), [&#x0040;ha0ye](https://github.com/ha0ye), [&#x0040;holgerbrandl](https://github.com/holgerbrandl), [&#x0040;Hong-Revo](https://github.com/Hong-Revo), [&#x0040;hrbrmstr](https://github.com/hrbrmstr), [&#x0040;hughjonesd](https://github.com/hughjonesd), [&#x0040;ianmcook](https://github.com/ianmcook), [&#x0040;Isaacsh](https://github.com/Isaacsh), [&#x0040;Jadamso](https://github.com/Jadamso), [&#x0040;james-atkins](https://github.com/james-atkins), [&#x0040;JamesSteeleII](https://github.com/JamesSteeleII), [&#x0040;jceleste1991](https://github.com/jceleste1991), [&#x0040;jefshe](https://github.com/jefshe), [&#x0040;jiaqitony](https://github.com/jiaqitony), [&#x0040;JiaxiangBU](https://github.com/JiaxiangBU), [&#x0040;jkraut](https://github.com/jkraut), [&#x0040;joeddav](https://github.com/joeddav), [&#x0040;JohnMount](https://github.com/JohnMount), [&#x0040;joncfoo](https://github.com/joncfoo), [&#x0040;jonkeane](https://github.com/jonkeane), [&#x0040;josherrickson](https://github.com/josherrickson), [&#x0040;JustinMShea](https://github.com/JustinMShea), [&#x0040;KallyopeBio](https://github.com/KallyopeBio), [&#x0040;kanasethu](https://github.com/kanasethu), [&#x0040;karlropkins](https://github.com/karlropkins), [&#x0040;Keaton1188](https://github.com/Keaton1188), [&#x0040;kemin711](https://github.com/kemin711), [&#x0040;kenahoo](https://github.com/kenahoo), [&#x0040;kendonB](https://github.com/kendonB), [&#x0040;kimyen](https://github.com/kimyen), [&#x0040;klmr](https://github.com/klmr), [&#x0040;kmcconeghy](https://github.com/kmcconeghy), [&#x0040;komalsrathi](https://github.com/komalsrathi), [&#x0040;krshedd](https://github.com/krshedd), [&#x0040;layik](https://github.com/layik), [&#x0040;lindbrook](https://github.com/lindbrook), [&#x0040;lucacerone](https://github.com/lucacerone), [&#x0040;magic-lantern](https://github.com/magic-lantern), [&#x0040;malwinare](https://github.com/malwinare), [&#x0040;MansMeg](https://github.com/MansMeg), [&#x0040;MarcHiggins](https://github.com/MarcHiggins), [&#x0040;MarkEdmondson1234](https://github.com/MarkEdmondson1234), [&#x0040;martin11112](https://github.com/martin11112), [&#x0040;mattfidler](https://github.com/mattfidler), [&#x0040;mdavy86](https://github.com/mdavy86), [&#x0040;meowcat](https://github.com/meowcat), [&#x0040;mhines-usgs](https://github.com/mhines-usgs), [&#x0040;MichaelM27](https://github.com/MichaelM27), [&#x0040;michaelwhammer](https://github.com/michaelwhammer), [&#x0040;mikemeredith](https://github.com/mikemeredith), [&#x0040;mikldk](https://github.com/mikldk), [&#x0040;MilesMcBain](https://github.com/MilesMcBain), [&#x0040;mjpnijmeijer](https://github.com/mjpnijmeijer), [&#x0040;mkearney](https://github.com/mkearney), [&#x0040;mkhezr](https://github.com/mkhezr), [&#x0040;mojaveazure](https://github.com/mojaveazure), [&#x0040;moodymudskipper](https://github.com/moodymudskipper), [&#x0040;MrFlick](https://github.com/MrFlick), [&#x0040;mroemer](https://github.com/mroemer), [&#x0040;mrustl](https://github.com/mrustl), [&#x0040;ms609](https://github.com/ms609), [&#x0040;msberends](https://github.com/msberends), [&#x0040;mtmorgan](https://github.com/mtmorgan), [&#x0040;mvuorre](https://github.com/mvuorre), [&#x0040;myaseen208](https://github.com/myaseen208), [&#x0040;navdeep-G](https://github.com/navdeep-G), [&#x0040;neekro](https://github.com/neekro), [&#x0040;Neil-Schneider](https://github.com/Neil-Schneider), [&#x0040;ngreifer](https://github.com/ngreifer), [&#x0040;nick-youngblut](https://github.com/nick-youngblut), [&#x0040;nmattia](https://github.com/nmattia), [&#x0040;ntdef](https://github.com/ntdef), [&#x0040;okayaa](https://github.com/okayaa), [&#x0040;paternogbc](https://github.com/paternogbc), [&#x0040;paul-buerkner](https://github.com/paul-buerkner), [&#x0040;paulmartins](https://github.com/paulmartins), [&#x0040;pavel-filatov](https://github.com/pavel-filatov), [&#x0040;Paxanator](https://github.com/Paxanator), [&#x0040;peterhurford](https://github.com/peterhurford), [&#x0040;petermeissner](https://github.com/petermeissner), [&#x0040;pfgherardini](https://github.com/pfgherardini), [&#x0040;plantarum](https://github.com/plantarum), [&#x0040;potterzot](https://github.com/potterzot), [&#x0040;privefl](https://github.com/privefl), [&#x0040;qpcg](https://github.com/qpcg), [&#x0040;renkun-ken](https://github.com/renkun-ken), [&#x0040;renozao](https://github.com/renozao), [&#x0040;rpruim](https://github.com/rpruim), [&#x0040;RS-eco](https://github.com/RS-eco), [&#x0040;RSIGitHubAdmin](https://github.com/RSIGitHubAdmin), [&#x0040;sammo3182](https://github.com/sammo3182), [&#x0040;SanVerhavert](https://github.com/SanVerhavert), [&#x0040;saurfang](https://github.com/saurfang), [&#x0040;sfirke](https://github.com/sfirke), [&#x0040;ShanSabri](https://github.com/ShanSabri), [&#x0040;skhiggins](https://github.com/skhiggins), [&#x0040;SrinivasTammana](https://github.com/SrinivasTammana), [&#x0040;StanleyXu](https://github.com/StanleyXu), [&#x0040;statquant](https://github.com/statquant), [&#x0040;stla](https://github.com/stla), [&#x0040;stumoodie](https://github.com/stumoodie), [&#x0040;sushilashenoy](https://github.com/sushilashenoy), [&#x0040;Swarje](https://github.com/Swarje), [&#x0040;SymbolixAU](https://github.com/SymbolixAU), [&#x0040;talgalili](https://github.com/talgalili), [&#x0040;tbates](https://github.com/tbates), [&#x0040;tfitzhughilx](https://github.com/tfitzhughilx), [&#x0040;thk686](https://github.com/thk686), [&#x0040;ThorleyJack](https://github.com/ThorleyJack), [&#x0040;TinkaMiau](https://github.com/TinkaMiau), [&#x0040;TKoscik](https://github.com/TKoscik), [&#x0040;tungmilan](https://github.com/tungmilan), [&#x0040;twolodzko](https://github.com/twolodzko), [&#x0040;unDocUMeantIt](https://github.com/unDocUMeantIt), [&#x0040;vaibhav2903](https://github.com/vaibhav2903), [&#x0040;vermouthmjl](https://github.com/vermouthmjl), [&#x0040;vishnu1994](https://github.com/vishnu1994), [&#x0040;wehc1](https://github.com/wehc1), [&#x0040;wldnjs](https://github.com/wldnjs), [&#x0040;wolski](https://github.com/wolski), [&#x0040;xingbaodong](https://github.com/xingbaodong), [&#x0040;Xinzhu-Fang](https://github.com/Xinzhu-Fang), [&#x0040;YanpingGuo312](https://github.com/YanpingGuo312), and [&#x0040;yurivict](https://github.com/yurivict)

[devtools]: https://devtools.r-lib.org
[R Packages]: http://r-pkgs.had.co.nz/
[Conscious uncoupling]: https://web.archive.org/web/20140326060230/http://www.goop.com/journal/be/conscious-uncoupling
[rcmdcheck]: https://cran.r-project.org/package=rcmdcheck
[spelling]: https://cran.r-project.org/package=spelling

