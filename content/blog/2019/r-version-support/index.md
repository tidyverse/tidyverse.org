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

## Which versions of R do tidyverse packages support?

Though package-specific minimum versions of R are given in the `Depends` fields of individual `DESCRIPTION` files, our general policy is to support the **current version**, the **devel version**, and **four previous versions** of R.

This policy applies to all packages that we support, i.e. as well as all packages in the tidyverse, it also applies the infrastructure packages that we maintain in [r-lib](https://github.com/r-lib).

Over the past several years and moving forward (as described in the "Release plans" section of the [R Developer Page](https://developer.r-project.org/)), R version releases occur annually:

> The overall release schedule is to have annual x.y.0 releases in Spring, with patch releases happening on an as-needed basis.

Thus, the *official* minimum supported versions of R for the tidyverse[^2] are as described in the table, below.

<div class="highlight">

| Year | Current R version | Minimum supported version |
|-----:|:------------------|:--------------------------|
| 2019 | 3.6               | 3.2                       |
| 2020 | 4.0               | 3.3                       |
| 2021 | 4.1               | 3.4                       |
| 2022 | 4.2               | 3.5                       |
| 2023 | 4.3               | 3.6                       |
| 2024 | 4.4               | 4.0                       |
| 2025 | 4.5               | 4.1                       |
| 2026 | 4.6               | 4.2                       |

Tidyverse minimum R version support

</div>

[^1]: Note that we only update the required version on package release, so you may see older versions listed in published CRAN packages.

### Edit history

* 2022-11-15: Added table with annual historic and projected R-version support.
* 2024-07-03: Clarified that the policy also applies to r-lib.
