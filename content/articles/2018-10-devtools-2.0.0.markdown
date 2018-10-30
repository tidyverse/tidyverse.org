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
changes](http://devtools.r-lib.org/news/index.html#breaking-changes)
section of devtools'
[NEWS](https://github.com/r-lib/devtools/blob/master/NEWS.md). If you
discover something missing, please let us know so we can add it.

## Conscious uncoupling

This release splits the functionality in devtools into a number of smaller
packages which are simpler to develop and also easier for other packages to
depend on. In particular the following packages have been spun off in what we
are calling the [conscious uncoupling] of devtools.

* [remotes](https://remotes.r-lib.org): Installs packages (i.e.
  `install_github()`).
* [pkgbuild](https://github.com/r-lib/pkgbuild): Builds binary packages
  (including checking if build tools are available) (i.e. `build()`).
* [pkgload](https://github.com/r-lib/pkgload): Simulates package loading (i.e.
  `load_all()`).
* [rcmdcheck](https://github.com/r-lib/rcmdcheck): Runs `R CMD check` and
  reports the results (i.e. `check()`).
* [revdepcheck](https://github.com/r-lib/revdepcheck): Runs `R CMD check` on
  all reverse dependencies, and figures out what has changed since the last CRAN
  release (i.e. `revdep_check()`).
* [sessioninfo](https://github.com/r-lib/sessioninfo): R session info (i.e.
  `session_info()`).
* [usethis](https://usethis.r-lib.org): Automates package setup (i.e.
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
[Changelog](http://devtools.r-lib.org/news/index.html).

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

This requires you use a [standard naming
convention](http://style.tidyverse.org/tests.html) for your tests, e.g. if you
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
[&#xFF20;ankane](https://github.com/ankane), [&#xFF20;ashiklom](https://github.com/ashiklom), [&#xFF20;bleutner](https://github.com/bleutner), [&#xFF20;coatless](https://github.com/coatless), [&#xFF20;dandelo](https://github.com/dandelo), [&#xFF20;dleutnant](https://github.com/dleutnant), [&#xFF20;dpprdan](https://github.com/dpprdan), [&#xFF20;evanbiederstedt](https://github.com/evanbiederstedt), [&#xFF20;gaborcsardi](https://github.com/gaborcsardi), [&#xFF20;glin](https://github.com/glin), [&#xFF20;gungne](https://github.com/gungne), [&#xFF20;hadley](https://github.com/hadley), [&#xFF20;heavywatal](https://github.com/heavywatal), [&#xFF20;imanuelcostigan](https://github.com/imanuelcostigan), [&#xFF20;jennybc](https://github.com/jennybc), [&#xFF20;jimhester](https://github.com/jimhester), [&#xFF20;jogrue](https://github.com/jogrue), [&#xFF20;jonasfoe](https://github.com/jonasfoe), [&#xFF20;joshuaulrich](https://github.com/joshuaulrich), [&#xFF20;jsal13](https://github.com/jsal13), [&#xFF20;KasperSkytte](https://github.com/KasperSkytte), [&#xFF20;krlmlr](https://github.com/krlmlr), [&#xFF20;LiNk-NY](https://github.com/LiNk-NY), [&#xFF20;lorenzwalthert](https://github.com/lorenzwalthert), [&#xFF20;nbenn](https://github.com/nbenn), [&#xFF20;overmar](https://github.com/overmar), [&#xFF20;paulobrecht](https://github.com/paulobrecht), [&#xFF20;pgensler](https://github.com/pgensler), [&#xFF20;profandyfield](https://github.com/profandyfield), [&#xFF20;r-cheologist](https://github.com/r-cheologist), [&#xFF20;rcannood](https://github.com/rcannood), [&#xFF20;richfitz](https://github.com/richfitz), [&#xFF20;robertdj](https://github.com/robertdj), [&#xFF20;rtobar](https://github.com/rtobar), [&#xFF20;surmann](https://github.com/surmann), [&#xFF20;trinker](https://github.com/trinker), [&#xFF20;VincentGuyader](https://github.com/VincentGuyader), [&#xFF20;vsabarly](https://github.com/vsabarly), [&#xFF20;vspinu](https://github.com/vspinu), [&#xFF20;wch](https://github.com/wch), [&#xFF20;wibeasley](https://github.com/wibeasley), [&#xFF20;yutannihilation](https://github.com/yutannihilation), [&#xFF20;aravind-j](https://github.com/aravind-j), [&#xFF20;eddelbuettel](https://github.com/eddelbuettel), [&#xFF20;helix123](https://github.com/helix123), [&#xFF20;HughParsonage](https://github.com/HughParsonage), [&#xFF20;jrosen48](https://github.com/jrosen48), [&#xFF20;noamross](https://github.com/noamross), [&#xFF20;pat-s](https://github.com/pat-s), [&#xFF20;wlandau-lilly](https://github.com/wlandau-lilly), [&#xFF20;baptiste](https://github.com/baptiste), [&#xFF20;bbolker](https://github.com/bbolker), [&#xFF20;benjaminhlina](https://github.com/benjaminhlina), [&#xFF20;colearendt](https://github.com/colearendt), [&#xFF20;HenrikBengtsson](https://github.com/HenrikBengtsson), [&#xFF20;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#xFF20;jeroen](https://github.com/jeroen), [&#xFF20;kevinushey](https://github.com/kevinushey), [&#xFF20;lionel-](https://github.com/lionel-), [&#xFF20;nitisethi28](https://github.com/nitisethi28), [&#xFF20;schloerke](https://github.com/schloerke), [&#xFF20;topepo](https://github.com/topepo), [&#xFF20;lcolladotor](https://github.com/lcolladotor), [&#xFF20;llrs](https://github.com/llrs), [&#xFF20;patperry](https://github.com/patperry), [&#xFF20;bgoodri](https://github.com/bgoodri), [&#xFF20;dpastoor](https://github.com/dpastoor), [&#xFF20;karldw](https://github.com/karldw), [&#xFF20;kylebmetrum](https://github.com/kylebmetrum), [&#xFF20;njtierney](https://github.com/njtierney), [&#xFF20;richierocks](https://github.com/richierocks), [&#xFF20;sangeetabhatia03](https://github.com/sangeetabhatia03), [&#xFF20;theGreatWhiteShark](https://github.com/theGreatWhiteShark), [&#xFF20;benmarwick](https://github.com/benmarwick), [&#xFF20;billdenney](https://github.com/billdenney), [&#xFF20;Dripdrop12](https://github.com/Dripdrop12), [&#xFF20;friendly](https://github.com/friendly), [&#xFF20;isteves](https://github.com/isteves), [&#xFF20;mb706](https://github.com/mb706), [&#xFF20;pitakakariki](https://github.com/pitakakariki), [&#xFF20;prosoitos](https://github.com/prosoitos), [&#xFF20;tetron](https://github.com/tetron), [&#xFF20;yiufung](https://github.com/yiufung), [&#xFF20;adomingues](https://github.com/adomingues), [&#xFF20;alexholcombe](https://github.com/alexholcombe), [&#xFF20;alexpghayes](https://github.com/alexpghayes), [&#xFF20;andrie](https://github.com/andrie), [&#xFF20;atheriel](https://github.com/atheriel), [&#xFF20;batpigandme](https://github.com/batpigandme), [&#xFF20;behrman](https://github.com/behrman), [&#xFF20;bestdan](https://github.com/bestdan), [&#xFF20;bfgray3](https://github.com/bfgray3), [&#xFF20;bhaskarvk](https://github.com/bhaskarvk), [&#xFF20;boshek](https://github.com/boshek), [&#xFF20;cboettig](https://github.com/cboettig), [&#xFF20;cderv](https://github.com/cderv), [&#xFF20;chris-billingham](https://github.com/chris-billingham), [&#xFF20;Chris-Engelhardt](https://github.com/Chris-Engelhardt), [&#xFF20;chris-prener](https://github.com/chris-prener), [&#xFF20;CorradoLanera](https://github.com/CorradoLanera), [&#xFF20;dchiu911](https://github.com/dchiu911), [&#xFF20;dirkschumacher](https://github.com/dirkschumacher), [&#xFF20;dougmet](https://github.com/dougmet), [&#xFF20;dragosmg](https://github.com/dragosmg), [&#xFF20;duckmayr](https://github.com/duckmayr), [&#xFF20;echasnovski](https://github.com/echasnovski), [&#xFF20;eheinzen](https://github.com/eheinzen), [&#xFF20;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#xFF20;GregorDeCillia](https://github.com/GregorDeCillia), [&#xFF20;gvegayon](https://github.com/gvegayon), [&#xFF20;gvelasq](https://github.com/gvelasq), [&#xFF20;hafen](https://github.com/hafen), [&#xFF20;HanjoStudy](https://github.com/HanjoStudy), [&#xFF20;ijlyttle](https://github.com/ijlyttle), [&#xFF20;jackwasey](https://github.com/jackwasey), [&#xFF20;jasonserviss](https://github.com/jasonserviss), [&#xFF20;jayhesselberth](https://github.com/jayhesselberth), [&#xFF20;jdblischak](https://github.com/jdblischak), [&#xFF20;jjchern](https://github.com/jjchern), [&#xFF20;jmgirard](https://github.com/jmgirard), [&#xFF20;jonocarroll](https://github.com/jonocarroll), [&#xFF20;jsta](https://github.com/jsta), [&#xFF20;karawoo](https://github.com/karawoo), [&#xFF20;katrinleinweber](https://github.com/katrinleinweber), [&#xFF20;kiwiroy](https://github.com/kiwiroy), [&#xFF20;lbusett](https://github.com/lbusett), [&#xFF20;lwjohnst86](https://github.com/lwjohnst86), [&#xFF20;maelle](https://github.com/maelle), [&#xFF20;maislind](https://github.com/maislind), [&#xFF20;malcolmbarrett](https://github.com/malcolmbarrett), [&#xFF20;markdly](https://github.com/markdly), [&#xFF20;martinjhnhadley](https://github.com/martinjhnhadley), [&#xFF20;maurolepore](https://github.com/maurolepore), [&#xFF20;mdlincoln](https://github.com/mdlincoln), [&#xFF20;mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [&#xFF20;mixtrak](https://github.com/mixtrak), [&#xFF20;muschellij2](https://github.com/muschellij2), [&#xFF20;nijibabulu](https://github.com/nijibabulu), [&#xFF20;PeteHaitch](https://github.com/PeteHaitch), [&#xFF20;rdrivers](https://github.com/rdrivers), [&#xFF20;romainfrancois](https://github.com/romainfrancois), [&#xFF20;rorynolan](https://github.com/rorynolan), [&#xFF20;s-fleck](https://github.com/s-fleck), [&#xFF20;seankross](https://github.com/seankross), [&#xFF20;strboul](https://github.com/strboul), [&#xFF20;tjmahr](https://github.com/tjmahr), [&#xFF20;uribo](https://github.com/uribo), [&#xFF20;vnijs](https://github.com/vnijs), [&#xFF20;webbedfeet](https://github.com/webbedfeet), [&#xFF20;1beb](https://github.com/1beb), [&#xFF20;ackleymi](https://github.com/ackleymi), [&#xFF20;akubisch](https://github.com/akubisch), [&#xFF20;alexilliamson](https://github.com/alexilliamson), [&#xFF20;alistaire47](https://github.com/alistaire47), [&#xFF20;amilenkovic](https://github.com/amilenkovic), [&#xFF20;amstilp](https://github.com/amstilp), [&#xFF20;AmundsenJunior](https://github.com/AmundsenJunior), [&#xFF20;AndreMikulec](https://github.com/AndreMikulec), [&#xFF20;andrewrech](https://github.com/andrewrech), [&#xFF20;andriuking](https://github.com/andriuking), [&#xFF20;anhqle](https://github.com/anhqle), [&#xFF20;Ashilex](https://github.com/Ashilex), [&#xFF20;Bandytwin](https://github.com/Bandytwin), [&#xFF20;bastistician](https://github.com/bastistician), [&#xFF20;BenoitLondon](https://github.com/BenoitLondon), [&#xFF20;bgctw](https://github.com/bgctw), [&#xFF20;BillPetti](https://github.com/BillPetti), [&#xFF20;bioinformatist](https://github.com/bioinformatist), [&#xFF20;bioticinteractions](https://github.com/bioticinteractions), [&#xFF20;Bustami](https://github.com/Bustami), [&#xFF20;carlganz](https://github.com/carlganz), [&#xFF20;cbail](https://github.com/cbail), [&#xFF20;cdeterman](https://github.com/cdeterman), [&#xFF20;cfhammill](https://github.com/cfhammill), [&#xFF20;chiarapiccino](https://github.com/chiarapiccino), [&#xFF20;ChrisMuir](https://github.com/ChrisMuir), [&#xFF20;ck37](https://github.com/ck37), [&#xFF20;cklunch](https://github.com/cklunch), [&#xFF20;courtiol](https://github.com/courtiol), [&#xFF20;crossxwill](https://github.com/crossxwill), [&#xFF20;daattali](https://github.com/daattali), [&#xFF20;damianooldoni](https://github.com/damianooldoni), [&#xFF20;darsoo](https://github.com/darsoo), [&#xFF20;dataisdata](https://github.com/dataisdata), [&#xFF20;DavisVaughan](https://github.com/DavisVaughan), [&#xFF20;dbaston](https://github.com/dbaston), [&#xFF20;deephoot](https://github.com/deephoot), [&#xFF20;dfrankow](https://github.com/dfrankow), [&#xFF20;DiogoFerrari](https://github.com/DiogoFerrari), [&#xFF20;DivadNojnarg](https://github.com/DivadNojnarg), [&#xFF20;djm158](https://github.com/djm158), [&#xFF20;djvanderlaan](https://github.com/djvanderlaan), [&#xFF20;dmenne](https://github.com/dmenne), [&#xFF20;dmurdoch](https://github.com/dmurdoch), [&#xFF20;DocOfi](https://github.com/DocOfi), [&#xFF20;dracodoc](https://github.com/dracodoc), [&#xFF20;dtelad11](https://github.com/dtelad11), [&#xFF20;EmilBode](https://github.com/EmilBode), [&#xFF20;epurdom](https://github.com/epurdom), [&#xFF20;Fazendaaa](https://github.com/Fazendaaa), [&#xFF20;feng-li](https://github.com/feng-li), [&#xFF20;FilipeamTeixeira](https://github.com/FilipeamTeixeira), [&#xFF20;flying-sheep](https://github.com/flying-sheep), [&#xFF20;fmichonneau](https://github.com/fmichonneau), [&#xFF20;gbouzill](https://github.com/gbouzill), [&#xFF20;GeoBosh](https://github.com/GeoBosh), [&#xFF20;gilbertocamara](https://github.com/gilbertocamara), [&#xFF20;Gioparra91](https://github.com/Gioparra91), [&#xFF20;gitter-badger](https://github.com/gitter-badger), [&#xFF20;goranbrostrom](https://github.com/goranbrostrom), [&#xFF20;guhjy](https://github.com/guhjy), [&#xFF20;gwarnes-mdsol](https://github.com/gwarnes-mdsol), [&#xFF20;gzagatti](https://github.com/gzagatti), [&#xFF20;ha0ye](https://github.com/ha0ye), [&#xFF20;holgerbrandl](https://github.com/holgerbrandl), [&#xFF20;Hong-Revo](https://github.com/Hong-Revo), [&#xFF20;hrbrmstr](https://github.com/hrbrmstr), [&#xFF20;hughjonesd](https://github.com/hughjonesd), [&#xFF20;ianmcook](https://github.com/ianmcook), [&#xFF20;Isaacsh](https://github.com/Isaacsh), [&#xFF20;Jadamso](https://github.com/Jadamso), [&#xFF20;james-atkins](https://github.com/james-atkins), [&#xFF20;JamesSteeleII](https://github.com/JamesSteeleII), [&#xFF20;jceleste1991](https://github.com/jceleste1991), [&#xFF20;jefshe](https://github.com/jefshe), [&#xFF20;jiaqitony](https://github.com/jiaqitony), [&#xFF20;JiaxiangBU](https://github.com/JiaxiangBU), [&#xFF20;jkraut](https://github.com/jkraut), [&#xFF20;joeddav](https://github.com/joeddav), [&#xFF20;JohnMount](https://github.com/JohnMount), [&#xFF20;joncfoo](https://github.com/joncfoo), [&#xFF20;jonkeane](https://github.com/jonkeane), [&#xFF20;josherrickson](https://github.com/josherrickson), [&#xFF20;JustinMShea](https://github.com/JustinMShea), [&#xFF20;KallyopeBio](https://github.com/KallyopeBio), [&#xFF20;kanasethu](https://github.com/kanasethu), [&#xFF20;karlropkins](https://github.com/karlropkins), [&#xFF20;Keaton1188](https://github.com/Keaton1188), [&#xFF20;kemin711](https://github.com/kemin711), [&#xFF20;kenahoo](https://github.com/kenahoo), [&#xFF20;kendonB](https://github.com/kendonB), [&#xFF20;kimyen](https://github.com/kimyen), [&#xFF20;klmr](https://github.com/klmr), [&#xFF20;kmcconeghy](https://github.com/kmcconeghy), [&#xFF20;komalsrathi](https://github.com/komalsrathi), [&#xFF20;krshedd](https://github.com/krshedd), [&#xFF20;layik](https://github.com/layik), [&#xFF20;lindbrook](https://github.com/lindbrook), [&#xFF20;lucacerone](https://github.com/lucacerone), [&#xFF20;magic-lantern](https://github.com/magic-lantern), [&#xFF20;malwinare](https://github.com/malwinare), [&#xFF20;MansMeg](https://github.com/MansMeg), [&#xFF20;MarcHiggins](https://github.com/MarcHiggins), [&#xFF20;MarkEdmondson1234](https://github.com/MarkEdmondson1234), [&#xFF20;martin11112](https://github.com/martin11112), [&#xFF20;mattfidler](https://github.com/mattfidler), [&#xFF20;mdavy86](https://github.com/mdavy86), [&#xFF20;meowcat](https://github.com/meowcat), [&#xFF20;mhines-usgs](https://github.com/mhines-usgs), [&#xFF20;MichaelM27](https://github.com/MichaelM27), [&#xFF20;michaelwhammer](https://github.com/michaelwhammer), [&#xFF20;mikemeredith](https://github.com/mikemeredith), [&#xFF20;mikldk](https://github.com/mikldk), [&#xFF20;MilesMcBain](https://github.com/MilesMcBain), [&#xFF20;mjpnijmeijer](https://github.com/mjpnijmeijer), [&#xFF20;mkearney](https://github.com/mkearney), [&#xFF20;mkhezr](https://github.com/mkhezr), [&#xFF20;mojaveazure](https://github.com/mojaveazure), [&#xFF20;moodymudskipper](https://github.com/moodymudskipper), [&#xFF20;MrFlick](https://github.com/MrFlick), [&#xFF20;mroemer](https://github.com/mroemer), [&#xFF20;mrustl](https://github.com/mrustl), [&#xFF20;ms609](https://github.com/ms609), [&#xFF20;msberends](https://github.com/msberends), [&#xFF20;mtmorgan](https://github.com/mtmorgan), [&#xFF20;mvuorre](https://github.com/mvuorre), [&#xFF20;myaseen208](https://github.com/myaseen208), [&#xFF20;navdeep-G](https://github.com/navdeep-G), [&#xFF20;neekro](https://github.com/neekro), [&#xFF20;Neil-Schneider](https://github.com/Neil-Schneider), [&#xFF20;ngreifer](https://github.com/ngreifer), [&#xFF20;nick-youngblut](https://github.com/nick-youngblut), [&#xFF20;nmattia](https://github.com/nmattia), [&#xFF20;ntdef](https://github.com/ntdef), [&#xFF20;okayaa](https://github.com/okayaa), [&#xFF20;paternogbc](https://github.com/paternogbc), [&#xFF20;paul-buerkner](https://github.com/paul-buerkner), [&#xFF20;paulmartins](https://github.com/paulmartins), [&#xFF20;pavel-filatov](https://github.com/pavel-filatov), [&#xFF20;Paxanator](https://github.com/Paxanator), [&#xFF20;peterhurford](https://github.com/peterhurford), [&#xFF20;petermeissner](https://github.com/petermeissner), [&#xFF20;pfgherardini](https://github.com/pfgherardini), [&#xFF20;plantarum](https://github.com/plantarum), [&#xFF20;potterzot](https://github.com/potterzot), [&#xFF20;privefl](https://github.com/privefl), [&#xFF20;qpcg](https://github.com/qpcg), [&#xFF20;renkun-ken](https://github.com/renkun-ken), [&#xFF20;renozao](https://github.com/renozao), [&#xFF20;rpruim](https://github.com/rpruim), [&#xFF20;RS-eco](https://github.com/RS-eco), [&#xFF20;RSIGitHubAdmin](https://github.com/RSIGitHubAdmin), [&#xFF20;sammo3182](https://github.com/sammo3182), [&#xFF20;SanVerhavert](https://github.com/SanVerhavert), [&#xFF20;saurfang](https://github.com/saurfang), [&#xFF20;sfirke](https://github.com/sfirke), [&#xFF20;ShanSabri](https://github.com/ShanSabri), [&#xFF20;skhiggins](https://github.com/skhiggins), [&#xFF20;SrinivasTammana](https://github.com/SrinivasTammana), [&#xFF20;StanleyXu](https://github.com/StanleyXu), [&#xFF20;statquant](https://github.com/statquant), [&#xFF20;stla](https://github.com/stla), [&#xFF20;stumoodie](https://github.com/stumoodie), [&#xFF20;sushilashenoy](https://github.com/sushilashenoy), [&#xFF20;Swarje](https://github.com/Swarje), [&#xFF20;SymbolixAU](https://github.com/SymbolixAU), [&#xFF20;talgalili](https://github.com/talgalili), [&#xFF20;tbates](https://github.com/tbates), [&#xFF20;tfitzhughilx](https://github.com/tfitzhughilx), [&#xFF20;thk686](https://github.com/thk686), [&#xFF20;ThorleyJack](https://github.com/ThorleyJack), [&#xFF20;TinkaMiau](https://github.com/TinkaMiau), [&#xFF20;TKoscik](https://github.com/TKoscik), [&#xFF20;tungmilan](https://github.com/tungmilan), [&#xFF20;twolodzko](https://github.com/twolodzko), [&#xFF20;unDocUMeantIt](https://github.com/unDocUMeantIt), [&#xFF20;vaibhav2903](https://github.com/vaibhav2903), [&#xFF20;vermouthmjl](https://github.com/vermouthmjl), [&#xFF20;vishnu1994](https://github.com/vishnu1994), [&#xFF20;wehc1](https://github.com/wehc1), [&#xFF20;wldnjs](https://github.com/wldnjs), [&#xFF20;wolski](https://github.com/wolski), [&#xFF20;xingbaodong](https://github.com/xingbaodong), [&#xFF20;Xinzhu-Fang](https://github.com/Xinzhu-Fang), [&#xFF20;YanpingGuo312](https://github.com/YanpingGuo312), and [&#xFF20;yurivict](https://github.com/yurivict)

[devtools]: https://devtools.r-lib.org
[R Packages]: http://r-pkgs.had.co.nz/
[Conscious uncoupling]: https://web.archive.org/web/20140326060230/http://www.goop.com/journal/be/conscious-uncoupling
[rcmdcheck]: https://cran.r-project.org/package=rcmdcheck
[spelling]: https://cran.r-project.org/package=spelling

