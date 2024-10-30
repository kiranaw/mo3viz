library(jsonlite)
library(data.table)

options(timeout = 900)

file_urls <- c(
  #"https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.0.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.1.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.2.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.3.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.4.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.5.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.6.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.7.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.8.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-0.9.json.gz",
  "https://nextcloud.openmole.org/s/Ks8EAN35ny7GCry/download?path=%2F&files=ratio-1.0.json.gz"
)

get_filename_from_url <- function(url) {
  file_name <- sub(".*files=([^&]+).*", "\\1", url)
  return(file_name)
}

download_files <- function(file_url) {
  file_name <- get_filename_from_url(file_url)
  
  download.file(file_url, destfile = file_name, mode = "wb")
  
  cat("Downloaded:", file_name, "\n")
}


lapply(file_urls, download_files)
