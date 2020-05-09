---
title: googlesheets4 0.2.0
author: Jenny Bryan
date: '2020-05-10'
slug: googlesheets4-0-2-0
categories:
  - package
tags:
  - googlesheets4
  - google
photo:
  author: Stephane YAICH
  url: https://unsplash.com/photos/ufxd6aU0w9U
---

<!-- index.Rmarkdown is generated from index.Rmarkdown.orig -->
<!-- Please edit that file and run precompile.R -->







We're ecstatic to announce the release of googlesheets4 0.2.0 on CRAN:

[googlesheets4.tidyverse.org](https://googlesheets4.tidyverse.org)

googlesheets4 is a package to work with Google Sheets from R. Although version 0.1.0 debuted on CRAN in late 2019, I've waited to blog about it until I considered googlesheet4 a replacement for an older package called googlesheets. That day is here! In particular, googlesheets 0.2.0 can create and edit Sheets.

Install googlesheets4 from CRAN like so:


```r
install.packages("googlesheets4")
```

Then attach it for use via:


```r
library(googlesheets4)
```

googlesheets4 is already documented through [several articles](https://googlesheets4.tidyverse.org/articles/index.html) and, as always, you can find detailed notes about all changes in the [change log](https://googlesheets4.tidyverse.org/news/index.html).

## googlesheets is dead! Long live googlesheets4!

googlesheets4 is a reboot of an earlier package called googlesheets.

*Why **4**? Why googlesheets**4**? Did I miss googlesheets1 through 3? No. The idea is to name the package after the corresponding version of the Sheets API. In hindsight, the original googlesheets should have been googlesheets**3**.*

googlesheets4 wraps [v4 of the Sheets API](https://developers.google.com/sheets), whereas the original googlesheets wraps v3. The [v3 API](https://developers.google.com/sheets/api/v3) has been deprecated for a long time. Its shut-off has been postponed several times, but its days are clearly numbered. Gradual shutdown of certain endpoints and scopes is already underway, with complete shutdown [expected on September 30, 2020](https://cloud.google.com/blog/products/g-suite/migrate-your-apps-use-latest-sheets-api) at the time of writing. If you use googlesheets, you **must** switch to googlesheets4 and the time is now.

Change is hard, but let's focus on the positive:

* The v4 API has a better design, which makes it easier to wrap, which
  translates to a better user experience in client packages.
* I have gotten a lot better at writing R packages. Some of the fiddly parts
  of the original googlesheets came from the awkward v3 API, but some of it
  came from me.
* The gargle package ([gargle.r-lib.org](https://gargle.r-lib.org)) provides
  infrastructure common to ~250 Google APIs, including Sheets, Drive, Gmail, and
  BigQuery. By using gargle for auth, we can provide a consistent auth
  experience across googlesheets4, googledrive, gmailr, and bigrquery.
* The googledrive package ([googledrive.tidyverse.org](https://googledrive.tidyverse.org))
  provides a full-featured client for working with files on Google Drive, which
  allows googlesheets4 to focus on operations specific to spreadsheets. In the
  original googlesheets package, about half of the code and effort was actually
  devoted to Drive, not Sheets.

## Read a Sheet

Let's say you're staring at a Sheet in the browser and you want to read it into R. Copy the URL to your clipboard and paste it into a call to `read_sheet()` like this:


```r
read_sheet("https://docs.google.com/spreadsheets/d/1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY/edit#gid=780868077")
#> Reading from "gapminder"
#> Range "Africa"
#> # A tibble: 624 x 6
#>   country continent  year lifeExp      pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#> 1 Algeria Africa     1952    43.1  9279525     2449.
#> 2 Algeria Africa     1957    45.7 10270856     3014.
#> 3 Algeria Africa     1962    48.3 11000948     2551.
#> 4 Algeria Africa     1967    51.4 12760499     3247.
#> 5 Algeria Africa     1972    54.5 14760787     4183.
#> # … with 619 more rows
```

I'm reading from one of our public example Sheets -- specifically, a Sheet that holds Gapminder data. `gs4_examples()` and `gs4_example()` make the example Sheets easy to access.

*If you're following along at home, you probably just got a prompt to log in with Google. That's because, in general, you'll want googlesheets4 to be able to do the same things you can do with Sheets in the browser. If you know you only want to read public Sheets, you can use `gs4_deauth()` to tell googlesheets4 that it should not attempt auth.*


```r
gs4_example("gapminder")
#>   Spreadsheet name: gapminder
#>                 ID: 1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY
#>             Locale: en_US
#>          Time zone: America/Los_Angeles
#>        # of sheets: 5
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>       Africa: 625 x 6
#>     Americas: 301 x 6
#>         Asia: 397 x 6
#>       Europe: 361 x 6
#>      Oceania: 25 x 6
#> 
#> (Named range): (A1 range)        
#>        canada: 'Americas'!A38:F49
```

The above demonstrates that printing a Sheet ID reveals relevant metadata about the Sheet, such as its name and an overview of its worksheets and named ranges.

A browser URL is OK for quick-and-dirty work, but there are other ways to target Sheet that are more robust and easier on the eyes. We can pipe a Sheet ID into `read_sheet()`. I'll also start to demonstrate other features, e.g. the use of a qualifed A1-style `range`.


```r
gs4_example("gapminder") %>%
  read_sheet(range = "Asia!A:D")
#> Reading from "gapminder"
#> Range "'Asia'!A:D"
#> # A tibble: 396 x 4
#>   country     continent  year lifeExp
#>   <chr>       <chr>     <dbl>   <dbl>
#> 1 Afghanistan Asia       1952    28.8
#> 2 Afghanistan Asia       1957    30.3
#> 3 Afghanistan Asia       1962    32.0
#> 4 Afghanistan Asia       1967    34.0
#> 5 Afghanistan Asia       1972    36.1
#> # … with 391 more rows
```

We can use googledrive's ability to address Drive files by **name** to help us identify the Sheet of interest. I'll switch to a different example Sheet, show the use of `range` to target a *named range*, and specify some of the column types:


```r
googledrive::drive_get("deaths") %>%
  read_sheet(range = "arts_data", col_types = "??i?DD")
#> Reading from "deaths"
#> Range "arts_data"
#> # A tibble: 10 x 6
#>   Name          Profession   Age `Has kids` `Date of birth` `Date of death`
#>   <chr>         <chr>      <int> <lgl>      <date>          <date>         
#> 1 David Bowie   musician      69 TRUE       1947-01-08      2016-01-10     
#> 2 Carrie Fisher actor         60 TRUE       1956-10-21      2016-12-27     
#> 3 Chuck Berry   musician      90 TRUE       1926-10-18      2017-03-18     
#> 4 Bill Paxton   actor         61 TRUE       1955-05-17      2017-02-25     
#> 5 Prince        musician      57 TRUE       1958-06-07      2016-04-21     
#> # … with 5 more rows
```

`read_sheet()` is the main "read" function of googlesheets4 and should remind you of other table-reading functions, like `readr::read_csv()` and `readxl::read_excel()`. It also goes by another name: `range_read()`, which is the "correct" name according to googlesheets4's naming conventions. Either name is fine! It's OK if you don't care about this, I just want to give you a heads up. If you make extensive use of googlesheets4, you'll notice there are 3 large families of functions, with the prefixes `gs4_`, `sheet_`, and `range_`. The prefix conveys a function's scope of operation.

Remember there are [articles](https://googlesheets4.tidyverse.org/articles/index.html) that go into much more depth.

## Write and modify a Sheet

I'll go out in a blaze of glory, demonstrating just a few of the functions that can create and edit a Sheet.

Create a new Sheet with `gs4_create()` and send some initial data to well-named worksheets.


```r
ss <- gs4_create(
  "able-aardvark",
  sheets = list(flowers = head(iris), autos = head(mtcars))
  )
#> Creating new Sheet: "able-aardvark"
ss
#>   Spreadsheet name: able-aardvark
#>                 ID: 14KGbP1tuXJ1I94yUX44QxRtgEiUQCHUK5zRMLNb27Oo
#>             Locale: en_US
#>          Time zone: Etc/GMT
#>        # of sheets: 2
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>      flowers: 7 x 5
#>        autos: 7 x 11

read_sheet(ss)
#> Reading from "able-aardvark"
#> Range "flowers"
#> # A tibble: 6 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <chr>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa 
#> 4          4.6         3.1          1.5         0.2 setosa 
#> 5          5           3.6          1.4         0.2 setosa 
#> # … with 1 more row
```

If you're following along at home, you can use `gs4_browse()` to open a Sheet in your default web browser.


```r
gs4_browse(ss)
```

Send another data frame to an entirely new (work)sheet within this existing (spread)Sheet with `write_sheet()`.


```r
my_data <- data.frame(
  numbers = c(1, 5, 3, 2, 4, 6),
  letters = letters[1:6]
)

write_sheet(my_data, ss = ss)
#> Writing to "able-aardvark"
#> Writing to sheet "my_data"
```

Let's append a row to the bottom of `my_data` and populate it with formulas that summarize the data in each column (hey, a sparkline!).


```r
my_summaries <- data.frame(
  x = gs4_formula('=SPARKLINE(A2:A7, {"color", "blue"})'),
  y = gs4_formula('=JOIN("-", B2:B7)')
)
ss %>%
  sheet_append(my_summaries, sheet = "my_data")
#> Writing to "able-aardvark"
#> Appending 1 row(s) to "my_data"
```

Notice that we did not have to specify which row to write the new values into. `sheet_append()` uses an endpoint that knows how to add rows to the existing table of data. It's true that we used some row knowledge in our formulas, but more often you will just be sending data. Also notice the use of `gs4_formula()`. This is how you indicate that character data should be sent as Sheets formulas, as opposed to regular strings.

Let's take one last glance at our creation.


```r
ss
#>   Spreadsheet name: able-aardvark
#>                 ID: 14KGbP1tuXJ1I94yUX44QxRtgEiUQCHUK5zRMLNb27Oo
#>             Locale: en_US
#>          Time zone: Etc/GMT
#>        # of sheets: 3
#> 
#> (Sheet name): (Nominal extent in rows x columns)
#>      flowers: 7 x 5
#>        autos: 7 x 11
#>      my_data: 8 x 2
```

Finally, we clean up. Note that we (must) use googledrive for this. The Sheets API can create a Sheet, but alas it cannot delete one. For that (and most other "whole file" operations), we must use the Drive API, which is why googlesheets4 is designed to work *with* googledrive.


```r
googledrive::drive_trash(ss)
#> Files trashed:
#>   * able-aardvark: 14KGbP1tuXJ1I94yUX44QxRtgEiUQCHUK5zRMLNb27Oo
```

Once again, the [articles](https://googlesheets4.tidyverse.org/articles/index.html) provide much deeper coverage of all of these topics.

## Try it out

The googlesheets4 package is marked as [experimental](https://www.tidyverse.org/lifecycle/#experimental), but it's really somewhere between experimental and [maturing](https://www.tidyverse.org/lifecycle/#maturing). This is the first CRAN release that includes write and edit capability, so I reserve the right to make some relatively quick, modest changes to the interface in response to user feedback. But such changes get more painful for everyone the longer we wait. Now is a great time to take googlesheets4 out for a test drive.

If you encounter ergonomic problems or spot tasks that were possible with googlesheets but are not yet possible with googlesheet4, please [open an issue](https://github.com/tidyverse/googlesheets4/issues).

## Thank you!

A big thanks to all 64 contributors who helped make this release happen via their contributions on GitHub.
[&#x0040;4marel](https://github.com/4marel), [&#x0040;AaronGullickson](https://github.com/AaronGullickson), [&#x0040;adisarid](https://github.com/adisarid), [&#x0040;ahelgason](https://github.com/ahelgason), [&#x0040;alex-steiner-next](https://github.com/alex-steiner-next), [&#x0040;aljrico](https://github.com/aljrico), [&#x0040;amir2cs](https://github.com/amir2cs), [&#x0040;antoine-sachet](https://github.com/antoine-sachet), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;behrman](https://github.com/behrman), [&#x0040;ben519](https://github.com/ben519), [&#x0040;Biomiha](https://github.com/Biomiha), [&#x0040;BriBecker](https://github.com/BriBecker), [&#x0040;ceprdata](https://github.com/ceprdata), [&#x0040;ChemiKyle](https://github.com/ChemiKyle), [&#x0040;chrowe](https://github.com/chrowe), [&#x0040;cneskey](https://github.com/cneskey), [&#x0040;csnardi](https://github.com/csnardi), [&#x0040;dan-reznik](https://github.com/dan-reznik), [&#x0040;dcaley5005](https://github.com/dcaley5005), [&#x0040;Flavjack](https://github.com/Flavjack), [&#x0040;GitHubDoug](https://github.com/GitHubDoug), [&#x0040;gloignon](https://github.com/gloignon), [&#x0040;grwhumphries](https://github.com/grwhumphries), [&#x0040;guhanrv](https://github.com/guhanrv), [&#x0040;ianformanek](https://github.com/ianformanek), [&#x0040;j-Rinehart](https://github.com/j-Rinehart), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jiaoshuo](https://github.com/jiaoshuo), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jjankowiak](https://github.com/jjankowiak), [&#x0040;jpawlata](https://github.com/jpawlata), [&#x0040;jperkel](https://github.com/jperkel), [&#x0040;juliangilbey](https://github.com/juliangilbey), [&#x0040;jzadra](https://github.com/jzadra), [&#x0040;karawoo](https://github.com/karawoo), [&#x0040;kaveh1000](https://github.com/kaveh1000), [&#x0040;lucasmation](https://github.com/lucasmation), [&#x0040;MarkEdmondson1234](https://github.com/MarkEdmondson1234), [&#x0040;mikegunn](https://github.com/mikegunn), [&#x0040;mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), [&#x0040;mitchelloharawild](https://github.com/mitchelloharawild), [&#x0040;mlamias](https://github.com/mlamias), [&#x0040;mountainMath](https://github.com/mountainMath), [&#x0040;mssanjavickovic](https://github.com/mssanjavickovic), [&#x0040;nacnudus](https://github.com/nacnudus), [&#x0040;nathanhwangbo](https://github.com/nathanhwangbo), [&#x0040;nicole-brewer](https://github.com/nicole-brewer), [&#x0040;ogs22](https://github.com/ogs22), [&#x0040;pachamaltese](https://github.com/pachamaltese), [&#x0040;peeter-t2](https://github.com/peeter-t2), [&#x0040;ramirobentes](https://github.com/ramirobentes), [&#x0040;realauggieheschmeyer](https://github.com/realauggieheschmeyer), [&#x0040;RSherwoodJr](https://github.com/RSherwoodJr), [&#x0040;sam-watts](https://github.com/sam-watts), [&#x0040;schmalte04](https://github.com/schmalte04), [&#x0040;seanchrismurphy](https://github.com/seanchrismurphy), [&#x0040;selesnow](https://github.com/selesnow), [&#x0040;somnambWl](https://github.com/somnambWl), [&#x0040;SridharJagannathan](https://github.com/SridharJagannathan), [&#x0040;Tadge-Analytics](https://github.com/Tadge-Analytics), [&#x0040;untergeekDE](https://github.com/untergeekDE), [&#x0040;wildcat47](https://github.com/wildcat47), and [&#x0040;yogat3ch](https://github.com/yogat3ch).
