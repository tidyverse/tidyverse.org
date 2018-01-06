---
title: Lifecycle badges
---

![](/images/lifecycle/lifecycle.png)
### Package lifecycles & APIs {#api}

This page describes the typical lifecycle on an R package. Knowing where a
package is in its lifecycle is particularly important for understanding how the API
will change over time. The API (short for application programming interface) is
the set of functions (and their arguments) that defines how you interact with
the package.

There are three ways an API can change:

 1. It can __grow__ when a function or argument is added. 

 2. It can __shrink__ when a function or argument is removed. 

 3. It can __change__ when the meaning of an argument changes, or the type of 
 data returned from a function changes.

Changing or shrinking the API will __break__ it: code that previously worked
will no any longer. (Sometimes code will break even if the API doesn't; for
example, you might have accidentally depended on behaviour that the author
thought was a bug).


### Experimental ![](/images/lifecycle/lifecycle-experimental.png) {#experimental}

An experimental package is in the very early stages of development. The API will be changing frequently as we rapidly iterate and explore variations in search of the best fit. Experimental packages will make API breaking changes without deprecation, so you are generally best off waiting until the package is more mature before you use it. Experimental packages will not be released on CRAN

### Maturing ![](/images/lifecycle/lifecycle-maturing.png) {#maturing}

The API of a maturing package has been roughed out, but finer details likely to change. Once released to CRAN, we will strive to maintain backward compatibility, but the package needs wider usage in order to get more feedback and find the optimal API.

### Stable ![](/images/lifecycle/lifecycle-stable.png) {#stable}

In a stable package, we are largely happy with the API, and major changes are unlikely. This means that the API will generally evolve by adding new functions and new arguments; we will avoid removing arguments or changing the meaning of existing arguments.

If API breaking change are needed, they will occur gradually. To begin with, the function or argument will be deprecated; it will continue to work but will emit an message informing you of the change. Next, typically after at least a year, the message will be transformed to an error.

### Retired ![](/images/lifecycle/lifecycle-retired.png) {#retired}

A retired package is no longer under active development, and a known better alternative is available. We will only make the necessary changes to ensure that retired packages remain on CRAN. No new features will be added, and only the most critical of bugs will be fixed.

### Archived ![](/images/lifecycle/lifecycle-archived.png) {#archived}

The development of an archived package is complete, and it has been archived on CRAN and on GitHub.

### Dormant ![](/images/lifecycle/lifecycle-dormant.png) {#dormant}

A dormant package is not completed, but is not currently under active development. We plan to return to it in the future.

### Questioning ![](/images/lifecycle/lifecycle-questioning.png) {#questioning}

We are no longer convinced that a questioning package is the optimal approach, but we don't yet know what a better approach is.
