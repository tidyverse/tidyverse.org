---
title: 'lobstr 1.0.0'
author: Mara Averick
date: '2018-12-21'
slug: lobstr
description: > 
  lobstr is now on CRAN. lobstr provides tools that allow you to dig into the detail of an object.
categories:
  - package
tags:
  - lobstr
  - r-lib
photo:
  url: https://unsplash.com/photos/BmjuEqM4YOY
  author: Toa Heftiba
---



We're so happy to announce the release of [lobstr](https://lobstr.r-lib.org/) on CRAN. lobstr provides tools that allow you to dig into the internal representation and structure of R objects, in a similar vein to [`str()`](https://stat.ethz.ch/R-manual/R-devel/library/utils/html/str.html).

You can install it by running:


```r
install.packages("lobstr")
```

## Visualising R data structures with trees

### Abstract syntax trees

[`ast()`](https://lobstr.r-lib.org/reference/ast.html) draws the abstract syntax tree (AST) of R expressions. You can learn about these in greater detail in the [Abstract syntax trees](https://adv-r.hadley.nz/expressions.html#abstract-syntax-trees) section of [Advanced R](https://adv-r.hadley.nz/).


```r
ast(a + b + c)
#> █─`+` 
#> ├─█─`+` 
#> │ ├─a 
#> │ └─b 
#> └─c
```

### Call stack trees

[`cst()`](https://lobstr.r-lib.org/reference/cst.html) shows how the frames of a call stack are connected:


```r
f <- function(x) g(x)
g <- function(x) h(x)
h <- function(x) x
f(cst())
#>     █
#>  1. ├─global::f(cst())
#>  2. │ └─global::g(x)
#>  3. │   └─global::h(x)
#>  4. └─lobstr::cst()
```

Learn more about this in [The call stack](https://adv-r.hadley.nz/environments.html#call-stack).

### References

[`ref()`](https://lobstr.r-lib.org/reference/ref.html) shows the connection between shared references using a locally unique id by printing the memory address of each object (further discussed [here](https://adv-r.hadley.nz/names-values.html#copy-on-modify)). 


```r
x <- 1:100
ref(x)
#> [1:0x7fb19c66bbc8] <int>

y <- list(x, x, x)
ref(y)
#> █ [1:0x7fb19d0d5a28] <list> 
#> ├─[2:0x7fb19c66bbc8] <int> 
#> ├─[2:0x7fb19c66bbc8] 
#> └─[2:0x7fb19c66bbc8]
```


## Object inspection

The [`obj_addr()`](https://lobstr.r-lib.org/reference/obj_addr.html) function gives the address of the value that an object, `x`, points to. In [Binding basics](https://adv-r.hadley.nz/names-values.html#binding-basics), this is used to illustrate the "lazy copying" used by R: when multiple names reference the same value, they point to the same identifier. The object itself is not duplicated.


```r
x <- 1:10
y <- x

obj_addr(x)
#> [1] "0x7fb19c7aeeb0"
obj_addr(y)
#> [1] "0x7fb19c7aeeb0"
```

[`obj_size()`](https://lobstr.r-lib.org/reference/obj_size.html) computes the size of an object or set of objects. It is different to `object.size()` in three ways. It:

* Accounts for all types of shared values, not just strings in the global string pool,  
* Includes the size of environments (up to `env`), and  
* Accurately measures the size of ALTREP objects.

`obj_size()` attempts to take into account the size of the environments associated with an object. By default, it never counts the size of the global environment, the base environment, the empty environment, or any namespace. However, the optional `env` argument allows you to specify another environment at which to stop.


```r
x <- runif(1e4)
obj_size(x)
#> 80,048 B

z <- list(a = x, b = x, c = x)
obj_size(z)
#> 80,488 B
```

You can use `obj_sizes()` to see the unique contribution of each component:


```r
obj_sizes(x, z)
#> * 80,048 B
#> *    440 B
```

For more detail, see the [Object size](https://adv-r.hadley.nz/names-values.html#object-size) section of Advanced R.

## Memory usage

[`mem_used()`](https://lobstr.r-lib.org/reference/mem_used.html) wraps around the base-R garbage collection function, [`gc()`](https://stat.ethz.ch/R-manual/R-devel/library/base/html/gc.html), and returns the exact number of bytes currently used by R. See [Unbinding and the garbage collector](https://adv-r.hadley.nz/names-values.html#gc) for details.

