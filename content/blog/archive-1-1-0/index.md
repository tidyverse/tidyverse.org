---
output: hugodown::hugo_document

slug: archive-1-0-0
title: archive 1 0 0
date: 2021-08-23
author: Jim Hester
description: >
    archive 1.1.0 is now on CRAN!

photo:
  url: https://unsplash.com/photos/IEiAmhXehwE
  author: Nana Smirnova
  

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [package] 
tags: [r-lib]
rmd_hash: 46f61f3223838134

---

[archive](https://archive.r-lib.org/) 1.1.0 is now on CRAN. archive lets you work with file archives, such as [ZIP](https://en.wikipedia.org/wiki/ZIP_(file_format)), [tar](https://en.wikipedia.org/wiki/Tar_(computing)), [7-Zip](https://en.wikipedia.org/wiki/7-Zip) and [RAR](https://en.wikipedia.org/wiki/RAR_(file_format)) and compression formats like [gzip](https://en.wikipedia.org/wiki/Gzip), [bzip2](https://en.wikipedia.org/wiki/Bzip2), [XZ](https://en.wikipedia.org/wiki/XZ_Utils) and [Zstandard](https://en.wikipedia.org/wiki/Zstandard). It does this by building on top of the [libarchive](https://www.libarchive.org/) C library.

You can install it from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"archive"</span><span class='o'>)</span></code></pre>

</div>

This blog post will explain the main functions of archive, and show how you can use them to read from and write to archives.

You can see a full list of changes in the [release notes](https://archive.r-lib.org/news/index.html)

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://r-lib.github.io/archive/'>archive</a></span><span class='o'>)</span>
<span class='nv'>my_dir</span> <span class='o'>&lt;-</span> <span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='http://fs.r-lib.org/reference/file_temp.html'>file_temp</a></span><span class='o'>(</span><span class='o'>)</span> |&gt; <span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='http://fs.r-lib.org/reference/create.html'>dir_create</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='nf'>knitr</span><span class='nf'>::</span><span class='nv'><a href='https://rdrr.io/pkg/knitr/man/opts_knit.html'>opts_knit</a></span><span class='o'>$</span><span class='nf'>set</span><span class='o'>(</span>root.dir <span class='o'>=</span> <span class='nv'>my_dir</span><span class='o'>)</span></code></pre>

</div>

## Displaying archive contents

Use [`archive()`](https://archive.r-lib.org/reference/archive.html) to return a tibble of the files contained in a given archive.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://archive.r-lib.org/reference/archive.html'>archive</a></span><span class='o'>(</span><span class='s'>"nycflights13.zip"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 5 × 3</span></span>
<span class='c'>#&gt;   path                       size date               </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>                     <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dttm&gt;</span>             </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> nycflights13/airlines.csv   386 2021-09-29 <span style='color: #555555;'>16:32:53</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> nycflights13/airports.csv <span style='text-decoration: underline;'>71</span>209 2021-09-29 <span style='color: #555555;'>16:32:53</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> nycflights13/flights.csv  <span style='text-decoration: underline;'>90</span>886 2021-09-29 <span style='color: #555555;'>16:32:55</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>4</span> nycflights13/planes.csv   <span style='text-decoration: underline;'>72</span>927 2021-09-29 <span style='color: #555555;'>16:32:55</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>5</span> nycflights13/weather.csv  <span style='text-decoration: underline;'>86</span>753 2021-09-29 <span style='color: #555555;'>16:32:55</span></span></code></pre>

</div>

## Reading single files from an archive

[`archive_read()`](https://archive.r-lib.org/reference/archive_read.html) is used to read a single file from an archive. This function returns an R connection, which can be passed to many R functions that takes a connection object as input. All base R file system functions use connections, as well as some packages like readr.

The `file=` argument accepts numeric positions in the archive, or filenames as input.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='nf'><a href='https://archive.r-lib.org/reference/archive_read.html'>archive_read</a></span><span class='o'>(</span><span class='s'>"nycflights13.zip"</span>, file <span class='o'>=</span> <span class='m'>2</span><span class='o'>)</span>,
          n <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "faa,name,lat,lon,alt,tz,dst,tzone"                                                </span>
<span class='c'>#&gt; [2] "04G,Lansdowne Airport,41.1304722,-80.6195833,1044,-5,A,America/New_York"          </span>
<span class='c'>#&gt; [3] "06A,Moton Field Municipal Airport,32.4605722,-85.6800278,264,-6,A,America/Chicago"</span>
<span class='c'>#&gt; [4] "06C,Schaumburg Regional,41.9893408,-88.1012428,801,-6,A,America/Chicago"          </span>
<span class='c'>#&gt; [5] "06N,Randall Airport,41.431912,-74.3915611,523,-5,A,America/New_York"</span>
<span class='nf'><a href='https://rdrr.io/r/base/readLines.html'>readLines</a></span><span class='o'>(</span><span class='nf'><a href='https://archive.r-lib.org/reference/archive_read.html'>archive_read</a></span><span class='o'>(</span><span class='s'>"nycflights13.zip"</span>,
                       file <span class='o'>=</span> <span class='s'>"nycflights13/planes.csv"</span><span class='o'>)</span>,
          n <span class='o'>=</span> <span class='m'>5</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "tailnum,year,type,manufacturer,model,engines,seats,speed,engine"                 </span>
<span class='c'>#&gt; [2] "N10156,2004,Fixed wing multi engine,EMBRAER,EMB-145XR,2,55,NA,Turbo-fan"         </span>
<span class='c'>#&gt; [3] "N102UW,1998,Fixed wing multi engine,AIRBUS INDUSTRIE,A320-214,2,182,NA,Turbo-fan"</span>
<span class='c'>#&gt; [4] "N103US,1999,Fixed wing multi engine,AIRBUS INDUSTRIE,A320-214,2,182,NA,Turbo-fan"</span>
<span class='c'>#&gt; [5] "N104UW,1999,Fixed wing multi engine,AIRBUS INDUSTRIE,A320-214,2,182,NA,Turbo-fan"</span></code></pre>

</div>

## Writing single files to an archive

Similarly [`archive_write()`](https://archive.r-lib.org/reference/archive_write.html) is used to write a single file to an archive. Again this creates a writable R connection. Like reading, many base R functions work with writable connections, as well as some packages like readr.

The archive and compression formats are automatically guessed based on the output filename file extensions. However you can also specify them explicity with the `format` and `filter` options.

Here we create a new zip archive containing the file `mtcars.csv`.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'>readr</span><span class='nf'>::</span><span class='nf'><a href='https://readr.tidyverse.org/reference/write_delim.html'>write_csv</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='nf'><a href='https://archive.r-lib.org/reference/archive_write.html'>archive_write</a></span><span class='o'>(</span><span class='s'>"my-cars.zip"</span>, <span class='s'>"mtcars.csv"</span><span class='o'>)</span><span class='o'>)</span>

<span class='nf'><a href='https://archive.r-lib.org/reference/archive.html'>archive</a></span><span class='o'>(</span><span class='s'>"my-cars.zip"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 1 × 3</span></span>
<span class='c'>#&gt;   path        size date               </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>      <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dttm&gt;</span>             </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> mtcars.csv  <span style='text-decoration: underline;'>1</span>281 1980-01-01 <span style='color: #555555;'>00:00:00</span></span></code></pre>

</div>

## Writing multiple files to an archive

[`archive_write_files()`](https://archive.r-lib.org/reference/archive_write_files.html) writes multiple files to a new archive. In this case the files to be added to the archive should already be written on disk.

[`archive_write_dir()`](https://archive.r-lib.org/reference/archive_write_files.html) is a helper to archive all the files in a given directory.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://readr.tidyverse.org'>readr</a></span><span class='o'>)</span>

<span class='c'># Write a few files to the temp directory</span>
<span class='nf'><a href='https://readr.tidyverse.org/reference/write_delim.html'>write_csv</a></span><span class='o'>(</span><span class='nv'>iris</span>, <span class='s'>"iris.csv"</span><span class='o'>)</span>
<span class='nf'><a href='https://readr.tidyverse.org/reference/write_delim.html'>write_csv</a></span><span class='o'>(</span><span class='nv'>mtcars</span>, <span class='s'>"mtcars.csv"</span><span class='o'>)</span>
<span class='nf'><a href='https://readr.tidyverse.org/reference/write_delim.html'>write_csv</a></span><span class='o'>(</span><span class='nv'>airquality</span>, <span class='s'>"airquality.csv"</span><span class='o'>)</span>

<span class='c'># Add them to a new XZ compressed tar archive</span>
<span class='nf'><a href='https://archive.r-lib.org/reference/archive_write_files.html'>archive_write_files</a></span><span class='o'>(</span><span class='s'>"data.tar.xz"</span>,
                    <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"iris.csv"</span>, <span class='s'>"mtcars.csv"</span>, <span class='s'>"airquality.csv"</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'># View archive contents</span>
<span class='nf'><a href='https://archive.r-lib.org/reference/archive.html'>archive</a></span><span class='o'>(</span><span class='s'>"data.tar.xz"</span><span class='o'>)</span>
<span class='c'>#&gt; <span style='color: #555555;'># A tibble: 3 × 3</span></span>
<span class='c'>#&gt;   path            size date               </span>
<span class='c'>#&gt;   <span style='color: #555555; font-style: italic;'>&lt;chr&gt;</span>          <span style='color: #555555; font-style: italic;'>&lt;int&gt;</span> <span style='color: #555555; font-style: italic;'>&lt;dttm&gt;</span>             </span>
<span class='c'>#&gt; <span style='color: #555555;'>1</span> iris.csv        <span style='text-decoration: underline;'>3</span>716 2021-09-29 <span style='color: #555555;'>16:32:55</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>2</span> mtcars.csv      <span style='text-decoration: underline;'>1</span>281 2021-09-29 <span style='color: #555555;'>16:32:55</span></span>
<span class='c'>#&gt; <span style='color: #555555;'>3</span> airquality.csv  <span style='text-decoration: underline;'>2</span>890 2021-09-29 <span style='color: #555555;'>16:32:55</span></span></code></pre>

</div>

## Extracting multiple files from an archive

[`archive_extract()`](https://archive.r-lib.org/reference/archive_extract.html) allows you to extract one or more files to disk from an archive.

Note the archive and compression formats will be automatically detected.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='c'># Create a new directory</span>
<span class='nv'>my_dir</span> <span class='o'>&lt;-</span> <span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='http://fs.r-lib.org/reference/file_temp.html'>file_temp</a></span><span class='o'>(</span><span class='o'>)</span> |&gt; <span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='http://fs.r-lib.org/reference/create.html'>dir_create</a></span><span class='o'>(</span><span class='o'>)</span>

<span class='c'># Extract two of the files in the archive to that directory</span>
<span class='nf'><a href='https://archive.r-lib.org/reference/archive_extract.html'>archive_extract</a></span><span class='o'>(</span><span class='s'>"data.tar.xz"</span>, dir <span class='o'>=</span> <span class='nv'>my_dir</span>, files <span class='o'>=</span> <span class='nf'><a href='https://rdrr.io/r/base/c.html'>c</a></span><span class='o'>(</span><span class='s'>"iris.csv"</span>, <span class='s'>"mtcars.csv"</span><span class='o'>)</span><span class='o'>)</span>

<span class='c'># Show the extracted files</span>
<span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='http://fs.r-lib.org/reference/dir_ls.html'>dir_ls</a></span><span class='o'>(</span><span class='nv'>my_dir</span><span class='o'>)</span> |&gt; <span class='nf'>fs</span><span class='nf'>::</span><span class='nf'><a href='http://fs.r-lib.org/reference/path_file.html'>path_file</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; [1] "iris.csv"   "mtcars.csv"</span></code></pre>

</div>

## Acknowledgements

Thanks to the following users who have tried out the development versions of archive and opened issues and feature suggestions to improve it! [@cboettig](https://github.com/cboettig), [@jennybc](https://github.com/jennybc), [@jeroen](https://github.com/jeroen), and [@JMcrocs](https://github.com/JMcrocs).

