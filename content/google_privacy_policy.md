---
title: Privacy policy for Google API wrappers
---

<!--
Heavily inspired by:
https://pandas-gbq.readthedocs.io/en/latest/privacy.html
https://pydata-google-auth.readthedocs.io/en/latest/privacy.html
-->

The tidyverse team maintains several packages that make it easier to work with Google APIs from R:

  * gargle: <https://gargle.r-lib.org>
    - Infrastructure package with general helpers for Google APIs, including auth
  * bigrquery: <https://bigrquery.r-dbi.org>
    - Works with the [BigQuery API](https://developers.google.com/bigquery/)
  * googledrive: <https://googledrive.tidyverse.org>
    - Allows user to manage their files on [Drive](https://developers.google.com/drive/)
  * gmailr: <https://cran.r-project.org/package=gmailr>
    - Allows user to work with [Gmail](https://developers.google.com/gmail/api/), including sending messages
  * googlesheets4: <https://googlesheets4.tidyverse.org> *not released yet*
    - Allows user to read and modify [Google Sheets](https://developers.google.com/sheets/api/)
  
All of these packages are governed by the common policies recorded here.

TODO: once this is merged and has a stable URL, link back to it from all those package websites. For gmailr, we might need to switch to the README above and put the link there.

Your use of Google APIs with these packages is subject to each API's respective
terms of service <https://developers.google.com/terms/>.
  
# Privacy

## Google account and user data

### Accessing user data

These packages access Google resources from your local machine. Your machine communicates directly with the Google APIs.

Each package includes functions that you can execute in order to read or modify your own data. This can only happen after you provide a token, which requires that you authenticate yourself as a specific Google user and authorize these actions. 

If you do not provide your own service account token, these packages can guide you through the OAuth flow in the browser, where you must consent to allowing the GARGLE_PROJECT to operate on your behalf. These packages can also guide you through the OAuth process using an OAuth client that you provide, in which case your associated Google Cloud Project will be listed instead of the GARGLE_PROJECT.

The OAuth consent screen will describe the scope of what is being authorized, e.g., it will name the target API(s) and whether you authorizing "read only" or "read and write" access. Depending on the package, you may have the ability to control which scopes are associated with a token. If you only want to read your data, you may wish to specify a "read only" scope.

At no time does the GARGLE_PROJECT receive your data or the permission to access your data. The GARGLE_PROJECT can only see information about aggregate usage of tokens associated with its OAuth client, such as which APIs and endpoints are being used. If you provide a service account token or obtain a token with your own OAuth client, your usage will not appear in the usage data that Google attributes to the GARGLE_PROJECT.

### Storing user data

By default, your token is stored to a local file, such as `~/.R/gargle/gargle-oauth`. See the documentation for [`gargle::gargle_options()`](https://gargle.r-lib.org/reference/gargle_options.html) and [`gargle::credentials_user_oauth2()`](https://gargle.r-lib.org/reference/credentials_user_oauth2.html) for information on how to control the location of the token cache or suppress token caching, globally or at the individual token level. All user data is stored on your local machine. **Use caution when using these packages on a shared machine**.

### Sharing user data

The packages only communicate with Google APIs. No user data is shared with the tidyverse maintainers, RStudio, or any other servers.

### Policies for package authors

Do not use an API key or client ID from the GARGLE_PROJECT in an external package or tool. Per the Google User Data Policy
<https://developers.google.com/terms/api-services-user-data-policy>, your
application must accurately represent itself when authenticating to Google API services.
