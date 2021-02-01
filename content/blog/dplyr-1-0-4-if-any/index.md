---
output: hugodown::md_document

slug: dplyr-1-0-4-if-any
title: dplyr 1.0.4 if_any() and if_all()
date: 2021-02-01
author: Romain Francois

photo:
  url: https://unsplash.com/photos/nQz49efZEFs
  author: Mattias Olsson

categories: [package] 
tags: [dplyr]
rmd_hash: abc52f742d1a092e

---

We're happy to announce the release of [dplyr](https://dplyr.tidyverse.org) 1.0.4. dplyr is the data manipulation package of the [tidyverse](https://www.tidyverse.org).

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"dplyr"</span><span class='o'>)</span></code></pre>

</div>

This blog post will discuss the two most important changes of the 1.0.4 release: the new [`if_any()`](https://dplyr.tidyverse.org/reference/across.html) and [`if_all()`](https://dplyr.tidyverse.org/reference/across.html) functions, and performance improvements for [`across()`](https://dplyr.tidyverse.org/reference/across.html).

You can see a full list of changes in the [release notes](%7B%20github_release%20%7D)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://dplyr.tidyverse.org'>dplyr</a></span>, warn.conflicts <span class='o'>=</span> <span class='kc'>FALSE</span><span class='o'>)</span></code></pre>

</div>

if\_any() and if\_all()
-----------------------

The new [`across()`](https://dplyr.tidyverse.org/reference/across.html) function introduced as part of dplyr 1.0.0 is starting to be a successful addition to dplyr. In case you missed it, [`across()`](https://dplyr.tidyverse.org/reference/across.html) lets you conveniently express a set of actions to be performed across a tidy selection of columns.

However useful [`across()`](https://dplyr.tidyverse.org/reference/across.html) may be within [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html) and [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html), we discovered that it is not optimal in the context of [`filter()`](https://dplyr.tidyverse.org/reference/filter.html), and is not sufficient in itself to replace the set of column wise [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) variant it meant to supersede.

To fill the gap, we're introducing the two functions [`if_all()`](https://dplyr.tidyverse.org/reference/across.html) and [`if_any()`](https://dplyr.tidyverse.org/reference/across.html). Let's directly dive in to an example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://allisonhorst.github.io/palmerpenguins/'>palmerpenguins</a></span><span class='o'>)</span>

<span class='nv'>big</span> <span class='o'>&lt;-</span> <span class='kr'>function</span><span class='o'>(</span><span class='nv'>x</span><span class='o'>)</span> <span class='o'>&#123;</span>
  <span class='nv'>x</span> <span class='o'>&gt;</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>x</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>
<span class='o'>&#125;</span>

<span class='nv'>penguins</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>if_all</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>contains</a></span><span class='o'>(</span><span class='s'>"bill"</span><span class='o'>)</span>, <span class='nv'>big</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 61 x 8</span></span>
<span class='c'>#&gt;    species island bill_length_mm bill_depth_mm flipper_length_… body_mass_g</span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;fct&gt;</span><span>   </span><span style='color: #555555;font-style: italic;'>&lt;fct&gt;</span><span>           </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>         </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>       </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> Adelie  Torge…           46            21.5              194        </span><span style='text-decoration: underline;'>4</span><span>200</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> Adelie  Dream            44.1          19.7              196        </span><span style='text-decoration: underline;'>4</span><span>400</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> Adelie  Torge…           45.8          18.9              197        </span><span style='text-decoration: underline;'>4</span><span>150</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> Adelie  Biscoe           45.6          20.3              191        </span><span style='text-decoration: underline;'>4</span><span>600</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> Adelie  Torge…           44.1          18                210        </span><span style='text-decoration: underline;'>4</span><span>000</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> Gentoo  Biscoe           44.4          17.3              219        </span><span style='text-decoration: underline;'>5</span><span>250</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> Gentoo  Biscoe           50.8          17.3              228        </span><span style='text-decoration: underline;'>5</span><span>600</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> Chinst… Dream            46.5          17.9              192        </span><span style='text-decoration: underline;'>3</span><span>500</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> Chinst… Dream            50            19.5              196        </span><span style='text-decoration: underline;'>3</span><span>900</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> Chinst… Dream            51.3          19.2              193        </span><span style='text-decoration: underline;'>3</span><span>650</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 51 more rows, and 2 more variables: sex </span><span style='color: #555555;font-style: italic;'>&lt;fct&gt;</span><span style='color: #555555;'>, year </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>

<span class='nv'>penguins</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>if_any</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>contains</a></span><span class='o'>(</span><span class='s'>"bill"</span><span class='o'>)</span>, <span class='nv'>big</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 296 x 8</span></span>
<span class='c'>#&gt;    species island bill_length_mm bill_depth_mm flipper_length_… body_mass_g</span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;fct&gt;</span><span>   </span><span style='color: #555555;font-style: italic;'>&lt;fct&gt;</span><span>           </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>         </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span>            </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>       </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> Adelie  Torge…           39.1          18.7              181        </span><span style='text-decoration: underline;'>3</span><span>750</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> Adelie  Torge…           39.5          17.4              186        </span><span style='text-decoration: underline;'>3</span><span>800</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> Adelie  Torge…           40.3          18                195        </span><span style='text-decoration: underline;'>3</span><span>250</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> Adelie  Torge…           36.7          19.3              193        </span><span style='text-decoration: underline;'>3</span><span>450</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> Adelie  Torge…           39.3          20.6              190        </span><span style='text-decoration: underline;'>3</span><span>650</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> Adelie  Torge…           38.9          17.8              181        </span><span style='text-decoration: underline;'>3</span><span>625</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> Adelie  Torge…           39.2          19.6              195        </span><span style='text-decoration: underline;'>4</span><span>675</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> Adelie  Torge…           34.1          18.1              193        </span><span style='text-decoration: underline;'>3</span><span>475</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> Adelie  Torge…           42            20.2              190        </span><span style='text-decoration: underline;'>4</span><span>250</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> Adelie  Torge…           37.8          17.3              180        </span><span style='text-decoration: underline;'>3</span><span>700</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 286 more rows, and 2 more variables: sex </span><span style='color: #555555;font-style: italic;'>&lt;fct&gt;</span><span style='color: #555555;'>, year </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span></code></pre>

</div>

Both functions operate similarly to [`across()`](https://dplyr.tidyverse.org/reference/across.html) but go the extra mile of aggregating the results to indicate if *all* the results are true when using [`if_all()`](https://dplyr.tidyverse.org/reference/across.html), or if *at least one* is true when using [`if_any()`](https://dplyr.tidyverse.org/reference/across.html).

Although [`if_all()`](https://dplyr.tidyverse.org/reference/across.html) and [`if_any()`](https://dplyr.tidyverse.org/reference/across.html) were designed with [`filter()`](https://dplyr.tidyverse.org/reference/filter.html) in mind, we then discovered through [this github issue](https://github.com/tidyverse/dplyr/issues/5709) that they can be equally useful when used within [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) and/or [`summarise()`](https://dplyr.tidyverse.org/reference/summarise.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>penguins</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/filter.html'>filter</a></span><span class='o'>(</span><span class='o'>!</span><span class='nf'><a href='https://rdrr.io/r/base/NA.html'>is.na</a></span><span class='o'>(</span><span class='nv'>bill_length_mm</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/mutate.html'>mutate</a></span><span class='o'>(</span>
    category <span class='o'>=</span> <span class='nf'><a href='https://dplyr.tidyverse.org/reference/case_when.html'>case_when</a></span><span class='o'>(</span>
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>if_all</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>contains</a></span><span class='o'>(</span><span class='s'>"bill"</span><span class='o'>)</span>, <span class='nv'>big</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"both big"</span>, 
      <span class='nf'><a href='https://dplyr.tidyverse.org/reference/across.html'>if_any</a></span><span class='o'>(</span><span class='nf'><a href='https://tidyselect.r-lib.org/reference/starts_with.html'>contains</a></span><span class='o'>(</span><span class='s'>"bill"</span><span class='o'>)</span>, <span class='nv'>big</span><span class='o'>)</span> <span class='o'>~</span> <span class='s'>"one big"</span>, 
      <span class='kc'>TRUE</span>                          <span class='o'>~</span> <span class='s'>"small"</span>
    <span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span> 
  <span class='nf'><a href='https://dplyr.tidyverse.org/reference/count.html'>count</a></span><span class='o'>(</span><span class='nv'>category</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 2</span></span>
<span class='c'>#&gt;   category     n</span>
<span class='c'>#&gt; <span style='color: #555555;'>*</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;chr&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> both big    61</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> one big    235</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> small       46</span></span></code></pre>

</div>

Faster across()
---------------

Acknowledgements
----------------

[@abalter](https://github.com/abalter), [@cuixueqin](https://github.com/cuixueqin), [@eggrandio](https://github.com/eggrandio), [@everetr](https://github.com/everetr), [@hadley](https://github.com/hadley), [@hjohns12](https://github.com/hjohns12), [@iago-pssjd](https://github.com/iago-pssjd), [@jahonamir](https://github.com/jahonamir), [@krlmlr](https://github.com/krlmlr), [@lionel-](https://github.com/lionel-), [@lotard](https://github.com/lotard), [@luispfonseca](https://github.com/luispfonseca), [@mbcann01](https://github.com/mbcann01), [@mutahiwachira](https://github.com/mutahiwachira), [@Robinlovelace](https://github.com/Robinlovelace), [@romainfrancois](https://github.com/romainfrancois), [@rpruim](https://github.com/rpruim), [@shahronak47](https://github.com/shahronak47), [@shangguandong1996](https://github.com/shangguandong1996), [@sylvainDaubree](https://github.com/sylvainDaubree), [@tomazweiss](https://github.com/tomazweiss), [@vhorvath](https://github.com/vhorvath), [@wasdoff](https://github.com/wasdoff), and [@Yunuuuu](https://github.com/Yunuuuu).

