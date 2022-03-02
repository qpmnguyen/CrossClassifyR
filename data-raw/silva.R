## code to prepare `DATASET` dataset goes here
library(here)
here::i_am("data-raw/silva.R")
source(here("data-raw", "deps.R"))

version <- c("138", "1")


url <- glue("https://www.arb-silva.de/fileadmin/silva_databases/release_{maver}_{miver}/Exports/taxonomy/taxmap_slv_ssu_ref_nr_{maver}.{miver}.txt.gz", 
            maver = version[1], miver = version[2])

d_file <- tempfile()

download.file(url = url, destfile = d_file)
silva <- read.table(gzfile(d_file), fill = TRUE, sep = "\t", header = TRUE)
silva <- silva %>% distinct(path, taxid) %>% as_tibble() %>% 
    filter(str_detect(path, "Bacteria")) %>%
    mutate(ids = strsplit(path, ";", fixed = TRUE), .before = 1) %>% 
    mutate(ids = map(ids, function(x) {
        if (length(x) < 6){
            x <- c(x, rep(NA_character_, 6 - length(x)))
        }
        tax <- as.list(x)
        names(tax) <- c("kingdom", "phylum", "class", "order", "family", "genus")
        as_tibble(tax)
    })) %>% unnest(ids) %>% 
    select(taxid, kingdom, phylum, class, order, family, genus, path) %>% 
    rename("full_path" = "path") %>% 
    rename("ncbiid" = "taxid")

usethis::use_data(silva, overwrite = TRUE, internal = TRUE, version = 3)
