---
title: Lifecycle badges
---

![](/images/lifecycle/lifecycle.png)

### Experimental ![](https://img.shields.io/badge/lifecycle-experimental-orange.svg) {#experimental}

An experimental package is in the very early stages of development. The API (application programming interface) will be changing frequently as we rapidly iterate and explore variations in search of the best fit. Experimental packages will make API breaking changes without deprecation, so you are generally best off waiting until the package is more mature before you use it. Experimental packages will not be released on CRAN

### Maturing ![](https://img.shields.io/badge/lifecycle-maturing-blue.svg) {#maturing}

The API of a maturing package has been roughed out, but finer details likely to change. Once released to CRAN, we will strive to maintain backward compatibility, but the package needs wider usage in order to get more feedback and find the optimal API.

### Stable ![](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg) {#stable}

In a stable package, we are largely happy with the API, and major changes are unlikely. This means that the API will generally evolve by adding new functions and new arguments; we will avoid removing arguments or changing the meaning of existing arguments.

If API breaking change are needed, they will occur gradually. To begin with, the function or argument will be deprecated; it will continue to work but will emit an message informing you of the change. Next, typically after at least a year, the message will be transformed to an error.

### Retired ![](https://img.shields.io/badge/lifecycle-retired-orange.svg) {#retired}

A retired package is no longer under active development, and a known better alternative is available. We will only make the necessary changes to ensure that retired packages remain on CRAN. No new features will be added, and only the most critical of bugs will be fixed.

### Archived ![](https://img.shields.io/badge/lifecycle-archived-red.svg) {#archived}

The development of an archived package is complete, and it has been archived on CRAN and on GitHub.

### Dormant ![](https://img.shields.io/badge/lifecycle-dormant-blue.svg) {#dormant}

A dormant package is not completed, but is not currently under active development. We plan to return to it in the future.

### Questioning ![](https://img.shields.io/badge/lifecycle-questioning-blue.svg) {#questioning}

We are no longer convinced that a questioning package is the optimal approach, but we don't yet know what a better approach is.
