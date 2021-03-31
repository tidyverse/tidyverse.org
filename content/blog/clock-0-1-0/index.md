---
output: hugodown::hugo_document
slug: clock-0-1-0
title: Comprehensive Date-Time Handling for R
date: 2021-03-31
author: Davis Vaughan
description: >
    Introducing, clock, a new package for working with date-times.
photo:
  
  url: https://unsplash.com/photos/FlHdnPO6dlw
  author: Jon Tyson
categories: [package] 
tags: ["r-lib"]
editor_options: 
  chunk_output_type: console
rmd_hash: e8738b759e59a04c

---

<div class="highlight">

</div>

We're thrilled to announce the first release of [clock](https://r-lib.github.io/clock/index.html). clock is a new package providing a comprehensive set of tools for working with date-times. It is packed with features, including utilities for: parsing, formatting, arithmetic, rounding, and extraction/updating of individual components. In addition to these tools for manipulating date-times, clock provides entirely new date-time types which are structured to reduce the agony of working with time zones as much as possible. At a high-level, clock:

-   Provides a new family of date-time classes (durations, time points, zoned-times, and calendars) that partition responsibilities so that you only have to think about time zones when you need them.

-   Implements a [high level API](https://r-lib.github.io/clock/reference/index.html#section-high-level-api) for Date and POSIXct classes that lets you get productive quickly without having to learn the details of clock's new date-time types.

-   Requires explicit handling of invalid dates (e.g. what date is one month after January 31st?) and nonexistent or ambiguous times (caused by daylight saving time issues).

-   Is built on the C++ [date](https://github.com/HowardHinnant/date) library, which provides a correct and high-performance backend. In general, operations on Dates are *much* faster with clock than with lubridate. Currently, operations on POSIXct have roughly the same performance between clock and lubridate (clock's performance with POSIXct will improve greatly in a future release, once a few upstream changes in date are accepted).

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"clock"</span><span class='o'>)</span></code></pre>

</div>

This blog post will show off a few of clock's unique features. To learn more, you'll want to take a look at clock's vignettes:

-   [Getting Started](https://r-lib.github.io/clock/articles/clock.html)

-   [Motivations for clock](https://r-lib.github.io/clock/articles/articles/motivations.html)

-   [Examples and Recipes](https://r-lib.github.io/clock/articles/recipes.html)

-   [Frequently Asked Questions](https://r-lib.github.io/clock/articles/faq.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://github.com/r-lib/clock'>clock</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://github.com/hadley/nycflights13'>nycflights13</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='http://tidyverse.tidyverse.org'>tidyverse</a></span><span class='o'>)</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://lubridate.tidyverse.org'>lubridate</a></span><span class='o'>)</span></code></pre>

</div>

## Logo

Thanks to [Julie Jung](https://www.jungjulie.com/), clock has an amazing logo:

<img src="clock.png" width="250"/> <br></br>

## What about lubridate?

If you've ever worked with dates or date-times in R, you've probably used [lubridate](https://lubridate.tidyverse.org/). lubridate has powerful capabilities for working with this kind of data. So, why clock?

One of the primary motivations for creating clock was to improve on lubridate's handling of invalid dates and daylight saving time. As you'll see in the following sections, clock tries extremely hard to guard you from unexpected problems that can arise from these two complex concepts.

Additionally, clock provides a variety of new types for working with date-times. While lubridate is solely focused on working with R's native Date and POSIXct classes, clock goes many steps further with types such as: date-times without an implied time zone, nanosecond precision date-times, built-in granular types such as year-month and year-quarter, and a type for representing a weekday.

lubridate will never go away, and is not being deprecated or superseded. As of now, we consider clock to be an *alternative* to lubridate. You can stick with one or the other, or use them together, as there are no name conflicts between the two. Keep in mind that clock is a young package, with plenty of room to grow. If you have any feedback about clock, or questions about its design, we'd love for you to [open an issue](https://github.com/r-lib/clock/issues).

## First steps

The best place to start learning about clock is by checking out the [High-Level API](https://r-lib.github.io/clock/reference/index.html#section-high-level-api). This lists all of the utilities in clock that work with R's native date (Date) and date-time (POSIXct) types. You'll notice that all of these helpers start with one of the following prefixes:

-   `get_*()`: Get a component

-   `set_*()`: Set a component

-   `add_*()`: Add a unit of time

-   `date_*()`: General date manipulation

We'll explore some of these with a trimmed down version of the `flights` dataset from the nycflights13 package.

<div class="highlight">

</div>

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 5</span></span>
<span class='c'>#&gt;     year month   day dep_time dep_delay</span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>    </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1     6     </span><span style='text-decoration: underline;'>1</span><span>827        -</span><span style='color: #BB0000;'>3</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1     8     </span><span style='text-decoration: underline;'>1</span><span>458        -</span><span style='color: #BB0000;'>2</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    17     </span><span style='text-decoration: underline;'>1</span><span>823        80</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    26     </span><span style='text-decoration: underline;'>1</span><span>052        13</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    29      448       -</span><span style='color: #BB0000;'>12</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1    30        3       124</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     2     1      816        -</span><span style='color: #BB0000;'>9</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     2     4     </span><span style='text-decoration: underline;'>1</span><span>943         3</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     2    10     </span><span style='text-decoration: underline;'>1</span><span>508        36</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     2    13     </span><span style='text-decoration: underline;'>2</span><span>033        33</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

The flight departure date is separated into year, month, and day fields. We can combine these together into a Date with [`date_build()`](https://rdrr.io/pkg/clock/man/date_build.html).

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights</span> <span class='o'>&lt;-</span> <span class='nv'>flights</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    date <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/date_build.html'>date_build</a></span><span class='o'>(</span><span class='nv'>year</span>, <span class='nv'>month</span>, <span class='nv'>day</span><span class='o'>)</span>, 
    .keep <span class='o'>=</span> <span class='s'>"unused"</span>, 
    .before <span class='o'>=</span> <span class='m'>1</span>
  <span class='o'>)</span>

<span class='nv'>flights</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 3</span></span>
<span class='c'>#&gt;    date       dep_time dep_delay</span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>        </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06     </span><span style='text-decoration: underline;'>1</span><span>827        -</span><span style='color: #BB0000;'>3</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08     </span><span style='text-decoration: underline;'>1</span><span>458        -</span><span style='color: #BB0000;'>2</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17     </span><span style='text-decoration: underline;'>1</span><span>823        80</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26     </span><span style='text-decoration: underline;'>1</span><span>052        13</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29      448       -</span><span style='color: #BB0000;'>12</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30        3       124</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01      816        -</span><span style='color: #BB0000;'>9</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04     </span><span style='text-decoration: underline;'>1</span><span>943         3</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10     </span><span style='text-decoration: underline;'>1</span><span>508        36</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13     </span><span style='text-decoration: underline;'>2</span><span>033        33</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

If you need to get those individual components back, extract them with the corresponding `get_*()` function.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>mutate</span><span class='o'>(</span><span class='nv'>flights</span>, year <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-getters.html'>get_year</a></span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span>, month <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-getters.html'>get_month</a></span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 5</span></span>
<span class='c'>#&gt;    date       dep_time dep_delay  year month</span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>        </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06     </span><span style='text-decoration: underline;'>1</span><span>827        -</span><span style='color: #BB0000;'>3</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08     </span><span style='text-decoration: underline;'>1</span><span>458        -</span><span style='color: #BB0000;'>2</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17     </span><span style='text-decoration: underline;'>1</span><span>823        80  </span><span style='text-decoration: underline;'>2</span><span>013     1</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26     </span><span style='text-decoration: underline;'>1</span><span>052        13  </span><span style='text-decoration: underline;'>2</span><span>013     1</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29      448       -</span><span style='color: #BB0000;'>12</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     1</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30        3       124  </span><span style='text-decoration: underline;'>2</span><span>013     1</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01      816        -</span><span style='color: #BB0000;'>9</span><span>  </span><span style='text-decoration: underline;'>2</span><span>013     2</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04     </span><span style='text-decoration: underline;'>1</span><span>943         3  </span><span style='text-decoration: underline;'>2</span><span>013     2</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10     </span><span style='text-decoration: underline;'>1</span><span>508        36  </span><span style='text-decoration: underline;'>2</span><span>013     2</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13     </span><span style='text-decoration: underline;'>2</span><span>033        33  </span><span style='text-decoration: underline;'>2</span><span>013     2</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

To summarize the average departure delay by month, one option is to use [`date_group()`](https://rdrr.io/pkg/clock/man/date_group.html) to group by the current month of the year. For Dates, this ends up setting every day of the month to `1`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>date <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/date_group.html'>date_group</a></span><span class='o'>(</span><span class='nv'>date</span>, <span class='s'>"month"</span><span class='o'>)</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>group_by</span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>summarise</span><span class='o'>(</span>avg_delay <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/mean.html'>mean</a></span><span class='o'>(</span><span class='nv'>dep_delay</span>, na.rm <span class='o'>=</span> <span class='kc'>TRUE</span><span class='o'>)</span>, .groups <span class='o'>=</span> <span class='s'>"drop"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 12 x 2</span></span>
<span class='c'>#&gt;    date       avg_delay</span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>         </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-01     33.3 </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-02-01     16   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-03-01     41.8 </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-04-01     -</span><span style='color: #BB0000;'>3.14</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-05-01     -</span><span style='color: #BB0000;'>1.14</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-06-01     12.2 </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-07-01     15.2 </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-08-01     26.2 </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-09-01     10.2 </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-10-01     21   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>11</span><span> 2013-11-01     -</span><span style='color: #BB0000;'>4.14</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>12</span><span> 2013-12-01      6.2</span></span></code></pre>

</div>

If you've used lubridate before, you would have probably used [`lubridate::floor_date()`](http://lubridate.tidyverse.org/reference/round_date.html) for this. In clock, date summarization is broken into three groups: grouping, shifting, and rounding. This separation leads to code that is both less surprising, and more powerful, giving you the ability to summarize in new ways, such as: flooring by multiple weeks, grouping by day of the quarter, and flooring by rolling sets of, say, 60 days.

Be sure to check out the many other high-level tools for working with dates, including powerful utilities for formatting ([`date_format()`](https://r-lib.github.io/clock/reference/date_format.html)) and parsing ([`date_parse()`](https://r-lib.github.io/clock/reference/date_parse.html) and [`date_time_parse()`](https://r-lib.github.io/clock/reference/date-time-parse.html)).

As a lubridate user, none of the above should seem particularly revolutionary, and that's the entire idea of the high-level API. We've tried to make transitioning over to clock as easy as possible. In the following sections, you'll see some of the benefits you'll get from doing so.

## Invalid dates

Using our `flights` data, imagine we want to add 1 month to `date`, perhaps to set up some kind of forward looking variable. With lubridate, we can use `+ months(1)`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>mutate</span><span class='o'>(</span><span class='nv'>flights</span>, date2 <span class='o'>=</span> <span class='nv'>date</span> <span class='o'>+</span> <span class='nf'><a href='https://rdrr.io/r/base/weekday.POSIXt.html'>months</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 4</span></span>
<span class='c'>#&gt;    date       dep_time dep_delay date2     </span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>        </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dbl&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>    </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06     </span><span style='text-decoration: underline;'>1</span><span>827        -</span><span style='color: #BB0000;'>3</span><span> 2013-02-06</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08     </span><span style='text-decoration: underline;'>1</span><span>458        -</span><span style='color: #BB0000;'>2</span><span> 2013-02-08</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17     </span><span style='text-decoration: underline;'>1</span><span>823        80 2013-02-17</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26     </span><span style='text-decoration: underline;'>1</span><span>052        13 2013-02-26</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29      448       -</span><span style='color: #BB0000;'>12</span><span> </span><span style='color: #BB0000;'>NA</span><span>        </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30        3       124 </span><span style='color: #BB0000;'>NA</span><span>        </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01      816        -</span><span style='color: #BB0000;'>9</span><span> 2013-03-01</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04     </span><span style='text-decoration: underline;'>1</span><span>943         3 2013-03-04</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10     </span><span style='text-decoration: underline;'>1</span><span>508        36 2013-03-10</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13     </span><span style='text-decoration: underline;'>2</span><span>033        33 2013-03-13</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

Huh, what's up with those `NA` values? Let's try with clock:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>mutate</span><span class='o'>(</span><span class='nv'>flights</span>, date2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_months</a></span><span class='o'>(</span><span class='nv'>date</span>, <span class='m'>1</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; Error: Problem with `mutate()` input `date2`.</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span><span> Invalid date found at location 5. Resolve invalid date issues by specifying the `invalid` argument.</span></span>
<span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span><span> Input `date2` is `add_months(date, 1)`.</span></span></code></pre>

</div>

What's this about an invalid date? Location 5? Taking a closer look, we can see that adding 1 month to `2013-01-29` theoretically results in `2013-02-29`, which doesn't exist. In clock, this is known as an *invalid date*. With lubridate, invalid dates result in a silent `NA`. With clock, an error is raised.

So, how do we handle this? Well, there are a number of things that you could do:

-   Return `NA`

-   Return the previous valid moment in time

-   Return the next valid moment in time

-   Overflow our invalid date into March by the number of days past the true end of February that it landed at

With lubridate, [`%m+%`](http://lubridate.tidyverse.org/reference/mplus.html) (i.e. [`add_with_rollback()`](http://lubridate.tidyverse.org/reference/mplus.html)) can help with the second and third bullets. The hardest part about [`%m+%`](http://lubridate.tidyverse.org/reference/mplus.html) is just remembering to use it. It is a common bug to forget to use this helper until *after* you have been bitten by an invalid date issue with an unexpected `NA`.

With clock, the error message advised us to use the `invalid` argument to [`add_months()`](https://rdrr.io/pkg/clock/man/clock-arithmetic.html). This allows for explicitly specifying one of many invalid date resolution strategies.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>problems</span> <span class='o'>&lt;-</span> <span class='nv'>flights</span> <span class='o'>%&gt;%</span>
  <span class='nf'>select</span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>slice</span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='m'>5</span>, <span class='m'>6</span><span class='o'>)</span><span class='o'>)</span>

<span class='nv'>problems</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    date2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_months</a></span><span class='o'>(</span><span class='nv'>date</span>, <span class='m'>1</span>, invalid <span class='o'>=</span> <span class='s'>"previous"</span><span class='o'>)</span>,
    date3 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_months</a></span><span class='o'>(</span><span class='nv'>date</span>, <span class='m'>1</span>, invalid <span class='o'>=</span> <span class='s'>"next"</span><span class='o'>)</span>,
    date4 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_months</a></span><span class='o'>(</span><span class='nv'>date</span>, <span class='m'>1</span>, invalid <span class='o'>=</span> <span class='s'>"overflow"</span><span class='o'>)</span>,
    date5 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_months</a></span><span class='o'>(</span><span class='nv'>date</span>, <span class='m'>1</span>, invalid <span class='o'>=</span> <span class='s'>"NA"</span><span class='o'>)</span>
  <span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 x 5</span></span>
<span class='c'>#&gt;   date       date2      date3      date4      date5     </span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>    </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> 2013-01-29 2013-02-28 2013-03-01 2013-03-01 </span><span style='color: #BB0000;'>NA</span><span>        </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> 2013-01-30 2013-02-28 2013-03-01 2013-03-02 </span><span style='color: #BB0000;'>NA</span></span></code></pre>

</div>

The overarching goal of clock is to protect you from issues like invalid dates by erroring early and often, rather than letting them slip through unnoticed, only to cause hard to debug issues down the line. If you're thinking, "That would never happen to me!", consider that if you had a daily sequence of every date in a particular year, and added 1 month to each date in that sequence, you would immediately generate *7 invalid dates* (6 if you chose a leap year).

## Daylight saving time

The `dep_time` column of `flights` contains the hour and minute of the actual departure time, encoded together into a single integer. Let's extract that.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights_hm</span> <span class='o'>&lt;-</span> <span class='nv'>flights</span> <span class='o'>%&gt;%</span>
  <span class='nf'>select</span><span class='o'>(</span><span class='nv'>date</span>, <span class='nv'>dep_time</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    hour <span class='o'>=</span> <span class='nv'>dep_time</span> <span class='o'>%/%</span> <span class='m'>100L</span>,
    minute <span class='o'>=</span> <span class='nv'>dep_time</span> <span class='o'>%%</span> <span class='m'>100L</span>,
    .keep <span class='o'>=</span> <span class='s'>"unused"</span>
  <span class='o'>)</span>

<span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span><span class='nv'>flights_hm</span>, n <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 2 x 3</span></span>
<span class='c'>#&gt;   date        hour minute</span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>  </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> 2013-01-06    18     27</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> 2013-01-08    14     58</span></span></code></pre>

</div>

We'd like to be able to add this time of day information to our `date` column. This flight information was recorded in the America/New_York time zone, so our resulting date-time should have that time zone as well. However, converting Date -\> POSIXct will *always* assume that Date starts as UTC, rather than being naive to any time zones, and the result will use your system's local time zone. This can have unintended side effects:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># My local time zone is actually America/New_York.</span>
<span class='c'># The conversion to POSIXct retains the underlying UTC instant, but</span>
<span class='c'># the printed time changes unexpectedly, showing the equivalent time</span>
<span class='c'># in the local time zone.</span>
<span class='nv'>flights_hm</span> <span class='o'>%&gt;%</span>
  <span class='nf'>select</span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    datetime <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span>,
    datetime_utc <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/date-zone.html'>date_set_zone</a></span><span class='o'>(</span><span class='nv'>datetime</span>, <span class='s'>"UTC"</span><span class='o'>)</span>
  <span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rdrr.io/r/utils/head.html'>head</a></span><span class='o'>(</span>n <span class='o'>=</span> <span class='m'>3</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 3</span></span>
<span class='c'>#&gt;   date       datetime            datetime_utc       </span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>              </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>             </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> 2013-01-06 2013-01-05 </span><span style='color: #555555;'>19:00:00</span><span> 2013-01-06 </span><span style='color: #555555;'>00:00:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> 2013-01-08 2013-01-07 </span><span style='color: #555555;'>19:00:00</span><span> 2013-01-08 </span><span style='color: #555555;'>00:00:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> 2013-01-17 2013-01-16 </span><span style='color: #555555;'>19:00:00</span><span> 2013-01-17 </span><span style='color: #555555;'>00:00:00</span></span></code></pre>

</div>

To get what we want, we need to convince the `date` column to "forget" that it is UTC, then add on the America/New_York time zone. With clock, we'll do this by going through a new intermediate type called naive-time, a date-time type with a yet-to-be-specified time zone. The ability to separate a date-time from its associated time zone is one of clock's most powerful features, which we'll explore more in the Time Points section below. For now, the important thing is that this retains the printed time as we expected.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights_dt</span> <span class='o'>&lt;-</span> <span class='nv'>flights_hm</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    datetime <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='o'>(</span><span class='nf'><a href='https://rdrr.io/pkg/clock/man/as_naive_time.html'>as_naive_time</a></span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span>, <span class='s'>"America/New_York"</span><span class='o'>)</span>,
    .keep <span class='o'>=</span> <span class='s'>"unused"</span>,
    .before <span class='o'>=</span> <span class='m'>1</span>
  <span class='o'>)</span>

<span class='nv'>flights_dt</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 3</span></span>
<span class='c'>#&gt;    datetime             hour minute</span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>              </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span><span>  </span><span style='color: #555555;font-style: italic;'>&lt;int&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06 </span><span style='color: #555555;'>00:00:00</span><span>    18     27</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08 </span><span style='color: #555555;'>00:00:00</span><span>    14     58</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17 </span><span style='color: #555555;'>00:00:00</span><span>    18     23</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26 </span><span style='color: #555555;'>00:00:00</span><span>    10     52</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29 </span><span style='color: #555555;'>00:00:00</span><span>     4     48</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30 </span><span style='color: #555555;'>00:00:00</span><span>     0      3</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01 </span><span style='color: #555555;'>00:00:00</span><span>     8     16</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04 </span><span style='color: #555555;'>00:00:00</span><span>    19     43</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10 </span><span style='color: #555555;'>00:00:00</span><span>    15      8</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13 </span><span style='color: #555555;'>00:00:00</span><span>    20     33</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

We can now add on our hours and minutes.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights_dt</span> <span class='o'>&lt;-</span> <span class='nv'>flights_dt</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    datetime <span class='o'>=</span> <span class='nv'>datetime</span> <span class='o'>%&gt;%</span>
      <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_hours</a></span><span class='o'>(</span><span class='nv'>hour</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
      <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_minutes</a></span><span class='o'>(</span><span class='nv'>minute</span><span class='o'>)</span>,
    .keep <span class='o'>=</span> <span class='s'>"unused"</span>
  <span class='o'>)</span>

<span class='nv'>flights_dt</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 1</span></span>
<span class='c'>#&gt;    datetime           </span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>             </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06 </span><span style='color: #555555;'>18:27:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08 </span><span style='color: #555555;'>14:58:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17 </span><span style='color: #555555;'>18:23:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26 </span><span style='color: #555555;'>10:52:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29 </span><span style='color: #555555;'>04:48:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30 </span><span style='color: #555555;'>00:03:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01 </span><span style='color: #555555;'>08:16:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04 </span><span style='color: #555555;'>19:43:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10 </span><span style='color: #555555;'>15:08:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13 </span><span style='color: #555555;'>20:33:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

Now assume that we want to add two days to this `datetime` column, again to construct some forward looking variable.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights_dt_lubridate</span> <span class='o'>&lt;-</span> <span class='nv'>flights_dt</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>datetime2 <span class='o'>=</span> <span class='nv'>datetime</span> <span class='o'>+</span> <span class='nf'><a href='http://lubridate.tidyverse.org/reference/period.html'>days</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>)</span><span class='o'>)</span>

<span class='nv'>flights_dt_lubridate</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 2</span></span>
<span class='c'>#&gt;    datetime            datetime2          </span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>              </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>             </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06 </span><span style='color: #555555;'>18:27:00</span><span> 2013-01-08 </span><span style='color: #555555;'>18:27:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08 </span><span style='color: #555555;'>14:58:00</span><span> 2013-01-10 </span><span style='color: #555555;'>14:58:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17 </span><span style='color: #555555;'>18:23:00</span><span> 2013-01-19 </span><span style='color: #555555;'>18:23:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26 </span><span style='color: #555555;'>10:52:00</span><span> 2013-01-28 </span><span style='color: #555555;'>10:52:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29 </span><span style='color: #555555;'>04:48:00</span><span> 2013-01-31 </span><span style='color: #555555;'>04:48:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30 </span><span style='color: #555555;'>00:03:00</span><span> 2013-02-01 </span><span style='color: #555555;'>00:03:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01 </span><span style='color: #555555;'>08:16:00</span><span> 2013-02-03 </span><span style='color: #555555;'>08:16:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04 </span><span style='color: #555555;'>19:43:00</span><span> 2013-02-06 </span><span style='color: #555555;'>19:43:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10 </span><span style='color: #555555;'>15:08:00</span><span> 2013-02-12 </span><span style='color: #555555;'>15:08:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13 </span><span style='color: #555555;'>20:33:00</span><span> 2013-02-15 </span><span style='color: #555555;'>20:33:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

Looks reasonable. Now with clock:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights_dt</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>datetime2 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_days</a></span><span class='o'>(</span><span class='nv'>datetime</span>, <span class='m'>2</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; Error: Problem with `mutate()` input `datetime2`.</span>
<span class='c'>#&gt; <span style='color: #BB0000;'>✖</span><span> Nonexistent time due to daylight saving time at location 18. Resolve nonexistent time issues by specifying the `nonexistent` argument.</span></span>
<span class='c'>#&gt; <span style='color: #0000BB;'>ℹ</span><span> Input `datetime2` is `add_days(datetime, 2)`.</span></span></code></pre>

</div>

Another problem! This time a *nonexistent time* at row 18. Let's investigate what lubridate gave us here:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights_dt_lubridate</span><span class='o'>[</span><span class='m'>18</span>,<span class='o'>]</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 x 2</span></span>
<span class='c'>#&gt;   datetime            datetime2          </span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>              </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>             </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> 2013-03-08 </span><span style='color: #555555;'>02:23:00</span><span> </span><span style='color: #BB0000;'>NA</span></span></code></pre>

</div>

An `NA`? But why?

As it turns out, in the America/New_York time zone, on 2013-03-10 the clocks jumped forward from 01:59:59 -\> 03:00:00, creating a daylight saving time gap, and a *nonexistent* 2 o'clock hour. By adding two days, we've landed right in that gap (at 02:23:00). With nonexistent times like this, lubridate silently returns `NA`, while clock errors.

Like with invalid dates, clock tries to guard you from these issues by erroring as soon as they occur. You can resolve these particular issues with the `nonexistent` argument to [`add_days()`](https://rdrr.io/pkg/clock/man/clock-arithmetic.html). In this case, we could:

-   Roll forward to the next valid moment in time

-   Roll backward to the previous valid moment in time

-   Shift forward by the size of the gap

-   Shift backward by the size of the gap

-   Return `NA`

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>problem</span> <span class='o'>&lt;-</span> <span class='nv'>flights_dt</span><span class='o'>$</span><span class='nv'>datetime</span><span class='o'>[</span><span class='m'>18</span><span class='o'>]</span>
<span class='nv'>problem</span>
<span class='c'>#&gt; [1] "2013-03-08 02:23:00 EST"</span>

<span class='c'># 02:23:00 -&gt; 03:00:00</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_days</a></span><span class='o'>(</span><span class='nv'>problem</span>, <span class='m'>2</span>, nonexistent <span class='o'>=</span> <span class='s'>"roll-forward"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "2013-03-10 03:00:00 EDT"</span>

<span class='c'># 02:23:00 -&gt; 01:59:59</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_days</a></span><span class='o'>(</span><span class='nv'>problem</span>, <span class='m'>2</span>, nonexistent <span class='o'>=</span> <span class='s'>"roll-backward"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "2013-03-10 01:59:59 EST"</span>

<span class='c'># 02:23:00 -&gt; 03:23:00</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_days</a></span><span class='o'>(</span><span class='nv'>problem</span>, <span class='m'>2</span>, nonexistent <span class='o'>=</span> <span class='s'>"shift-forward"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "2013-03-10 03:23:00 EDT"</span>

<span class='c'># 02:23:00 -&gt; 01:23:00</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_days</a></span><span class='o'>(</span><span class='nv'>problem</span>, <span class='m'>2</span>, nonexistent <span class='o'>=</span> <span class='s'>"shift-backward"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "2013-03-10 01:23:00 EST"</span>

<span class='c'># 02:23:00 -&gt; NA</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_days</a></span><span class='o'>(</span><span class='nv'>problem</span>, <span class='m'>2</span>, nonexistent <span class='o'>=</span> <span class='s'>"NA"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] NA</span></code></pre>

</div>

I recommend `"roll-forward"` or `"roll-backward"`, as these retain the *relative ordering* of `datetime`, an issue that you can read about [here](https://r-lib.github.io/clock/articles/articles/motivations.html#nonexistent-time-1).

Unlike with invalid dates, lubridate does not provide any tools for resolving nonexistent times.

There are another class of daylight saving time issues related to *ambiguous times*. These generally result from daylight saving fallbacks, where your clock might show two 1 AM hours. You resolve them in a similar way to what was done with nonexistent times. If you're interested, you can read more about ambiguous times [here](https://r-lib.github.io/clock/articles/articles/motivations.html#ambiguous-time-1).

Nonexistent and ambiguous times are particularly nasty issues because they occur relatively infrequently. If your time zone uses daylight saving time, these issues each come up once per year, generally for a duration of 1 hour (but not always!). This can be incredibly frustrating in production, where an analysis that has been working fine suddenly crashes on new data due to a daylight saving time issue. Which brings me to...

## Production

This new invalid date and daylight saving time behavior might sound great to you, but you might be wondering about usage of clock in production. What happens if [`add_months()`](https://rdrr.io/pkg/clock/man/clock-arithmetic.html) worked in interactive development, but then you put your analysis into production, gathered new data, and all of the sudden it started failing?

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>dates</span> <span class='o'>&lt;-</span> <span class='nv'>flights</span><span class='o'>$</span><span class='nv'>date</span>

<span class='c'># All good! Ship it!</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_months</a></span><span class='o'>(</span><span class='nv'>dates</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span><span class='o'>]</span>, <span class='m'>1</span><span class='o'>)</span> 
<span class='c'>#&gt; [1] "2013-02-06" "2013-02-08" "2013-02-17" "2013-02-26"</span>

<span class='c'># Failed in production with new data! Oh no!</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_months</a></span><span class='o'>(</span><span class='nv'>dates</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>10</span><span class='o'>]</span>, <span class='m'>1</span><span class='o'>)</span>
<span class='c'>#&gt; Error: Invalid date found at location 5. Resolve invalid date issues by specifying the `invalid` argument.</span></code></pre>

</div>

To balance the usefulness of clock in interactive development with the strict requirements of production, you can set the `clock.strict` global option to `TRUE` to turn `invalid`, `nonexistent`, and `ambiguous` from optional arguments into required ones.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>rlang</span><span class='nf'>::</span><span class='nf'><a href='https://rlang.r-lib.org/reference/local_options.html'>with_options</a></span><span class='o'>(</span>clock.strict <span class='o'>=</span> <span class='kc'>TRUE</span>, .expr <span class='o'>=</span> <span class='o'>&#123;</span>
  <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_months</a></span><span class='o'>(</span><span class='nv'>dates</span><span class='o'>[</span><span class='m'>1</span><span class='o'>:</span><span class='m'>4</span><span class='o'>]</span>, <span class='m'>1</span><span class='o'>)</span>
<span class='o'>&#125;</span><span class='o'>)</span>
<span class='c'>#&gt; Error: The global option, `clock.strict`, is currently set to `TRUE`. In this mode, `invalid` must be set and cannot be left as `NULL`.</span></code></pre>

</div>

Forcing yourself to specify these arguments up front during interactive development is a great way to explicitly document your assumptions about these possible issues, while also guarding against future problems in production.

## Advanced features

This blog post has only scratched the surface of what clock can do. Up until now, we've only explored clock's high-level API. There exists an entire world of more powerful utilities in the low-level API that powers clock. We'll briefly explore a few of those in the next few sections, but I'd encourage checking out the rest of the [reference page](https://r-lib.github.io/clock/reference/index.html) to get a bird's-eye view of all that clock can do.

### Calendars

Calendars allow you to represent a date using an alternative format. Rather than using a typical year, month, and day of the month format, you might want to specify the fiscal year, quarter, and day of the quarter. In the end, these point to the same moment in time, just in different ways. For example:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>ymd</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_month_day.html'>year_month_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>2</span>, <span class='m'>25</span><span class='o'>)</span>

<span class='c'># Fiscal year starting in January</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/as_year_quarter_day.html'>as_year_quarter_day</a></span><span class='o'>(</span><span class='nv'>ymd</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_quarter_day&lt;January&gt;&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-Q1-56"</span>

<span class='c'># Fiscal year starting in April</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/as_year_quarter_day.html'>as_year_quarter_day</a></span><span class='o'>(</span><span class='nv'>ymd</span>, start <span class='o'>=</span> <span class='nv'>clock_months</span><span class='o'>$</span><span class='nv'>april</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_quarter_day&lt;April&gt;&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-Q4-56"</span></code></pre>

</div>

There are 5 calendars that come with clock. The neat part about these is that they have *varying precision*, from year to nanosecond. This provides built-in granular types like year-month and year-quarter.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Gregorian year, month, and day of the month</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_month_day.html'>year_month_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>1</span>, <span class='m'>14</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_month_day&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-01-14"</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_month_day.html'>year_month_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>2</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_month_day&lt;month&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-02"</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_month_day.html'>year_month_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>2</span>, <span class='m'>14</span>, <span class='m'>2</span>, <span class='m'>30</span>, <span class='m'>25</span>, <span class='m'>12345</span>, subsecond_precision <span class='o'>=</span> <span class='s'>"nanosecond"</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_month_day&lt;nanosecond&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-02-14 02:30:25.000012345"</span>

<span class='c'># Gregorian year, month, and indexed weekday of the month</span>
<span class='c'># (i.e. the 2nd Wednesday)</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_month_weekday.html'>year_month_weekday</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>2</span>, day <span class='o'>=</span> <span class='nv'>clock_weekdays</span><span class='o'>$</span><span class='nv'>wednesday</span>, index <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_month_weekday&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-02-Wed[2]"</span>

<span class='c'># Gregorian year and day of the year</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_day.html'>year_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>105</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_day&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-105"</span>

<span class='c'># Fiscal year, quarter, and day of the quarter</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_quarter_day.html'>year_quarter_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>1</span>, <span class='m'>14</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_quarter_day&lt;January&gt;&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-Q1-14"</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_quarter_day.html'>year_quarter_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>1</span>, <span class='m'>14</span>, start <span class='o'>=</span> <span class='nv'>clock_months</span><span class='o'>$</span><span class='nv'>april</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_quarter_day&lt;April&gt;&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-Q1-14"</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_quarter_day.html'>year_quarter_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>2</span><span class='o'>:</span><span class='m'>4</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;year_quarter_day&lt;January&gt;&lt;quarter&gt;[3]&gt;</span>
<span class='c'>#&gt; [1] "2019-Q2" "2019-Q3" "2019-Q4"</span>

<span class='c'># ISO year, week, and day of the week</span>
<span class='nf'><a href='https://rdrr.io/pkg/clock/man/iso_year_week_day.html'>iso_year_week_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>2</span>, <span class='nv'>clock_iso_weekdays</span><span class='o'>$</span><span class='nv'>friday</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;iso_year_week_day&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-W02-5"</span></code></pre>

</div>

As shown above, you can convert from one calendar to another with functions like [`as_year_quarter_day()`](https://rdrr.io/pkg/clock/man/as_year_quarter_day.html), and to Date or POSIXct with the standard [`as.Date()`](https://rdrr.io/r/base/as.Date.html) and [`as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html) functions.

One of the most unique features of calendars is the ability to represent invalid dates directly. In a previous section, we added 1 month to a Date and used the `invalid` argument to resolve invalid date issues. Let's swap to a year-month-day and try again. We can also use the cleaner `+ duration_months()` syntax here, which we can't use with Dates.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>invalids</span> <span class='o'>&lt;-</span> <span class='nv'>flights</span> <span class='o'>%&gt;%</span>
  <span class='nf'>select</span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    ymd <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/as_year_month_day.html'>as_year_month_day</a></span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span>,
    ymd2 <span class='o'>=</span> <span class='nv'>ymd</span> <span class='o'>+</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/duration-helper.html'>duration_months</a></span><span class='o'>(</span><span class='m'>1</span><span class='o'>)</span>
  <span class='o'>)</span>

<span class='nv'>invalids</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 3</span></span>
<span class='c'>#&gt;    date       ymd        ymd2      </span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;ymd&lt;day&gt;&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;ymd&lt;day&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06 2013-01-06 2013-02-06</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08 2013-01-08 2013-02-08</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17 2013-01-17 2013-02-17</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26 2013-01-26 2013-02-26</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29 2013-01-29 2013-02-29</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30 2013-01-30 2013-02-30</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01 2013-02-01 2013-03-01</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04 2013-02-04 2013-03-04</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10 2013-02-10 2013-03-10</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13 2013-02-13 2013-03-13</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

The `ymd2` column directly contains the invalid dates, `2013-02-29` and `2013-02-30`! You can resolve these dates at any time using [`invalid_resolve()`](https://rdrr.io/pkg/clock/man/clock-invalid.html), providing an invalid resolution strategy like we did earlier. Or, you can ignore them if you expect them to be resolved naturally in some other way. For example, if our end goal was to add 1 month, then fix the day of the month to the 15th, then these invalid dates would naturally resolve themselves:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>mutate</span><span class='o'>(</span><span class='nv'>invalids</span>, ymd3 <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-setters.html'>set_day</a></span><span class='o'>(</span><span class='nv'>ymd2</span>, <span class='m'>15</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 4</span></span>
<span class='c'>#&gt;    date       ymd        ymd2       ymd3      </span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;ymd&lt;day&gt;&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;ymd&lt;day&gt;&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;ymd&lt;day&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06 2013-01-06 2013-02-06 2013-02-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08 2013-01-08 2013-02-08 2013-02-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17 2013-01-17 2013-02-17 2013-02-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26 2013-01-26 2013-02-26 2013-02-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29 2013-01-29 2013-02-29 2013-02-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30 2013-01-30 2013-02-30 2013-02-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01 2013-02-01 2013-03-01 2013-03-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04 2013-02-04 2013-03-04 2013-03-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10 2013-02-10 2013-03-10 2013-03-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13 2013-02-13 2013-03-13 2013-03-15</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

To detect which dates are invalid, use [`invalid_detect()`](https://rdrr.io/pkg/clock/man/clock-invalid.html), which returns a logical vector that can be useful for filtering:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/stats/filter.html'>filter</a></span><span class='o'>(</span><span class='nv'>invalids</span>, <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-invalid.html'>invalid_detect</a></span><span class='o'>(</span><span class='nv'>ymd2</span><span class='o'>)</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 x 3</span></span>
<span class='c'>#&gt;   date       ymd        ymd2      </span>
<span class='c'>#&gt;   <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;ymd&lt;day&gt;&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;ymd&lt;day&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span><span> 2013-01-29 2013-01-29 2013-02-29</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span><span> 2013-01-30 2013-01-30 2013-02-30</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span><span> 2013-10-31 2013-10-31 2013-11-31</span></span></code></pre>

</div>

With invalid dates, the important thing is that they *eventually* get resolved. You must resolve them before converting to another calendar or to a Date / POSIXct.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/as.Date.html'>as.Date</a></span><span class='o'>(</span><span class='nv'>invalids</span><span class='o'>$</span><span class='nv'>ymd2</span><span class='o'>)</span>
<span class='c'>#&gt; Error: Conversion from a calendar requires that all dates are valid. Resolve invalid dates by calling `invalid_resolve()`.</span></code></pre>

</div>

### Time points and zoned-times

The daylight saving time section of this post was complicated by the need to work around time zones. If your analysis doesn't actually require time zones, you can represent a date or date-time using a *naive-time*. This date-time type makes no assumption about the current time zone, instead assuming that there is a yet-to-be-specified time zone that hasn't been declared yet.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights_nt</span> <span class='o'>&lt;-</span> <span class='nv'>flights_hm</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    naive_day <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/as_naive_time.html'>as_naive_time</a></span><span class='o'>(</span><span class='nv'>date</span><span class='o'>)</span>,
    naive_time <span class='o'>=</span> <span class='nv'>naive_day</span> <span class='o'>+</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/duration-helper.html'>duration_hours</a></span><span class='o'>(</span><span class='nv'>hour</span><span class='o'>)</span> <span class='o'>+</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/duration-helper.html'>duration_minutes</a></span><span class='o'>(</span><span class='nv'>minute</span><span class='o'>)</span>
  <span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>select</span><span class='o'>(</span><span class='nv'>date</span>, <span class='nf'>starts_with</span><span class='o'>(</span><span class='s'>"naive"</span><span class='o'>)</span><span class='o'>)</span>

<span class='nv'>flights_nt</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 3</span></span>
<span class='c'>#&gt;    date       naive_day        naive_time         </span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;date&gt;</span><span>     </span><span style='color: #555555;font-style: italic;'>&lt;tp&lt;naive&gt;&lt;day&gt;&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;tp&lt;naive&gt;&lt;minute&gt;&gt;</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06 2013-01-06       2013-01-06 18:27   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08 2013-01-08       2013-01-08 14:58   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17 2013-01-17       2013-01-17 18:23   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26 2013-01-26       2013-01-26 10:52   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29 2013-01-29       2013-01-29 04:48   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30 2013-01-30       2013-01-30 00:03   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01 2013-02-01       2013-02-01 08:16   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04 2013-02-04       2013-02-04 19:43   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10 2013-02-10       2013-02-10 15:08   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13 2013-02-13       2013-02-13 20:33   </span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

Going from Date -\> naive-time has dropped the UTC time zone assumption altogether, while keeping the printed time. This allowed us to convert back to POSIXct in an earlier example. Essentially, all that we were doing was declaring that yet-to-be-specified time zone as America/New_York, keeping the printed time where possible. We could have easily chosen a different time zone, like Europe/London.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>flights_nt</span> <span class='o'>%&gt;%</span>
  <span class='nf'>select</span><span class='o'>(</span><span class='nv'>naive_time</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'>mutate</span><span class='o'>(</span>
    datetime_ny <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='o'>(</span><span class='nv'>naive_time</span>, <span class='s'>"America/New_York"</span><span class='o'>)</span>,
    datetime_lo <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='o'>(</span><span class='nv'>naive_time</span>, <span class='s'>"Europe/London"</span><span class='o'>)</span>
  <span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 100 x 3</span></span>
<span class='c'>#&gt;    naive_time          datetime_ny         datetime_lo        </span>
<span class='c'>#&gt;    <span style='color: #555555;font-style: italic;'>&lt;tp&lt;naive&gt;&lt;minute&gt;&gt;</span><span> </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>              </span><span style='color: #555555;font-style: italic;'>&lt;dttm&gt;</span><span>             </span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 1</span><span> 2013-01-06 18:27    2013-01-06 </span><span style='color: #555555;'>18:27:00</span><span> 2013-01-06 </span><span style='color: #555555;'>18:27:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 2</span><span> 2013-01-08 14:58    2013-01-08 </span><span style='color: #555555;'>14:58:00</span><span> 2013-01-08 </span><span style='color: #555555;'>14:58:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 3</span><span> 2013-01-17 18:23    2013-01-17 </span><span style='color: #555555;'>18:23:00</span><span> 2013-01-17 </span><span style='color: #555555;'>18:23:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 4</span><span> 2013-01-26 10:52    2013-01-26 </span><span style='color: #555555;'>10:52:00</span><span> 2013-01-26 </span><span style='color: #555555;'>10:52:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 5</span><span> 2013-01-29 04:48    2013-01-29 </span><span style='color: #555555;'>04:48:00</span><span> 2013-01-29 </span><span style='color: #555555;'>04:48:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 6</span><span> 2013-01-30 00:03    2013-01-30 </span><span style='color: #555555;'>00:03:00</span><span> 2013-01-30 </span><span style='color: #555555;'>00:03:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 7</span><span> 2013-02-01 08:16    2013-02-01 </span><span style='color: #555555;'>08:16:00</span><span> 2013-02-01 </span><span style='color: #555555;'>08:16:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 8</span><span> 2013-02-04 19:43    2013-02-04 </span><span style='color: #555555;'>19:43:00</span><span> 2013-02-04 </span><span style='color: #555555;'>19:43:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'> 9</span><span> 2013-02-10 15:08    2013-02-10 </span><span style='color: #555555;'>15:08:00</span><span> 2013-02-10 </span><span style='color: #555555;'>15:08:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>10</span><span> 2013-02-13 20:33    2013-02-13 </span><span style='color: #555555;'>20:33:00</span><span> 2013-02-13 </span><span style='color: #555555;'>20:33:00</span></span>
<span class='c'>#&gt; <span style='color: #555555;'># … with 90 more rows</span></span></code></pre>

</div>

If you're used to lubridate, converting to naive-time and back with a different time zone is similar to using [`lubridate::force_tz()`](http://lubridate.tidyverse.org/reference/force_tz.html), but with more control over possible daylight saving time issues (again using `nonexistent` and `ambiguous`, but supplied directly to [`as.POSIXct()`](https://rdrr.io/r/base/as.POSIXlt.html)).

In clock, a naive-time is a particular kind of *time point*, a type that counts units of time with respect to some origin. Time points are extremely efficient at daily and sub-daily arithmetic, but calendars are better suited for monthly and yearly arithmetic. Time points are also efficient at *rounding* and *shifting*, through [`time_point_floor()`](https://rdrr.io/pkg/clock/man/time-point-rounding.html) and [`time_point_shift()`](https://rdrr.io/pkg/clock/man/time_point_shift.html), but calendars are better at *grouping*, through [`calendar_group()`](https://rdrr.io/pkg/clock/man/calendar_group.html). In the high-level API for Date and POSIXct, we gloss over these details and internally switch between these two types for you.

There is a second type of time point in clock, the sys-time, which works exactly like a naive-time *except* that it is assumed to be in UTC. If you never use a time zone aware class like POSIXct, then sys-time and naive-time are equivalent. However, once you start adding in time zones, the way you interpret each of them becomes extremely important.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>ymd</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/year_month_day.html'>year_month_day</a></span><span class='o'>(</span><span class='m'>2019</span>, <span class='m'>1</span>, <span class='m'>1</span><span class='o'>)</span>

<span class='c'># Yet-to-be-specified time zone</span>
<span class='nv'>naive</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/as_naive_time.html'>as_naive_time</a></span><span class='o'>(</span><span class='nv'>ymd</span><span class='o'>)</span>
<span class='nv'>naive</span>
<span class='c'>#&gt; &lt;time_point&lt;naive&gt;&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-01-01"</span>

<span class='c'># UTC time zone</span>
<span class='nv'>sys</span> <span class='o'>&lt;-</span> <span class='nf'><a href='https://rdrr.io/pkg/clock/man/as_sys_time.html'>as_sys_time</a></span><span class='o'>(</span><span class='nv'>ymd</span><span class='o'>)</span>
<span class='nv'>sys</span>
<span class='c'>#&gt; &lt;time_point&lt;sys&gt;&lt;day&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-01-01"</span>

<span class='c'># - Keeps printed time</span>
<span class='c'># - Changes underlying duration</span>
<span class='nf'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='o'>(</span><span class='nv'>naive</span>, <span class='s'>"America/New_York"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "2019-01-01 EST"</span>

<span class='c'># - Changes printed time</span>
<span class='c'># - Keeps underlying duration</span>
<span class='nf'><a href='https://rdrr.io/r/base/as.POSIXlt.html'>as.POSIXct</a></span><span class='o'>(</span><span class='nv'>sys</span>, <span class='s'>"America/New_York"</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "2018-12-31 19:00:00 EST"</span></code></pre>

</div>

clock also provides its own time zone aware date-time type, the zoned-time. Converting to a zoned-time from a sys-time or naive-time works the same as converting to a POSIXct, but zoned-times can have up to nanosecond precision.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nv'>naive</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_nanoseconds</a></span><span class='o'>(</span><span class='m'>100</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rdrr.io/pkg/clock/man/clock-arithmetic.html'>add_hours</a></span><span class='o'>(</span><span class='m'>2</span><span class='o'>)</span> <span class='o'>%&gt;%</span>
  <span class='nf'><a href='https://rdrr.io/pkg/clock/man/as_zoned_time.html'>as_zoned_time</a></span><span class='o'>(</span><span class='s'>"America/New_York"</span><span class='o'>)</span>
<span class='c'>#&gt; &lt;zoned_time&lt;nanosecond&gt;&lt;America/New_York&gt;[1]&gt;</span>
<span class='c'>#&gt; [1] "2019-01-01 02:00:00.000000100-05:00"</span></code></pre>

</div>

There isn't actually a lot you can do with zoned-times directly. Generally, zoned-times are the start or end points of an analysis meant for humans to interpret. In the middle, you'll convert to naive-time, sys-time, or to a calendar type to perform any date-time specific manipulations.

<div class="highlight">

</div>

