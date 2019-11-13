---
title: dplyr 0.8.3
slug: dplyr-0-8-3
author: Romain François
description: >
  dplyr 0.8.3 is now on CRAN.
date: '2019-07-04'
categories: [package]
tags:
  - dplyr
  - tidyverse
photo:
  url: https://unsplash.com/photos/OxK32aLJXWU
  author: Krzysztof Niewolny
---




## Introduction

We're pleased (and a little embarrassed) to announce the release of dplyr 0.8.3 on CRAN 😬 !

This is an emergency release, one week after [0.8.2](https://www.tidyverse.org/articles/2019/06/dplyr-0-8-2/)
to fix a major performance regression as reported by the community on twitter. 

## Nostra culpa

This [commit](https://github.com/tidyverse/dplyr/commit/036de90fbf9e3eef72c015982a5d1294d2157a2c#r34165423) was pushed to
[dplyr](https://dplyr.tidyverse.org) on May 10, as a seemingly very harmless update to better support list
columns being used in [summarise()](https://dplyr.tidyverse.org/reference/summarise.html).

In addition to the changes that were necessary to fix the problem reported in [issue 4349](https://github.com/tidyverse/dplyr/issues/4349),
the commit removed two lines of code in a very central piece of [dplyr](https://dplyr.tidyverse.org) infrastructure,
namely its data mask layout.

As part of [dplyr 0.8.0](https://www.tidyverse.org/articles/2019/02/dplyr-0-8-0/), internals of the data mask layout has
dramatically changed and uses a data mask composed of two environments. The first environment contains a set of active
bindings for each of the columns in the data frame to process, the first time a variable is used in an expression,
presumably on the first group, the active binding is resolved to get the relevant slice of that column. This is a
somewhat expensive operation, therefore subsequent groups pro actively materialise the slice of columns which are known
to be needed, using the second environment of the data mask.

The two lines that were removed by mistake are central to this system, without them each group would
invoke the costly active binding. Even worse, the list of indices of columns to be rematerialised,
as maintained by a vector of integers, would grow each time, so on the second group the column slice would
be materialized twice to be then forgotten, on the third group three times ...

Classic embarrassing quadratic performance regression.

## Thanks

Thanks to the community for quickly alerting us of the situation, the 🐌 had been
in the code base for almost two months but we had not noticed because our continuous
integration protects us from regressions in functionality, but not regression in performance.

We might investigate in that direction in the future.Thanks to all contributors for this release.

[&#x0040;ajkroeg](https://github.com/ajkroeg), [&#x0040;bschneidr](https://github.com/bschneidr), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;dhicks](https://github.com/dhicks), [&#x0040;gvfarns](https://github.com/gvfarns), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;romainfrancois](https://github.com/romainfrancois), and [&#x0040;shane-kercheval](https://github.com/shane-kercheval)
