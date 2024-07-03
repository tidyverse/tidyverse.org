---
title: R version support
author: Mara Averick
date: '2019-04-01'
slug: r-version-support
output: hugodown::hugo_document
description: >
    Which versions of R do tidyverse packages support?
categories:
  - other
photo:
  url: https://unsplash.com/photos/GSCtoEEqntQ
  author: Ralph Howald
rmd_hash: efe6168c59ef5121

---

Our general policy is to support the **current version**, the **devel version**, and **four previous versions** of R. This policy applies to all packages that we support, i.e. as well as all tidyverse packages, it also applies to the infrastructure packages that we maintain in [r-lib](https://github.com/r-lib).

Thus the *official* minimum supported versions of R for the tidyverse are as follows:

| Released R version | Date       | Minimum supported version |
|:-------------------|-----------:|:--------------------------|
| 3.6                | 2019-04-26 | 3.2                       |
| 4.0                | 2020-04-24 | 3.3                       |
| 4.1                | 2021-05-18 | 3.4                       |
| 4.2                | 2022-04-22 | 3.5                       |
| 4.3                | 2023-04-21 | 3.6                       |
| 4.4                | 2024-04-24 | 4.0                       |
| 4.5                | 2025       | 4.1                       |
| 4.6                | 2026       | 4.2                       |

Note that, as described in the R Developer ["Release plans"](https://developer.r-project.org/), R version releases occur annually in Spring. We generally update the required version in package metadata on the next package release after the R release, so you may see older versions listed in published CRAN packages.

### Edit history

* 2022-11-15: Added table with annual historic and projected R-version support.
* 2024-07-03: Clarified that the policy also applies to r-lib and added release dates.
