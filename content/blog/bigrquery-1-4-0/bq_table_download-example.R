library(bigrquery)

#+ include = FALSE
bq_auth("jenny@rstudio.com")

#+ include = TRUE
dat <- bq_table_download(
  "bigquery-public-data.chicago_taxi_trips.taxi_trips",
  n_max = 100000,
  bigint = "integer64"
)

tail(dat)
