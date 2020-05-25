---
title: odbc 1.2.0
author: Jim Hester
date: '2019-12-02'
slug: odbc-1-2-0
description: >
  odbc 1.2.0 is now on CRAN. It includes improvements to dealing with schemas, an API for immediate execution, and a new parameter to control timezone outputs.
categories:
  - package
tags:
  - odbc
photo:
  url: https://unsplash.com/photos/40XgDxBfYXM
  author: Photo by Jordan Harrison
---

odbc 1.2.0 is now on CRAN! The odbc package provides a [DataBase Interface (DBI)](https://dbi.r-dbi.org/) to [Open DataBase Connectivity (ODBC)](https://en.wikipedia.org/wiki/Open_Database_Connectivity) drivers.
ODBC drivers exist for nearly all widely used databases, including [SQL Server](https://www.microsoft.com/en-us/sql-server/), [Oracle](https://www.oracle.com/database), [MySQL](https://www.mysql.com/), [PostgreSQL](https://www.postgresql.org/), [SQLite](https://sqlite.org/) and others.
RStudio also provides a set of [Professional ODBC Drivers](https://db.rstudio.com/rstudio/pro-drivers/) free of charge for customers who have RStudio Server Pro, RStudio Connect, or Shiny Server Pro.
In addition, [db.rstudio.com](https://db.rstudio.com/) has extensive resources on connecting to and working with databases from R.
The odbc package allows you to query these databases from within R.
Get the latest version with:

```r
install.packages("odbc")
```

Generally you will *not* need to load the odbc package with `library()`, instead you can load the `DBI` package and use `odbc::odbc()` to reference the driver when connecting. e.g.

```r
library(DBI)
con <- dbConnect(odbc::odbc(), "MicrosoftSQLServer", UID = "SA", PWD = "Password12")
```

The biggest improvements in this release are related to querying within schemas, an API for immediate execution, and a new `timezone_out` parameter to control the displayed time of timezones returned by the query.
See the [change log](https://cloud.r-project.org/web/packages/odbc/news/news.html) for the full set of changes for this release.

## Querying schemas

Use `DBI::Id()` reference a table within a schema.
This will allow odbc to handle any quoting necessary for your particular database. e.g. you can write to a table named `my.iris` even if there is a schema named `my`.

```{r, eval = FALSE}
library(DBI)

con <- dbConnect(odbc::odbc(), "MicrosoftSQLServer", UID = "SA", PWD = "Password12")

my_tbl <- Id(schema = "my", table = "my.iris")
dbWriteTable(con, my_tbl, iris)

tbl <- dbReadTable(con, my_tbl)
# The quoting for "my"."my.iris" is done automatically when 
# using DBI::Id()
tbl2 <- dbGetQuery(con, 'SELECT * FROM "my"."my.iris"')
all.equal(tbl, tbl2)
#> TRUE
```

This feature has actually existed for a number of odbc releases, but due to driver inconsistencies was not working properly on SQL Server, which is now fixed.

## Immediate/direct execution

The odbc package uses [Prepared Statements](https://en.wikipedia.org/wiki/Prepared_statement) to compile the query once and reuse it, allowing large or repeated queries to be more efficient.
However, prepared statements can actually perform worse in some cases, such as many different small queries that are all only executed once.
Because of this the odbc package now also supports direct queries by specifying `immediate = TRUE`.

```r
# This will use a prepared statement
dbGetQuery("SELECT * from iris")

# This will execute the statement directly
dbGetQuery("SELECT * from iris", immediate = TRUE)
```

## Timezone display

The odbc package has historically imported date times with a `UTC` timezone.
This ensures that the same code will produce the same output regardless of the local time.
However this can confuse users, particularly if the server timezones are stored or displayed in a non-UTC timezone.
Because of this, the odbc package now supports a `timezone_out` parameter, which allows users to set the timezone the times should be displayed in.
Setting this to your local timezone, or the timezone of the database may reduce this confusion.

``` r
library(DBI)
# Create a new connection, specifying a timezone_out of UTC (this is the default)
con_utc <- dbConnect(odbc::odbc(), "MicrosoftSQLServer", UID="SA", PWD="Password12", timezone_out = "UTC")

# Create a table with the current timestamp as a value
dbExecute(con_utc, "SELECT CURRENT_TIMESTAMP AS x INTO now")
#> [1] 1

# Read that table, the time is displayed in UTC
res_utc <- dbReadTable(con_utc, "now")
res_utc
#>                     x
#> 1 2019-11-29 15:03:59

# Create another connection, this time with the timezone in United States eastern time
con_est <- dbConnect(odbc::odbc(), "MicrosoftSQLServer", UID="SA", PWD="Password12", timezone_out = "US/Eastern")

# Read the same table again, this time the time is displayed in EST
res_est <- dbReadTable(con_est, "now")
res_est
#>                     x
#> 1 2019-11-29 10:03:59

# These two times equal the same time point, the only difference is the display
res_utc == res_est
#> Warning in check_tzones(e1, e2): 'tzone' attributes are inconsistent
#>         x
#> [1,] TRUE

# You can convert res_utc to res_est by changing the `tzone` attribute
attr(res_utc$x, "tzone") <- "US/Eastern"
res_utc
#>                     x
#> 1 2019-11-29 10:03:59
```

There were a number of additional features and bug fixes in this version, see the [change log](https://cloud.r-project.org/web/packages/odbc/news/news.html) for details.

## Acknowledgements

Thanks to Xianying Tan, James Blair and Kirill Müller who all submitted multiple pull requests with improvements, and to all the 114 GitHub contributors who have opened issues or submitted code improvements to help make this release happen!

[&#x0040;ajholguin](https://github.com/ajholguin), [&#x0040;ammarelsh](https://github.com/ammarelsh), [&#x0040;anchal02](https://github.com/anchal02), [&#x0040;andreaspano](https://github.com/andreaspano), [&#x0040;andrewsali](https://github.com/andrewsali), [&#x0040;arestrom](https://github.com/arestrom), [&#x0040;aryoda](https://github.com/aryoda), [&#x0040;berkorbay](https://github.com/berkorbay), [&#x0040;blairj09](https://github.com/blairj09), [&#x0040;blmayer](https://github.com/blmayer), [&#x0040;cboettig](https://github.com/cboettig), [&#x0040;cdumoulin-usgs](https://github.com/cdumoulin-usgs), [&#x0040;CerebralMastication](https://github.com/CerebralMastication), [&#x0040;cfisher5](https://github.com/cfisher5), [&#x0040;chrishaug](https://github.com/chrishaug), [&#x0040;ChristianAlvaradoAP](https://github.com/ChristianAlvaradoAP), [&#x0040;cnolanminich](https://github.com/cnolanminich), [&#x0040;colearendt](https://github.com/colearendt), [&#x0040;copernican](https://github.com/copernican), [&#x0040;crossxwill](https://github.com/crossxwill), [&#x0040;david-cortes](https://github.com/david-cortes), [&#x0040;davidchall](https://github.com/davidchall), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;detule](https://github.com/detule), [&#x0040;dhaycraft](https://github.com/dhaycraft), [&#x0040;dirkschumacher](https://github.com/dirkschumacher), [&#x0040;dpprdan](https://github.com/dpprdan), [&#x0040;duncanrellis](https://github.com/duncanrellis), [&#x0040;edgararuiz](https://github.com/edgararuiz), [&#x0040;elbamos](https://github.com/elbamos), [&#x0040;elben10](https://github.com/elben10), [&#x0040;etienne-s](https://github.com/etienne-s), [&#x0040;etiennebr](https://github.com/etiennebr), [&#x0040;felipegerard](https://github.com/felipegerard), [&#x0040;foundinblank](https://github.com/foundinblank), [&#x0040;Freekers](https://github.com/Freekers), [&#x0040;ghost](https://github.com/ghost), [&#x0040;hadley](https://github.com/hadley), [&#x0040;halpo](https://github.com/halpo), [&#x0040;happyshows](https://github.com/happyshows), [&#x0040;harrismcgehee](https://github.com/harrismcgehee), [&#x0040;hiltonmbr](https://github.com/hiltonmbr), [&#x0040;hoxo-m](https://github.com/hoxo-m), [&#x0040;iamsaini87](https://github.com/iamsaini87), [&#x0040;its-gazza](https://github.com/its-gazza), [&#x0040;JarkoDubbeldam](https://github.com/JarkoDubbeldam), [&#x0040;jasperDD](https://github.com/jasperDD), [&#x0040;javierluraschi](https://github.com/javierluraschi), [&#x0040;jeroenhabets](https://github.com/jeroenhabets), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jrisi256](https://github.com/jrisi256), [&#x0040;jsonbecker](https://github.com/jsonbecker), [&#x0040;jtelleria](https://github.com/jtelleria), [&#x0040;jtelleriar](https://github.com/jtelleriar), [&#x0040;juliasilge](https://github.com/juliasilge), [&#x0040;kbzsl](https://github.com/kbzsl), [&#x0040;kerry-ja](https://github.com/kerry-ja), [&#x0040;kevinushey](https://github.com/kevinushey), [&#x0040;khotilov](https://github.com/khotilov), [&#x0040;KimmoMW](https://github.com/KimmoMW), [&#x0040;kjaanson](https://github.com/kjaanson), [&#x0040;kohleth](https://github.com/kohleth), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;lee170](https://github.com/lee170), [&#x0040;leungi](https://github.com/leungi), [&#x0040;madlogos](https://github.com/madlogos), [&#x0040;martindut](https://github.com/martindut), [&#x0040;mateusz1981](https://github.com/mateusz1981), [&#x0040;matthijsvanderloos](https://github.com/matthijsvanderloos), [&#x0040;maverix13](https://github.com/maverix13), [&#x0040;maxPunck](https://github.com/maxPunck), [&#x0040;mbfsdatascience](https://github.com/mbfsdatascience), [&#x0040;md0u80c9](https://github.com/md0u80c9), [&#x0040;meztez](https://github.com/meztez), [&#x0040;mhsilvav](https://github.com/mhsilvav), [&#x0040;mingwandroid](https://github.com/mingwandroid), [&#x0040;mlaviolet](https://github.com/mlaviolet), [&#x0040;mmastand](https://github.com/mmastand), [&#x0040;move[bot]](https://github.com/move[bot]), [&#x0040;muranyia](https://github.com/muranyia), [&#x0040;nwstephens](https://github.com/nwstephens), [&#x0040;nzbart](https://github.com/nzbart), [&#x0040;patperu](https://github.com/patperu), [&#x0040;PatWilson](https://github.com/PatWilson), [&#x0040;pchiacchiari-coatue](https://github.com/pchiacchiari-coatue), [&#x0040;pgensler](https://github.com/pgensler), [&#x0040;pythiantech](https://github.com/pythiantech), [&#x0040;quartin](https://github.com/quartin), [&#x0040;r2evans](https://github.com/r2evans), [&#x0040;ralsouza](https://github.com/ralsouza), [&#x0040;renkun-ken](https://github.com/renkun-ken), [&#x0040;revodavid](https://github.com/revodavid), [&#x0040;ronblum](https://github.com/ronblum), [&#x0040;rtgdk](https://github.com/rtgdk), [&#x0040;s-fleck](https://github.com/s-fleck), [&#x0040;satvenkat](https://github.com/satvenkat), [&#x0040;scmck17](https://github.com/scmck17), [&#x0040;sebschub](https://github.com/sebschub), [&#x0040;shapenaji](https://github.com/shapenaji), [&#x0040;shizidushu](https://github.com/shizidushu), [&#x0040;shrektan](https://github.com/shrektan), [&#x0040;smingerson](https://github.com/smingerson), [&#x0040;stlouiso](https://github.com/stlouiso), [&#x0040;timabe](https://github.com/timabe), [&#x0040;totalgit74](https://github.com/totalgit74), [&#x0040;TTudino](https://github.com/TTudino), [&#x0040;UpsideDownRide](https://github.com/UpsideDownRide), [&#x0040;versipellis](https://github.com/versipellis), [&#x0040;vh-d](https://github.com/vh-d), [&#x0040;vpanfilov](https://github.com/vpanfilov), [&#x0040;warnes](https://github.com/warnes), [&#x0040;washcycle](https://github.com/washcycle), [&#x0040;wibeasley](https://github.com/wibeasley), and [&#x0040;yutannihilation](https://github.com/yutannihilation)
