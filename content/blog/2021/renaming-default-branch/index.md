---
output: hugodown::hugo_document

slug: renaming-default-branch
title: Renaming the default branch
date: 2021-10-27
author: Jenny Bryan
description: >
    We are renaming the default branch of many Git(Hub) repositories and this
    post explains how contributors can adapt, using new functionality in
    usethis.

photo:
  url: https://unsplash.com/photos/jA264x_MkCI
  author: Natalie Chaney

# one of: "deep-dive", "learn", "package", "programming", or "other"
categories: [learn, package] 
tags: [usethis, devtools]
rmd_hash: 90501ab6a3ad81ef

---

Technically, Git has no official concept of the default branch. But in practice, most Git repos have an *effective default branch*. If there's only one branch, this is it! It is the branch that most bug fixes and features get merged in to. It is the branch you see when you first visit a repo on a site such as GitHub. On a Git remote, it is the branch that `HEAD` points to. The default branch may not be precisely defined in Git itself, but most of us know it when we see it.

Historically, `master` has been the most common name for the default branch, but `main` is an increasingly popular choice. There is coordinated change across the Git ecosystem that is making it easier for users to make this switch, for example:

-   [Regarding Git and Branch Naming](https://sfconservancy.org/news/2020/jun/23/gitbranchname/), statement from the Git project and the Software Freedom Conservancy regarding the new `init.defaultBranch` configuration option
-   [Renaming the default branch from`master`](https://github.com/github/renaming#readme), GitHub's roadmap for supporting the shift away from `master`
-   [The new Git default branch name](https://about.gitlab.com/blog/2021/03/10/new-git-default-branch-name/), same, but for GitLab

Folks at RStudio maintain hundreds of public repositories on GitHub, spread out over various organizations and user accounts. Some individual repos had already moved away from `master` in the past year, but many of us had not made the change, just due to inertia. We've decided it tackle this switch proactively and in bulk, for any interested individual or team, hopefully reducing the pain for everyone.

The purpose of this blog post is to:

-   Give our community a heads-up about this change.
-   Explain how this affects people who have cloned or forked our repositories.
-   Explain how you can make the `master` to `main` switch in your own Git life.
-   Advertise new functions in usethis >= 2.1.2 that help with the above.

## TL;DR

These are the key bits of code shown below.

**NOTE: you will need to update to usethis 2.1.2 or higher to get this functionality!**

| Function                                   | Purpose                                                                                                                                                       |
|--------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| [`usethis::git_default_branch()`](https://usethis.r-lib.org/reference/git-default-branch.html)            | Reveals the default branch of the current project.                                                                                                            |
| [`usethis::git_default_branch_rediscover()`](https://usethis.r-lib.org/reference/git-default-branch.html) | Detects when a project's default branch has changed on GitHub and makes the necessary updates to your Git environment. Primarily for use by **contributors**. |
| [`usethis::git_default_branch_rename()`](https://usethis.r-lib.org/reference/git-default-branch.html)     | Changes the default branch on GitHub and makes any necessary local updates. Aimed at **maintainers** who have admin permissions.                              |
| [`usethis::git_default_branch_configure()`](https://usethis.r-lib.org/reference/git-default-branch.html)  | Changes the default name of the initial branch in new Git repos, going forward.                                                                               |

Read on for more context.

## Which repositories are affected?

The transition from `master` to `main` is happening organization-wide for specific GitHub organizations (e.g. [tidyverse](https://github.com/tidyverse), [r-lib](https://github.com/r-lib), [tidymodels](https://github.com/tidymodels), and [sol-eng](https://github.com/sol-eng)). However, several teams maintain repos across multiple organizations and several organizations host repos for multiple teams and purposes. The organization-wide approach doesn't work well for these cases. Therefore, many additional "one-off" repos are also part of this effort.

In total, we're coordinating the `master` to `main` switch for around 350 repositories.

In each case, we opened a GitHub issue announcing the coming change, several weeks in advance. These issues all look something like this: <https://github.com/tidyverse/dplyr/issues/6006>.

## When are things changing?

"Around now."

Ideally, we would publish this post at the very same moment we rename our branches. But that's not possible for a variety of reasons, chiefly because no single person has the necessary permissions for all of the affected repos.

Is there a repo you care about, that has an open issue about branch renaming, and yet the change doesn't seem to be happening? Feel free to give us a gentle nudge by commenting in the issue thread.

## usethis has functions to help

The recent release of usethis has some new functions to support changes in the default branch. Specifically, you want version 2.1.2 or higher. To be clear, you don't *need* usethis to adapt to change in the default branch. On a small scale, the work can be done through some combination of command line Git and actions in a web browser, if that's how you roll.

But the new `git_default_branch*()` family of functions can make this process more pleasant, for those who enjoy using devtools/usethis, especially for Git and GitHub tasks. These functions also help us do this work programmatically for hundreds of repositories at once.

You can install the newest version of usethis from CRAN with:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://rdrr.io/r/utils/install.packages.html'>install.packages</a></span><span class='o'>(</span><span class='s'>"usethis"</span><span class='o'>)</span></code></pre>

</div>

You can make usethis available in your R session with either of these commands:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://usethis.r-lib.org'>usethis</a></span><span class='o'>)</span>

<span class='c'># or possibly even better:</span>
<span class='kr'><a href='https://rdrr.io/r/base/library.html'>library</a></span><span class='o'>(</span><span class='nv'><a href='https://devtools.r-lib.org/'>devtools</a></span><span class='o'>)</span>
<span class='c'># devtools Depends on usethis, so attaching devtools also attaches usethis</span></code></pre>

</div>

If you'd like usethis to help with you with Git/GitHub, please read the article [Managing Git(Hub) Credentials](https://usethis.r-lib.org/articles/articles/git-credentials.html).

usethis is very opinionated and conservative about which GitHub setups it's willing to manage, because we don't want to barge in and mess with something we don't understand. These standard setups and what we mean by, e.g., **source repo** are all described at <https://happygitwithr.com/common-remote-setups.html>.

<div class="highlight">

<div class="figure" style="text-align: center">

<img src="six-configs.png" alt="Six common GitHub setups" width="100%" />
<p class="caption">
Six common GitHub setups
</p>

</div>

</div>

## How to update your clones and forks

As mentioned above, our bulk renaming involves around 350 GitHub repos, which are associated with approximately 90K watchers, 34K forks, 9.5K open issues, and 1K open pull requests. It's impossible to say how many non-fork clones are out there. One thing that's clear: our branch renaming potentially affects lots of people.

### How will I know I have a problem?

Here's what it looks like when you try to pull from a remote repo in a project that used to use `master`, but now uses `main`, but you haven't updated your local repo yet.

-   Example with [`usethis::pr_merge_main()`](https://usethis.r-lib.org/reference/pull-requests.html) **with usethis >= 2.1.2**:

        pr_merge_main()
        #> Error: Default branch mismatch between local repo and remote.
        #> The default branch of the "origin" remote is "main".
        #> But the default branch of the local repo appears to be "master".
        #> Call `git_default_branch_rediscover()` to resolve this.

-   Example with command line `git pull` (which is what RStudio's blue "down" arrow does):

        Your configuration specifies to merge with the ref 'refs/heads/master'
        from the remote, but no such ref was fetched.

Both messages are telling you the same thing:

> We're trying to pull changes from the remote `master` branch, but the remote does not have a `master` branch.

You need to tell your local repo about the switch from `master` to `main`.

In usethis v2.0.1 and earlier, we were not proactively on the lookout for a change to the default branch name in the source repository. Implicitly, we assumed that the user was responsible for staying current with such changes. The recent usethis release (>= 2.1.2) tries much harder to alert the user if the default branch name changes and to provide an easy way to sync up.

### 🔥 Can I just burn it all down? 🔥

Yes, yes you can!

If there's nothing precious in your local clone of our repo or in your fork, it's perfectly reasonable to delete them and just start over. Locally, you delete the folder corresponding to the repo. On GitHub, in your fork, go to *Settings* and scroll down to the *Danger Zone* to *Delete this repository*.

Then you can do a fresh fork-and-clone of, for example, dplyr:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://usethis.r-lib.org/reference/create_from_github.html'>create_from_github</a></span><span class='o'>(</span><span class='s'>"tidyverse/dplyr"</span><span class='o'>)</span></code></pre>

</div>

### How do I update my stuff to reflect the new default branch?

If you don't want to burn it all down, you can call [`usethis::git_default_branch_rediscover()`](https://usethis.r-lib.org/reference/git-default-branch.html) to *rediscover* the default branch from the **source repo**.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://usethis.r-lib.org/reference/git-default-branch.html'>git_default_branch_rediscover</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; ℹ Default branch of the source repo 'jennybc/happy-git-with-r': 'main'</span>
<span class='c'>#&gt; ✓ Default branch of local repo has moved: 'master' --&gt; 'main'</span></code></pre>

</div>

Above, you see usethis updating the local repository to match the source repo. If we detect that you also have a fork of this repo, usethis will rename its default branch as well.

GitHub provides official instructions for [updating a local clone after a branch name changes](https://docs.github.com/en/github/administering-a-repository/managing-branches-in-your-repository/renaming-a-branch#updating-a-local-clone-after-a-branch-name-changes), using only command line Git:

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'>git branch -m OLD-BRANCH-NAME NEW-BRANCH-NAME
git fetch origin
git branch -u origin/NEW-BRANCH-NAME NEW-BRANCH-NAME
git remote set-head origin -a</code></pre>

</div>

Depending on your setup, above you might need to substitute `upstream` for `origin`. `OLD-BRANCH-NAME` is probably `master` and `NEW-BRANCH-NAME` is probably `main`.

## How to rename default branch in your own existing repos

You can rename the default branch for repos that you effectively own. This is a straightforward task for a repo that only exists on your computer. [^1] We're more concerned about the trickier case where the project is also on GitHub.

You can call [`usethis::git_default_branch_rename()`](https://usethis.r-lib.org/reference/git-default-branch.html) to *rename* (or move) the default branch in the **source repo**. For this to work, you must either own the source repo personally or, if it's organization-owned, you must have `admin` permission. This is a higher level of permission than `write`, which is what's needed to push. [`git_default_branch_rename()`](https://usethis.r-lib.org/reference/git-default-branch.html) checks this pre-requisite and exits early, without doing anything, if you are not going to be successful.

<div class="highlight">

<pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://usethis.r-lib.org/reference/git-default-branch.html'>git_default_branch_rename</a></span><span class='o'>(</span><span class='o'>)</span>
<span class='c'>#&gt; ✓ Default branch of the source repo 'jennybc/myrepo' has moved: 'master' --&gt; 'main'</span>
<span class='c'>#&gt; • Be sure to update files that refer to the default branch by name.</span>
<span class='c'>#&gt;   Consider searching within your project for 'master'.</span>
<span class='c'>#&gt; x Some badges may refer to the old default branch 'master':</span>
<span class='c'>#&gt;   - 'README.md'</span>
<span class='c'>#&gt; ✓ Default branch of local repo has moved: 'master' --&gt; 'main'</span></code></pre>

</div>

Once the default branch is successfully renamed in the source repo on GitHub, [`git_default_branch_rename()`](https://usethis.r-lib.org/reference/git-default-branch.html) makes an internal call to [`git_default_branch_rediscover()`](https://usethis.r-lib.org/reference/git-default-branch.html) to finish the job. This makes any necessary local changes or, more rarely, changes in a personal fork.

Note also that we check for specific files that often include the name of the default branch, such as GitHub Actions workflows and the badges section of README. These references should be updated. It's probably a good idea to do a project-wide search for both the old and the new name and take a hard look at the "hits".

If you don't want to use usethis, you can rename the default branch from a web browser. On GitHub, in your repo, go to *Settings*, then *Branches*, and edit the *Default branch*. Then follow the command line instructions from the previous section, emulating what we do in [`git_default_branch_rename()`](https://usethis.r-lib.org/reference/git-default-branch.html).

## How to change the default name of your default branch, for the future

The way most repos end up with `master` as their default branch is that Git itself defaults to `master` when it creates the very first branch, with the very first commit, in a new repo. As of Git 2.28 (released 2020-07-27), this became configurable, so it's one of those things you can customize in your global, i.e. user-level, Git config file. usethis does all of its Git work via the [gert package](https://docs.ropensci.org/gert/) and the underlying library libgit2 library gained similar support in version 1.1 (released 2020-10-12).

The new configuration option is `init.defaultBranch`.

There are various ways to set your preferred initial branch name to, e.g., `main`:

-   With usethis >= 2.1.2, using a special-purpose function:
    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://usethis.r-lib.org/reference/git-default-branch.html'>git_default_branch_configure</a></span><span class='o'>(</span><span class='o'>)</span>
      <span class='c'>#&gt; ✓ Configuring init.defaultBranch as 'main'.</span>
      <span class='c'>#&gt; ℹ Remember: this only affects repos you create in the future.</span></code></pre>

    </div>
-   With usethis, using the general function to modify your Git configuration:
    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'><span class='nf'><a href='https://usethis.r-lib.org/reference/use_git_config.html'>use_git_config</a></span><span class='o'>(</span>init.defaultBranch <span class='o'>=</span> <span class='s'>"main"</span><span class='o'>)</span></code></pre>

    </div>
-   With command line Git:
    <div class="highlight">

    <pre class='chroma'><code class='language-r' data-lang='r'>git config --global init.defaultBranch main</code></pre>

    </div>

Although it is more rare to first create repos on a host like GitHub or GitLab, this certainly comes up from time to time. All the major providers now support configuration of the initial branch name and, in the absence of a user or organization preference, all default to `main`.

## Acknowledgements

Thanks to Jeroen Ooms ([@jeroen](https://github.com/jeroen)), maintainer of gert, for adding [`gert::git_branch_move()`](https://docs.ropensci.org/gert/reference/git_branch.html). And thanks to everyone at RStudio helping with this effort, especially the champions from other teams: Barret Schloerke ([@schloerke](https://github.com/schloerke), Shiny), Ian Flores Siaca ([@ian-flores](https://github.com/ian-flores), Solutions Engineering), Julia Silge ([@juliasilge](https://github.com/juliasilge), tidymodels), Mine Çetinkaya-Rundel ([@mine-cetinkaya-rundel](https://github.com/mine-cetinkaya-rundel), Education), Sigrid Keydana ([@skeydan](https://github.com/skeydan), Machine Learning), Alison Presmanes Hill ([@apreshill](https://github.com/apreshill), Data Science Communication).

[^1]: [`usethis::git_default_branch_rename()`](https://usethis.r-lib.org/reference/git-default-branch.html) **does** handle the special case of `"no_github"`. Internally, it calls [`gert::git_branch_move()`](https://docs.ropensci.org/gert/reference/git_branch.html). With command line Git, use `git branch -m OLD-BRANCH-NAME NEW-BRANCH-NAME`.

