---
title: Privacy policy for packages that access Google APIs
---

<!--
Heavily inspired by:
https://pandas-gbq.readthedocs.io/en/latest/privacy.html
https://pydata-google-auth.readthedocs.io/en/latest/privacy.html
-->

The tidyverse team maintains several packages that make it easier to work with Google APIs from R:

  * [gargle](https://gargle.r-lib.org) provides general R infrastructure for Google APIs, such as auth
  * [bigrquery](https://bigrquery.r-dbi.org) wraps the [BigQuery API](https://developers.google.com/bigquery/)
  * [googledrive](https://googledrive.tidyverse.org) wraps the [Drive API](https://developers.google.com/drive/)
  * [gmailr](https://cran.r-project.org/package=gmailr) wraps the [Gmail API](https://developers.google.com/gmail/api/)
  * [googlesheets4](https://googlesheets4.tidyverse.org) wraps the [Sheets API](https://developers.google.com/sheets/api/) *not released yet*
  
All of these packages are governed by the common policies recorded here.

Your use of Google APIs with these packages is subject to each API's respective
terms of service <https://developers.google.com/terms/>.
  
# Privacy

## Google account and user data

### Accessing user data

These packages access Google resources from your local machine. Your machine communicates directly with the Google APIs.

At no time does the GARGLE_PROJECT receive your data or the permission to access your data. The owners of the GARGLE_PROJECT can only see anonymous, aggregated information about usage of tokens obtained through its OAuth client, such as which APIs and endpoints are being used.

Each package includes functions that you can execute in order to read or modify your own data. This can only happen after you provide a token, which requires that you authenticate yourself as a specific Google user and authorize these actions. 

These packages can help you get a token by guiding you through the OAuth flow in the browser. There you must consent to allow the GARGLE_PROJECT to operate on your behalf. The OAuth consent screen will describe the scope of what is being authorized, e.g., it will name the target API(s) and whether you are authorizing "read only" or "read and write" access.

There are two ways to use these packages without authorizing the GARGLE_PROJECT: bring your own [service account token](https://developers.google.com/identity/protocols/OAuth2ServiceAccount) or configure the package to use an OAuth client of your choice.

### Scopes

Overview of the scopes requested by various packages in the GARGLE_PROJECT and their rationale:

  * `userinfo.email` (read only): All OAuth tokens obtained with the GARGLE_PROJECT request this scope so that cached tokens can be labelled with the associated Google user, allowing you to more easily access Google APIs with more than one identity. The GARGLE_PROJECT does NOT have access to and does NOT store your Google password.
  * BigQuery and Google Cloud Platform (read/write): The bigrquery package lets you upload, query, and modify data stored in Google Bigquery, as well as retrieve metadata about projects, datasets, tables, and jobs.
  * Drive (read/write): The googledrive package allows you to manage your Drive files and therefore the default scopes include read/write access. The googledrive package makes it possible for you to get a token with more limited scope, e.g. read only.
  * Gmail (read/write): The gmailr package is primarily used to send mail and thus must have the abilty to compose and send mail.
  * Sheets (read/write): The googledrive package allows you to manage your Sheets files and therefore the default scopes include read/write access. The googlesheets4 package makes it possible for you to get a token with more limited scope, e.g. read only.

### Sharing user data

The packages only communicate with Google APIs. No user data is shared with the tidyverse maintainers, RStudio, or any other servers.

### Storing user data

These packages may store your credentials on your local machine, for later reuse by you. **Use caution when using these packages on a shared machine**.

By default, an OAuth token is cached in a local file, such as `~/.R/gargle/gargle-oauth`. See the documentation for [`gargle::gargle_options()`](https://gargle.r-lib.org/reference/gargle_options.html) and [`gargle::credentials_user_oauth2()`](https://gargle.r-lib.org/reference/credentials_user_oauth2.html) for information on how to control the location of the token cache or suppress token caching, globally or at the individual token level. 

# Policies for authors of packages or other applications

Do not use an API key or client ID from the GARGLE_PROJECT in an external package or tool. Per the Google User Data Policy
<https://developers.google.com/terms/api-services-user-data-policy>, your
application must accurately represent itself when authenticating to Google API services.

If you use these packages inside another package or application that executes its own logic --- as opposed to code written by tidyverse maintainers or by the user --- you must communicate this clearly to the user. Do not use credentials from the GARGLE_PROJECT; instead, use credentials associated with your project or your user.
