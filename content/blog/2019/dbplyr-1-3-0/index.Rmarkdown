---
title: dbplyr 1.3.0
author: Mara Averick
date: '2019-01-09'
slug: dbplyr-1-3-0
description: > 
  dbplyr 1.3.0 is now on CRAN.
categories:
  - package
photo:
  url: https://unsplash.com/photos/sk59I1qRfEM
  author: Scott Webb
---

We're stoked to announce that [dbplyr](https://dbplyr.tidyverse.org) 1.3.0 is now available on CRAN. dbplyr is the database backend for dplyr, translating dplyr syntax into SQL. This is a minor release primarily for compatibility with dplyr 0.8.0. However, there have been some changes to the API, and minor improvements (the full details of which can be found in the [changelog](https://dbplyr.tidyverse.org/news/index.html)). A more substantive update can be expected after rstudio::conf.

## API changes

* Calls of the form `dplyr::foo()` are now evaluated in the database, rather than locally.

* The `vars` argument to [`tbl_sql()`](https://dbplyr.tidyverse.org/reference/tbl_sql.html) has been formally deprecated.

* `src` and `tbl` objects now include a class generated from the class of the underlying connection object. This makes it possible for dplyr backends to implement different behaviour at the dplyr level, when needed.

## SQL translation

* The new `as.integer64(x)` is translated to `CAST(x AS BIGINT)`. 

* [`cummean()`](https://dplyr.tidyverse.org/reference/cumall.html) now translates to SQL `AVG()` as opposed to `MEAN()`.

* `x %in% y` is now translated to `FALSE` if `y` is empty.

## Acknowledgements

Thank you to the 49 people who contributed to this release: [&#x0040;AkhilGNair](https://github.com/AkhilGNair), [&#x0040;andypohl](https://github.com/andypohl), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;bogdanrau](https://github.com/bogdanrau), [&#x0040;cboettig](https://github.com/cboettig), [&#x0040;cderv](https://github.com/cderv), [&#x0040;chris-park](https://github.com/chris-park), [&#x0040;colearendt](https://github.com/colearendt), [&#x0040;copernican](https://github.com/copernican), [&#x0040;cseidman](https://github.com/cseidman), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;dgrtwo](https://github.com/dgrtwo), [&#x0040;dlindelof](https://github.com/dlindelof), [&#x0040;dpprdan](https://github.com/dpprdan), [&#x0040;edgararuiz](https://github.com/edgararuiz), [&#x0040;foonwong](https://github.com/foonwong), [&#x0040;gbisschoff](https://github.com/gbisschoff), [&#x0040;hadley](https://github.com/hadley), [&#x0040;halldc](https://github.com/halldc), [&#x0040;happyshows](https://github.com/happyshows), [&#x0040;iangow](https://github.com/iangow), [&#x0040;javierluraschi](https://github.com/javierluraschi), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jinaliu](https://github.com/jinaliu), [&#x0040;JohnMount](https://github.com/JohnMount), [&#x0040;jonthegeek](https://github.com/jonthegeek), [&#x0040;jrjohnson0821](https://github.com/jrjohnson0821), [&#x0040;karldw](https://github.com/karldw), [&#x0040;kevinykuo](https://github.com/kevinykuo), [&#x0040;kmace](https://github.com/kmace), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;lincis](https://github.com/lincis), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;mfalcioni1](https://github.com/mfalcioni1), [&#x0040;mgirlich](https://github.com/mgirlich), [&#x0040;mkirzon](https://github.com/mkirzon), [&#x0040;mkuehn10](https://github.com/mkuehn10), [&#x0040;mtmorgan](https://github.com/mtmorgan), [&#x0040;N1h1l1sT](https://github.com/N1h1l1sT), [&#x0040;Prometheus77](https://github.com/Prometheus77), [&#x0040;ramnathv](https://github.com/ramnathv), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;sandan](https://github.com/sandan), [&#x0040;sverchkov](https://github.com/sverchkov), [&#x0040;tdsmith](https://github.com/tdsmith), [&#x0040;tmastny](https://github.com/tmastny), [&#x0040;TomWeishaar](https://github.com/TomWeishaar), [&#x0040;vitallish](https://github.com/vitallish), and [&#x0040;yutannihilation](https://github.com/yutannihilation).
