---
title: dplyr 0.8.0
author: Romain François
date: '2019-02-15'
slug: dplyr-0-8-0
description: >
  dplyr 0.8.0 is now on CRAN.
categories:
  - package
tags:
  - dplyr
  - tidyverse
photo:
  url: https://unsplash.com/photos/-WAiyQLGEEc
  author: Element5 Digital
---



We're tickled pink to announce the release of version 0.8.0 of [dplyr](https://dplyr.tidyverse.org), the grammar of data manipulation in the tidyverse. 
This is a major update that has kept us busy for almost a year. We take the coincidence of a Valentine's day release as a sign 
of continuous ❤️ for `dplyr`'s approach to tidy data manipulation. 

Important changes are discussed in detail in the [pre-release post](https://www.tidyverse.org/articles/2018/12/dplyr-0-8-0-release-candidate/), 
we are grateful to members of the community for their feedback in the last couple of months, this 
has been tremendously useful in making the release process smoother. 

The bulk of the changes are internal, and part of an ongoing effort to make the codebase more robust and 
less surprising. This is an investment that will continue to pay off for years, and serve as a foundation for 
more innovations in the future. 

For a comprehensive list of changes, please see [the NEWS](https://dplyr.tidyverse.org/news/index.html#dplyr-0-8-0) 
for the 0.8.0 release, the sections below discusses the main changes. 

## Group hug

Grouping has always been at the center of what `dplyr` is about, this release expands on the 
existing `group_by()` with a set of *experimental* functions with a variety of 
perspectives on the notion of grouping. 

We believe they offer new unique possibilities, but we welcome community feedback and use cases
before we put a 💍 on them. Let's illustrate them with a subset from the 
well-known `gapminder` data. 


```r
oceania <- gapminder::gapminder %>% 
  filter(continent == "Oceania") %>% 
  mutate(yr1952 = year - 1952) %>% 
  select(-continent) %>% 
  group_by(country)
oceania
#> # A tibble: 24 x 6
#> # Groups:   country [2]
#>    country    year lifeExp      pop gdpPercap yr1952
#>    <fct>     <int>   <dbl>    <int>     <dbl>  <dbl>
#>  1 Australia  1952    69.1  8691212    10040.      0
#>  2 Australia  1957    70.3  9712569    10950.      5
#>  3 Australia  1962    70.9 10794968    12217.     10
#>  4 Australia  1967    71.1 11872264    14526.     15
#>  5 Australia  1972    71.9 13177000    16789.     20
#>  6 Australia  1977    73.5 14074100    18334.     25
#>  7 Australia  1982    74.7 15184200    19477.     30
#>  8 Australia  1987    76.3 16257249    21889.     35
#>  9 Australia  1992    77.6 17481977    23425.     40
#> 10 Australia  1997    78.8 18565243    26998.     45
#> # … with 14 more rows
```

  - [group_nest()](https://dplyr.tidyverse.org/reference/group_nest.html) is similar to 
  `tidyr::nest()`, but focuses on the variables to *nest by* instead of the nested columns. 
  

```r
oceania %>% 
  group_nest()
#> # A tibble: 2 x 2
#>   country     data             
#>   <fct>       <list>           
#> 1 Australia   <tibble [12 × 5]>
#> 2 New Zealand <tibble [12 × 5]>
```
  
  - [group_split()](https://dplyr.tidyverse.org/reference/group_split.html) is a tidy version 
  of `base::split()`. In particular, it respects a `group_by()`-like grouping specification, 
  and refuses to name its result. 
  

```r
oceania %>% 
  group_split()
#> [[1]]
#> # A tibble: 12 x 6
#>    country    year lifeExp      pop gdpPercap yr1952
#>    <fct>     <int>   <dbl>    <int>     <dbl>  <dbl>
#>  1 Australia  1952    69.1  8691212    10040.      0
#>  2 Australia  1957    70.3  9712569    10950.      5
#>  3 Australia  1962    70.9 10794968    12217.     10
#>  4 Australia  1967    71.1 11872264    14526.     15
#>  5 Australia  1972    71.9 13177000    16789.     20
#>  6 Australia  1977    73.5 14074100    18334.     25
#>  7 Australia  1982    74.7 15184200    19477.     30
#>  8 Australia  1987    76.3 16257249    21889.     35
#>  9 Australia  1992    77.6 17481977    23425.     40
#> 10 Australia  1997    78.8 18565243    26998.     45
#> 11 Australia  2002    80.4 19546792    30688.     50
#> 12 Australia  2007    81.2 20434176    34435.     55
#> 
#> [[2]]
#> # A tibble: 12 x 6
#>    country      year lifeExp     pop gdpPercap yr1952
#>    <fct>       <int>   <dbl>   <int>     <dbl>  <dbl>
#>  1 New Zealand  1952    69.4 1994794    10557.      0
#>  2 New Zealand  1957    70.3 2229407    12247.      5
#>  3 New Zealand  1962    71.2 2488550    13176.     10
#>  4 New Zealand  1967    71.5 2728150    14464.     15
#>  5 New Zealand  1972    71.9 2929100    16046.     20
#>  6 New Zealand  1977    72.2 3164900    16234.     25
#>  7 New Zealand  1982    73.8 3210650    17632.     30
#>  8 New Zealand  1987    74.3 3317166    19007.     35
#>  9 New Zealand  1992    76.3 3437674    18363.     40
#> 10 New Zealand  1997    77.6 3676187    21050.     45
#> 11 New Zealand  2002    79.1 3908037    23190.     50
#> 12 New Zealand  2007    80.2 4115771    25185.     55
```
  
  - [group_map()](https://dplyr.tidyverse.org/reference/group_map.html) and [group_walk()](https://dplyr.tidyverse.org/reference/group_map.html) offer 
  a way to iterate on groups of a grouped data frame. 
  

```r
oceania %>% 
  mutate(yr1952 = year - 1952) %>% 
  group_map(~broom::tidy(stats::lm(lifeExp ~ yr1952, data = .x)))
#> # A tibble: 4 x 6
#> # Groups:   country [2]
#>   country     term        estimate std.error statistic  p.value
#>   <fct>       <chr>          <dbl>     <dbl>     <dbl>    <dbl>
#> 1 Australia   (Intercept)   68.4      0.337      203.  2.07e-19
#> 2 Australia   yr1952         0.228    0.0104      21.9 8.67e-10
#> 3 New Zealand (Intercept)   68.7      0.437      157.  2.66e-18
#> 4 New Zealand yr1952         0.193    0.0135      14.3 5.41e- 8
```
  
  - [group_data()](https://dplyr.tidyverse.org/reference/group_data.html), [group_rows()](https://dplyr.tidyverse.org/reference/group_data.html), and 
  [group_keys()](https://dplyr.tidyverse.org/reference/group_split.html) expose the grouping information, that has 
  been restructured in a tibble. 


```r
oceania %>% 
  group_data()
#> # A tibble: 2 x 2
#>   country     .rows     
#>   <fct>       <list>    
#> 1 Australia   <int [12]>
#> 2 New Zealand <int [12]>

oceania %>% 
  group_keys()
#> # A tibble: 2 x 1
#>   country    
#>   <fct>      
#> 1 Australia  
#> 2 New Zealand

oceania %>% 
  group_rows()
#> [[1]]
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12
#> 
#> [[2]]
#>  [1] 13 14 15 16 17 18 19 20 21 22 23 24
```
 
  - [group_by()](https://dplyr.tidyverse.org/reference/group_by.html) gains a `.drop` argument
  which you can set to `FALSE` to respect empty groups associated with factors (more on this below). 

## Give factors some love

The internal grouping algorithm has been redesigned to make it possible to 
better respect factor levels and empty groups. To limit the disruption, we have not made
this the default behaviour. To keep empty groups, 
you have to set [group_by()](https://dplyr.tidyverse.org/reference/group_by.html)'s 
`.drop` argument to `FALSE`. 

This can make data manipulation more predictable and reliable, because when factors are 
involved, the groups are based on the levels of the factors, rather than which levels 
have data points. 

Let's illustrate this with our favourite flowers 💐, 
and a function, `species_count()`, that counts the number of each species after 
a `filter()`, and structures it as a tibble with one column per species. 


```r
species_count <- function(...) {
  iris %>% 
    filter(...) %>% 
    group_by(Species, .drop = FALSE) %>% 
    summarise(n = n()) %>% 
    tidyr::spread(Species, n)
}
```

Because we use `.drop = FALSE` we get one column per level of the factor, 
even when there's no data associated with a level: 


```r
species_count(Petal.Length > 3)
#> # A tibble: 1 x 3
#>   setosa versicolor virginica
#>    <int>      <int>     <int>
#> 1      0         49        50
species_count(Petal.Length > 6.5)
#> # A tibble: 1 x 3
#>   setosa versicolor virginica
#>    <int>      <int>     <int>
#> 1      0          0         4
species_count(Petal.Length > 42)
#> # A tibble: 1 x 3
#>   setosa versicolor virginica
#>    <int>      <int>     <int>
#> 1      0          0         0
```

These 0 instead of missing columns make the experience easier when you want to combine multiple results: 


```r
limits <- seq(0, 8, by = .5)
limits %>% 
  purrr::map_dfr( ~species_count(Petal.Length > .x)) %>% 
  mutate(Sepal.Length = limits) %>% 
  select(Sepal.Length, everything())
#> # A tibble: 17 x 4
#>    Sepal.Length setosa versicolor virginica
#>           <dbl>  <int>      <int>     <int>
#>  1          0       50         50        50
#>  2          0.5     50         50        50
#>  3          1       49         50        50
#>  4          1.5     13         50        50
#>  5          2        0         50        50
#>  6          2.5      0         50        50
#>  7          3        0         49        50
#>  8          3.5      0         45        50
#>  9          4        0         34        50
#> 10          4.5      0         14        49
#> 11          5        0          1        41
#> 12          5.5      0          0        25
#> 13          6        0          0         9
#> 14          6.5      0          0         4
#> 15          7        0          0         0
#> 16          7.5      0          0         0
#> 17          8        0          0         0
```


## Thanks

Thanks to all contributors for this release. 

[&#x0040;abouf](https://github.com/abouf), [&#x0040;adisarid](https://github.com/adisarid), [&#x0040;adrfantini](https://github.com/adrfantini), [&#x0040;aetiologicCanada](https://github.com/aetiologicCanada), [&#x0040;afdta](https://github.com/afdta), [&#x0040;albertomv83](https://github.com/albertomv83), [&#x0040;alistaire47](https://github.com/alistaire47), [&#x0040;aloes2512](https://github.com/aloes2512), [&#x0040;andresimi](https://github.com/andresimi), [&#x0040;antaldaniel](https://github.com/antaldaniel), [&#x0040;AnthonyEbert](https://github.com/AnthonyEbert), [&#x0040;ArtemSokolov](https://github.com/ArtemSokolov), [&#x0040;AshesITR](https://github.com/AshesITR), [&#x0040;bakaburg1](https://github.com/bakaburg1), [&#x0040;batpigandme](https://github.com/batpigandme), [&#x0040;bbachrach](https://github.com/bbachrach), [&#x0040;bbolker](https://github.com/bbolker), [&#x0040;behrman](https://github.com/behrman), [&#x0040;BenjaminLouis](https://github.com/BenjaminLouis), [&#x0040;bifouba](https://github.com/bifouba), [&#x0040;billdenney](https://github.com/billdenney), [&#x0040;bnicenboim](https://github.com/bnicenboim), [&#x0040;BobMuenchen](https://github.com/BobMuenchen), [&#x0040;brooke-watson](https://github.com/brooke-watson), [&#x0040;CarolineBarret](https://github.com/CarolineBarret), [&#x0040;cbailiss](https://github.com/cbailiss), [&#x0040;CerebralMastication](https://github.com/CerebralMastication), [&#x0040;cfhammill](https://github.com/cfhammill), [&#x0040;cfry-propeller](https://github.com/cfry-propeller), [&#x0040;choisy](https://github.com/choisy), [&#x0040;ChrisBeeley](https://github.com/ChrisBeeley), [&#x0040;chrsigg](https://github.com/chrsigg), [&#x0040;clauswilke](https://github.com/clauswilke), [&#x0040;ClaytonJY](https://github.com/ClaytonJY), [&#x0040;colearendt](https://github.com/colearendt), [&#x0040;ColinFay](https://github.com/ColinFay), [&#x0040;coolbutuseless](https://github.com/coolbutuseless), [&#x0040;Copepoda](https://github.com/Copepoda), [&#x0040;cpsievert](https://github.com/cpsievert), [&#x0040;dah33](https://github.com/dah33), [&#x0040;damianooldoni](https://github.com/damianooldoni), [&#x0040;DanChaltiel](https://github.com/DanChaltiel), [&#x0040;danyal123](https://github.com/danyal123), [&#x0040;DavisVaughan](https://github.com/DavisVaughan), [&#x0040;Demetrio92](https://github.com/Demetrio92), [&#x0040;dewoller](https://github.com/dewoller), [&#x0040;dfalbel](https://github.com/dfalbel), [&#x0040;DiogoFerrari](https://github.com/DiogoFerrari), [&#x0040;dirkschumacher](https://github.com/dirkschumacher), [&#x0040;dmenne](https://github.com/dmenne), [&#x0040;dmvianna](https://github.com/dmvianna), [&#x0040;dongzhuoer](https://github.com/dongzhuoer), [&#x0040;earowang](https://github.com/earowang), [&#x0040;echasnovski](https://github.com/echasnovski), [&#x0040;eddelbuettel](https://github.com/eddelbuettel), [&#x0040;EdwinTh](https://github.com/EdwinTh), [&#x0040;eijoac](https://github.com/eijoac), [&#x0040;elbersb](https://github.com/elbersb), [&#x0040;Eli-Berkow](https://github.com/Eli-Berkow), [&#x0040;EmilHvitfeldt](https://github.com/EmilHvitfeldt), [&#x0040;epetrovski](https://github.com/epetrovski), [&#x0040;erblast](https://github.com/erblast), [&#x0040;etienne-s](https://github.com/etienne-s), [&#x0040;foundinblank](https://github.com/foundinblank), [&#x0040;FrancoisGuillem](https://github.com/FrancoisGuillem), [&#x0040;geotheory](https://github.com/geotheory), [&#x0040;ggrothendieck](https://github.com/ggrothendieck), [&#x0040;GoldbergData](https://github.com/GoldbergData), [&#x0040;gowerc](https://github.com/gowerc), [&#x0040;grayskripko](https://github.com/grayskripko), [&#x0040;GrimTrigger88](https://github.com/GrimTrigger88), [&#x0040;grizzthepro64](https://github.com/grizzthepro64), [&#x0040;hadley](https://github.com/hadley), [&#x0040;hafen](https://github.com/hafen), [&#x0040;heavywatal](https://github.com/heavywatal), [&#x0040;helix123](https://github.com/helix123), [&#x0040;henrikmidtiby](https://github.com/henrikmidtiby), [&#x0040;hpeaker](https://github.com/hpeaker), [&#x0040;htc502](https://github.com/htc502), [&#x0040;hughjonesd](https://github.com/hughjonesd), [&#x0040;ignacio82](https://github.com/ignacio82), [&#x0040;igoldin2u](https://github.com/igoldin2u), [&#x0040;igordot](https://github.com/igordot), [&#x0040;ilarischeinin](https://github.com/ilarischeinin), [&#x0040;Ilia-Kosenkov](https://github.com/Ilia-Kosenkov), [&#x0040;IndrajeetPatil](https://github.com/IndrajeetPatil), [&#x0040;ipofanes](https://github.com/ipofanes), [&#x0040;jasonmhoule](https://github.com/jasonmhoule), [&#x0040;jayhesselberth](https://github.com/jayhesselberth), [&#x0040;jennybc](https://github.com/jennybc), [&#x0040;jepusto](https://github.com/jepusto), [&#x0040;jflynn264](https://github.com/jflynn264), [&#x0040;jialu512](https://github.com/jialu512), [&#x0040;JiaxiangBU](https://github.com/JiaxiangBU), [&#x0040;jimhester](https://github.com/jimhester), [&#x0040;jkylearmstrongibx](https://github.com/jkylearmstrongibx), [&#x0040;jnolis](https://github.com/jnolis), [&#x0040;JohnMount](https://github.com/JohnMount), [&#x0040;jonkeane](https://github.com/jonkeane), [&#x0040;jonthegeek](https://github.com/jonthegeek), [&#x0040;jschelbert](https://github.com/jschelbert), [&#x0040;jsekamane](https://github.com/jsekamane), [&#x0040;jtelleria](https://github.com/jtelleria), [&#x0040;kendonB](https://github.com/kendonB), [&#x0040;kevinykuo](https://github.com/kevinykuo), [&#x0040;krlmlr](https://github.com/krlmlr), [&#x0040;langbe](https://github.com/langbe), [&#x0040;ldecicco-USGS](https://github.com/ldecicco-USGS), [&#x0040;leungi](https://github.com/leungi), [&#x0040;libbieweimer](https://github.com/libbieweimer), [&#x0040;lionel-](https://github.com/lionel-), [&#x0040;liz-is](https://github.com/liz-is), [&#x0040;lloven](https://github.com/lloven), [&#x0040;ltrgoddard](https://github.com/ltrgoddard), [&#x0040;luccastermans](https://github.com/luccastermans), [&#x0040;maicel1978](https://github.com/maicel1978), [&#x0040;Make42](https://github.com/Make42), [&#x0040;MalditoBarbudo](https://github.com/MalditoBarbudo), [&#x0040;markdly](https://github.com/markdly), [&#x0040;markvanderloo](https://github.com/markvanderloo), [&#x0040;mattbk](https://github.com/mattbk), [&#x0040;maxheld83](https://github.com/maxheld83), [&#x0040;melissakey](https://github.com/melissakey), [&#x0040;mem48](https://github.com/mem48), [&#x0040;mgirlich](https://github.com/mgirlich), [&#x0040;mikmart](https://github.com/mikmart), [&#x0040;MilesMcBain](https://github.com/MilesMcBain), [&#x0040;minhsphuc12](https://github.com/minhsphuc12), [&#x0040;mkoohafkan](https://github.com/mkoohafkan), [&#x0040;momeara](https://github.com/momeara), [&#x0040;moodymudskipper](https://github.com/moodymudskipper), [&#x0040;move[bot]](https://github.com/move[bot]), [&#x0040;nealpsmith](https://github.com/nealpsmith), [&#x0040;NightWinkle](https://github.com/NightWinkle), [&#x0040;o1iv3r](https://github.com/o1iv3r), [&#x0040;PascalKieslich](https://github.com/PascalKieslich), [&#x0040;petermeissner](https://github.com/petermeissner), [&#x0040;peterzsohar](https://github.com/peterzsohar), [&#x0040;philstraforelli](https://github.com/philstraforelli), [&#x0040;PMassicotte](https://github.com/PMassicotte), [&#x0040;PPICARDO](https://github.com/PPICARDO), [&#x0040;privefl](https://github.com/privefl), [&#x0040;prokulski](https://github.com/prokulski), [&#x0040;quartin](https://github.com/quartin), [&#x0040;rabutler-usbr](https://github.com/rabutler-usbr), [&#x0040;ramongallego](https://github.com/ramongallego), [&#x0040;randomgambit](https://github.com/randomgambit), [&#x0040;rappster](https://github.com/rappster), [&#x0040;rensa](https://github.com/rensa), [&#x0040;reshmamena](https://github.com/reshmamena), [&#x0040;richard987](https://github.com/richard987), [&#x0040;richierocks](https://github.com/richierocks), [&#x0040;RickPack](https://github.com/RickPack), [&#x0040;riship2009](https://github.com/riship2009), [&#x0040;RobertMyles](https://github.com/RobertMyles), [&#x0040;romainfrancois](https://github.com/romainfrancois), [&#x0040;rontomer](https://github.com/rontomer), [&#x0040;roumail](https://github.com/roumail), [&#x0040;rozsoma](https://github.com/rozsoma), [&#x0040;rundel](https://github.com/rundel), [&#x0040;rupesh2017](https://github.com/rupesh2017), [&#x0040;s-fleck](https://github.com/s-fleck), [&#x0040;S-UP](https://github.com/S-UP), [&#x0040;salmansyed0709](https://github.com/salmansyed0709), [&#x0040;schloerke](https://github.com/schloerke), [&#x0040;seasmith](https://github.com/seasmith), [&#x0040;sharlagelfand](https://github.com/sharlagelfand), [&#x0040;shizidushu](https://github.com/shizidushu), [&#x0040;simon-anasta](https://github.com/simon-anasta), [&#x0040;skaltman](https://github.com/skaltman), [&#x0040;skylarhopkins](https://github.com/skylarhopkins), [&#x0040;sowla](https://github.com/sowla), [&#x0040;statsccpr](https://github.com/statsccpr), [&#x0040;stenhaug](https://github.com/stenhaug), [&#x0040;streamline55](https://github.com/streamline55), [&#x0040;stuartE9](https://github.com/stuartE9), [&#x0040;stufield](https://github.com/stufield), [&#x0040;suzanbaert](https://github.com/suzanbaert), [&#x0040;sverchkov](https://github.com/sverchkov), [&#x0040;thackl](https://github.com/thackl), [&#x0040;the-knife](https://github.com/the-knife), [&#x0040;ThiAmm](https://github.com/ThiAmm), [&#x0040;thisisnic](https://github.com/thisisnic), [&#x0040;tinyheero](https://github.com/tinyheero), [&#x0040;tmelconian](https://github.com/tmelconian), [&#x0040;tobadia](https://github.com/tobadia), [&#x0040;tonyelhabr](https://github.com/tonyelhabr), [&#x0040;torbjorn](https://github.com/torbjorn), [&#x0040;trueNico](https://github.com/trueNico), [&#x0040;tungmilan](https://github.com/tungmilan), [&#x0040;TylerGrantSmith](https://github.com/TylerGrantSmith), [&#x0040;ukkonen](https://github.com/ukkonen), [&#x0040;vincentanutama](https://github.com/vincentanutama), [&#x0040;vnijs](https://github.com/vnijs), [&#x0040;wanfahmi](https://github.com/wanfahmi), [&#x0040;waynelapierre](https://github.com/waynelapierre), [&#x0040;wch](https://github.com/wch), [&#x0040;wdenton](https://github.com/wdenton), [&#x0040;wgrundlingh](https://github.com/wgrundlingh), [&#x0040;wmayner](https://github.com/wmayner), [&#x0040;wolski](https://github.com/wolski), [&#x0040;yiqinfu](https://github.com/yiqinfu), [&#x0040;yutannihilation](https://github.com/yutannihilation), [&#x0040;Zanidean](https://github.com/Zanidean), [&#x0040;Zedseayou](https://github.com/Zedseayou), [&#x0040;zslajchrt](https://github.com/zslajchrt), [&#x0040;zx8754](https://github.com/zx8754), and [&#x0040;zzygyx9119](https://github.com/zzygyx9119).
