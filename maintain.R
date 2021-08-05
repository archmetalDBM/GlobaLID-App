library(magrittr)

database <- readr::read_delim("G:/Projekte/ProLead/ProLead_DB.csv", delim = ",", guess_max = 22000, col_types = readr::cols()) %>%
  dplyr::filter(Status == "Ready") %>%
  dplyr::mutate(dplyr::across(c("Country":"Mining site"), stringr::str_remove, "\\s\\[.*\\]")) %>%
  dplyr::mutate(dplyr::across(.cols = c(where(is.character) & !c("doi", "Location precision", `Add. information on mine`)), tidyr::replace_na, "unknown")) %>%
  tidyr::unite(tooltip, `Sample number`, Country, `Political province/region`, `Mining area`, `Mining site`, sep = "<br>", remove = FALSE, na.rm = TRUE) %>%
  dplyr::mutate(tooltip = paste0("Sample ID: ", tooltip))

saveRDS(database, "data/database_complete.rds")

database_clean <- database %>%
  dplyr::filter(year >= 1974) %>%
  dplyr::filter(`Instrument used` %in% c("MC-ICP-MS", "TIMS", "TIMS?", NA))

saveRDS(database_clean, "data/database_clean.rds")

# update providers of maps
library(V8)
library(jsonlite)
library(leaflet.providers)
providers <- leaflet.providers::get_providers()


# update static documents
library(rmarkdown)

render("doc/resources.rmd")
render("doc/references.rmd")
render("doc/about.rmd")
render("doc/instructions.rmd")

# deploy
library(rsconnect)

deployApp(
  appFileManifest = "files_to_deploy.txt", 
  appName = "ProLeadTest"
)

