## code to prepare `DATASET` dataset goes here
library(here)
here::i_am("data-raw/silva.R")
source(here("data-raw", "deps.R"))
#TODO: The names are weird and not in order 
#TODO: Match with the actual SILVA names (see README.md from SILVA page for more information)
version <- c("138", "1")

get_silva <- function(version, subunit="ssu"){
    message("We're utilizing the nr99 SILVA database")
    subunit <- match.arg(subunit, c("lsu", "ssu"))
    if (length(version) == 2){
        message("Using major-minor version code of version ", version[1], ".", version[2])
        url <- glue("https://www.arb-silva.de/fileadmin/silva_databases/release_{maver}_{miver}/Exports/taxonomy/ncbi/taxmap_embl-ebi_ena_{subunit}_ref_nr99_{maver}.{miver}.txt.gz", 
                    maver = version[1], miver = version[2], subunit = subunit)
    } else {
        url <- glue("https://www.arb-silva.de/fileadmin/silva_databases/release_{version}/Exports/taxonomy/ncbi/taxmap_embl-ebi_ena_{subunit}_ref_nr99_{version}.txt.gz", 
                    version = version, subunit = subunit)
    }
    d_file <- tempfile()
    download.file(url = url, destfile = d_file)
    silva <- read.table(gzfile(d_file), fill = TRUE, sep = "\t", header = TRUE)
    silva <- silva %>% distinct(submitted_path, submitted_name, ncbi_taxonid) %>% as_tibble()
    gc()
    
    check_names <- map_lgl(silva$submitted_name, ~{
        sp <- str_split(.x, pattern = "\t")[[1]]
        if (length(sp) > 1){
            return(TRUE)
        } else {
            return(FALSE)
        }
    })
    
    silva <- silva[-check_names,] %>% mutate(ids = strsplit(submitted_path, ";", fixed = TRUE)) %>% 
        mutate(ids = map(ids, function(x) {
            if (length(x) < 6){
                x <- c(x, rep(NA_character_, 6 - length(x)))
            } else if (length(x) > 6){
                x <- x[1:6]
            }
            tax <- as.list(x)
            names(tax) <- c("kingdom", "phylum", "class", "order", "family", "genus")
            as_tibble(tax)
        })) %>% unnest(ids) %>% rename("species" = "submitted_name") %>% 
        select(kingdom, phylum, class, order, family, genus, species, ncbi_taxonid)
}

silva <- get_silva(version = "138")


usethis::use_data(silva, overwrite = TRUE, internal = TRUE, version = 3)
