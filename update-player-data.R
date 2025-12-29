library(httr)
library(jsonlite)
library(dplyr)
library(tidyr)
library(readr)

# Teams
# url <- "https://stats-api.mlssoccer.com/statistics/clubs/competitions/MLS-COM-000001/seasons/MLS-SEA-0001K9?per_page=50"
get_mls_data <- function() {
  # Players
  url <- "https://stats-api.mlssoccer.com/statistics/players/competitions/MLS-COM-000001/seasons/MLS-SEA-0001K9?per_page=50"
  
  res <- httr::GET(url)
  stop_for_status(res)
  
  data <- jsonlite::fromJSON(content(res, "text"))

  season_info <- as_tibble(data$stats_info)
  player_stats   <- as_tibble(data$player_statistics)

  list(season_info = season_info, player_stats = player_stats)
}

expand_lists <- function(df) {
  repeat {
    list_cols <- names(df)[sapply(df, function(x) is.list(x) || is.matrix(x))]
    if (length(list_cols) == 0) break
    
    for (col in list_cols) {
      df <- df %>% unnest_wider(all_of(col), names_sep = paste0("_", col))
    }
  }
  return(df)
}

# Fetch both tables
mls <- get_mls_data()

# Expand nested columns
season_info_expanded <- expand_lists(mls$season_info)
player_stats_expanded  <- expand_lists(mls$player_stats)

# Extract season year for filenames
season_year <- season_info_expanded$season

# Write CSVs with year in the filename
write_csv(season_info_expanded, paste0("mls_season_", season_year, "_info.csv"))
write_csv(player_stats_expanded, paste0("mls_", season_year, "_player_stats.csv"))
