library(httr)
library(jsonlite)
library(dplyr)
library(readr)

base_url <- "https://sportapi.mlssoccer.com/api/stats/players/competition/MLS-COM-000001/season/MLS-SEA-0001K9/order/goals/desc?pageSize=30&page="

all_pages <- 1:34

# Initialize empty tibble to store all pages
all_data <- tibble()

for (page in all_pages) {
  url <- paste0(base_url, page)
  message("Fetching page ", page, "...")
  
  res <- httr::GET(url)
  stop_for_status(res)
  
  # Convert JSON to R object (already flattened) therefore no need to expand list
  data <- jsonlite::fromJSON(content(res, "text"), flatten = TRUE)
  
  # Convert to tibble (if not already)
  data_tibble <- as_tibble(data)
  
  # Stack it
  all_data <- bind_rows(all_data, data_tibble)
}

# Save CSV
write_csv(all_data, "mls_2025_player_stats.csv")
