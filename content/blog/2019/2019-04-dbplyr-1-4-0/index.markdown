---
title: dbplyr 1.4.0
author: Hadley Wickham
date: '2019-04-30'
slug: dbplyr-1-4-0
categories:
  - package
tags:
  - dbplyr
  - dplyr
  - databases
photo:
  url: https://unsplash.com/photos/JuFcQxgCXwA
  author: Samuel Zeller
---



We're stoked to announce the release of [dbplyr 1.4.0](https://dbplyr.tidyverse.org), the database backend for dplyr that translates R code into SQL. dbplyr allows you to use a remote database as if it was a collection of local data frames: you write ordinary dplyr code and dbplyr turns it into SQL for you.

You can install the released version from CRAN:


```r
install.packages("dbplyr")
```

While there are many small improvements and bug fixes (see the full full details in the [changelog](https://dbplyr.tidyverse.org/news/index.html)), the biggest improvements in this release are related to SQL generation. In this blog post, I'll show you how find out what dplyr is doing behind the scenes, discuss some major simplifications to the SQL that dbplyr generates, and then show off a few of the new function translations.

To get started, I'll load dplyr and dbplyr:


```r
library(dplyr)
library(dbplyr)
```

## SQL simulation

This version of dbplyr substantially improves the tools that allow you to see what SQL dbplyr generates without needing to connect to a live database. You won't generally need these tools for real data, but they're very useful for blog posts (like this one!), for generating reprexes (as discussed in the new [`vignette("reprex")`](https://dbplyr.tidyverse.org/articles/reprex.html)), and for dbplyr's internal tests. 

The basic idea is that you can create a "lazy" frame:


```r
df1 <- lazy_frame(x = 1:3, y = 3:1)
```

I call this tibble lazy because dplyr operations don't do any work; instead they just record the action so it can later be turned in to a SQL query. You can see this query by printing the lazy tibble:


```r
df1
#> <SQL>
#> SELECT *
#> FROM `df`
```

This is most useful when you add on a few steps:


```r
df1 %>% 
  group_by(x) %>% 
  summarise(z = mean(y))
#> <SQL>
#> Warning: Missing values are always removed in SQL.
#> Use `mean(x, na.rm = TRUE)` to silence this warning
#> This warning is displayed only once per session.
#> SELECT `x`, AVG(`y`) AS `z`
#> FROM `df`
#> GROUP BY `x`
```

(This example also highlights another small improvement to dbplyr: it'll only warn you about missing values being automatically removed in the database once per session.)

Importantly, `lazy_frame()` has a `con` argument that allows you to specify which database should be used for the translation. This makes it easier to see the differences in SQL generation between databases:


```r
df1 %>% 
  mutate(z = paste("item:", x)) %>% 
  head(5)
#> <SQL>
#> SELECT `x`, `y`, CONCAT_WS(' ', 'item:', `x`) AS `z`
#> FROM `df`
#> LIMIT 5

df2 <- lazy_frame(x = 1, y = 2, con = simulate_mssql())
df2 %>% 
  mutate(z = paste("item:", x)) %>% 
  head(5)
#> <SQL>
#> SELECT TOP(5) `x`, `y`, 'item:' + ' ' + `x` AS `z`
#> FROM `df`
```

When you don't specify a connection, dplyr uses its standard translation, which tries to follow the ANSI SQL standard as closely as possible.

## Simpler SQL

Two improvements have considerably reduced the number of subqueries that dbplyr needs:

*   Joins, semi joins, and set operations no longer add additional unneeded
    subqueries, and now generate the minimum set:

    
    ```r
    df1 <- lazy_frame(x = 1, y = 2, a = 2)
    df2 <- lazy_frame(x = 1, y = 2, b = 2)
    
    union(df1, df2)
    #> <SQL>
    #> (SELECT `x`, `y`, `a`, NULL AS `b`
    #> FROM `df`)
    #> UNION
    #> (SELECT `x`, `y`, NULL AS `a`, `b`
    #> FROM `df`)
    
    left_join(df1, df2, by = c("x", "y"))
    #> <SQL>
    #> SELECT `LHS`.`x` AS `x`, `LHS`.`y` AS `y`, `LHS`.`a` AS `a`, `RHS`.`b` AS `b`
    #> FROM `df` AS `LHS`
    #> LEFT JOIN `df` AS `RHS`
    #> ON (`LHS`.`x` = `RHS`.`x` AND `LHS`.`y` = `RHS`.`y`)
    
    semi_join(df1, df2, by = c("x", "y"))
    #> <SQL>
    #> SELECT * FROM `df` AS `LHS`
    #> WHERE EXISTS (
    #>   SELECT 1 FROM `df` AS `RHS`
    #>   WHERE (`LHS`.`x` = `RHS`.`x` AND `LHS`.`y` = `RHS`.`y`)
    #> )
    ```

*   Many sequences of `mutate()`, `select()`, `rename()`, and `transmute()`
    steps are collapsed into a single query: 

    
    ```r
    df <- lazy_frame(x = 1, y = 2)
    df %>% 
      select(2:1) %>% 
      select(2:1) %>% 
      select(2:1) %>% 
      select(2:1) %>% 
      mutate(z = x + y) %>% 
      select(3:1)
    #> <SQL>
    #> SELECT `x` + `y` AS `z`, `y`, `x`
    #> FROM `df`
    ```

Note that dbplyr will still generate multiple subqueries from a single mutate statement when needed. This resolves one of my biggest frustrations with SQL:


```r
df %>% 
  mutate(
    a = x + 1, 
    b1 = a * 3, 
    b2 = a ^ 2,
    c = b1 / b2
  )
#> <SQL>
#> SELECT `x`, `y`, `a`, `b1`, `b2`, `b1` / `b2` AS `c`
#> FROM (SELECT `x`, `y`, `a`, `a` * 3.0 AS `b1`, POWER(`a`, 2.0) AS `b2`
#> FROM (SELECT `x`, `y`, `x` + 1.0 AS `a`
#> FROM `df`) `dbplyr_001`) `dbplyr_002`
```

I touch on this advantage of dbplyr over SQL in a new vignette, [`vignette("sql")`](https://dbplyr.tidyverse.org/dev/articles/sql.html), which also gives some advice about how to write literal SQL, when dbplyr's built-in translations don't work.

## SQL translation

As well as improving the translation of high-level dplyr functions, we've also considerably added to the set of low-level vector functions that dbplyr can translate. Firstly, [MySQL][mysql-window] (>= 8.0), [MariaDB][maria-window] (>= 10.2) and [SQLite][sqlite-window] (>3.25) gain support for [window functions](https://dbplyr.tidyverse.org/dev/articles/translation-function.html#window-functions). These allow you to use summary functions (like `mean()` or `sum()`) inside of `mutate()`, as well as unlocking useful function like `min_rank()`, `first()`, and `lead()`/`lag()`.

Thanks to [Cole Arendt](http://github.com/colearendt), dbplyr now supports translations for a selection of useful functions from stringr (`str_c()`, `str_sub()`, `str_length()`, `str_to_upper()`, `str_to_lower()`, and `str_to_title()`), and lubridate ( `today()`, `now()`, `year()`, `month()` (numeric value only), `day()`, `hour()`, `minute()`, `second()`):


```r
df <- lazy_frame(name = character(), birthday = character())

df %>% 
  transmute(
    name = str_to_lower(name), 
    month = month(birthday),
    mday = mday(birthday)
  )
#> <SQL>
#> SELECT LOWER(`name`) AS `name`, EXTRACT(month FROM `birthday`) AS `month`, EXTRACT(day FROM `birthday`) AS `mday`
#> FROM `df`
```

Thanks to [David C Hall](http://github.com/davidchall) we have translations for bitwise operations (`bitwNot()`, `bitwAnd()`, `bitwOr()`, `bitwXor()`, `bitwShiftL()`, and `bitwShiftR()`):


```r
df <- lazy_frame(x = integer(), y = integer())
df %>% 
  transmute(and = bitwAnd(x, y), or = bitwOr(x, y))
#> <SQL>
#> SELECT `x` & `y` AS `and`, `x` | `y` AS `or`
#> FROM `df`
```

Thanks to [E. David Aja](http://github.com/edavidaja)'s research on tidyverse developer day we have improved translations for `median()` and `quantile()` for all ANSI compliant databases (SQL Server, Postgres, MariaDB), along with custom translations for Hive and Teradata.


```r
lazy_frame(g = character(), x = numeric()) %>% 
  group_by(g) %>% 
  summarise(y = median(x))
#> <SQL>
#> SELECT `g`, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY `x`) AS `y`
#> FROM `df`
#> GROUP BY `g`
```

Finally, I have improved translation of `[`, so that you can use expressions like `sum(a[b == 0])` as you would in R:


```r
tbl_lazy(mtcars) %>% 
  group_by(cyl) %>% 
  summarise(mpg_vs = sum(mpg[vs == 1], na.rm = TRUE))
#> <SQL>
#> SELECT `cyl`, SUM(CASE WHEN (`vs` = 1.0) THEN (`mpg`) END) AS `mpg_vs`
#> FROM `df`
#> GROUP BY `cyl`
```

You can also now use use `x$y` to access nested fields:


```r
lazy_frame(x = list()) %>% 
  mutate(z = x$y$z)
#> <SQL>
#> SELECT `x`, `x`.`y`.`z` AS `z`
#> FROM `df`
```

## Acknowledgements

As always, a big thank goes to the entire community who helped make this release of dbplyr a reality - I really appreciated all your bug reports, helpful comments, SQL suggestions, and pull requests!

[&#x0040;alex-gable](https://github.com/alex-gable), [&#x0040;blairj09](https://github.com/blairj09), [&#x0040;carvalhomb](https://github.com/carvalhomb), [&#x0040;cderv](https://github.com/cderv), [&#x0040;colearendt](https://github.com/colearendt), [&#x0040;DanielStay](https://github.com/DanielStay), [&#x0040;davidchall](https://github.com/davidchall), [&#x0040;dlindelof](https://github.com/dlindelof), [&#x0040;edgararuiz](https://github.com/edgararuiz), [&#x0040;FrancoisGuillem](https://github.com/FrancoisGuillem), [&#x0040;FranGoitia](https://github.com/FranGoitia), [&#x0040;hadley](https://github.com/hadley), [&#x0040;imanuelcostigan](https://github.com/imanuelcostigan), [&#x0040;JakeRuss](https://github.com/JakeRuss), [&#x0040;javierluraschi](https://github.com/javierluraschi), [&#x0040;jcfisher](https://github.com/jcfisher), [&#x0040;jkylearmstrong](https://github.com/jkylearmstrong), [&#x0040;JohnMount](https://github.com/JohnMount), [&#x0040;jrisi256](https://github.com/jrisi256), [&#x0040;jsekamane](https://github.com/jsekamane), [&#x0040;klmedeiros](https://github.com/klmedeiros), [&#x0040;leungi](https://github.com/leungi), [&#x0040;Liubuntu](https://github.com/Liubuntu), [&#x0040;lpatruno](https://github.com/lpatruno), [&#x0040;lymanmark](https://github.com/lymanmark), [&#x0040;mkearney](https://github.com/mkearney), [&#x0040;mkirzon](https://github.com/mkirzon), [&#x0040;mpettis](https://github.com/mpettis), [&#x0040;mtoto](https://github.com/mtoto), [&#x0040;N1h1l1sT](https://github.com/N1h1l1sT), [&#x0040;nwstephens](https://github.com/nwstephens), [&#x0040;QuLogic](https://github.com/QuLogic), [&#x0040;r2evans](https://github.com/r2evans), [&#x0040;rlh1994](https://github.com/rlh1994), [&#x0040;shgoke](https://github.com/shgoke), [&#x0040;tomauer](https://github.com/tomauer), and [&#x0040;verajosemanuel](https://github.com/verajosemanuel)

[mysql-window]: https://dev.mysql.com/doc/refman/8.0/en/window-functions.html
[maria-window]: https://mariadb.com/kb/en/library/window-functions/
[sqlite-window]: https://www.sqlite.org/windowfunctions.html
