## code to prepare `DATASET` dataset goes here
library(here)
here::i_am("data-raw/silva.R")
source(here("data-raw", "deps.R"))
#TODO: The names are weird and not in order 
#TODO: Match with the actual SILVA names (see README.md from SILVA page for more information)
version <- c("138", "1")
subunit <- "ssu"
get_silva <- function(version, subunit="ssu"){
    message("We're utilizing the nr99 SILVA database")
    subunit <- match.arg(subunit, c("lsu", "ssu"))
    if (length(version) == 2){
        message("Using major-minor version code of version ", version[1], ".", version[2])
        ncbi_url <- glue("https://www.arb-silva.de/fileadmin/silva_databases/release_{maver}_{miver}/Exports/taxonomy/ncbi/taxmap_embl-ebi_ena_{subunit}_ref_nr99_{maver}.{miver}.txt.gz", 
                    maver = version[1], miver = version[2], subunit = subunit)
        silva_url <- glue("https://www.arb-silva.de/fileadmin/silva_databases/release_{maver}_{miver}/Exports/taxonomy/tax_slv_{subunit}_{maver}.{miver}.txt.gz", 
                          maver = version[1], miver = version[2], subunit = subunit)
        silva_map_url <- glue("https://www.arb-silva.de/fileadmin/silva_databases/release_{maver}_{miver}/Exports/taxonomy/taxmap_slv_{subunit}_ref_nr_{maver}.{miver}.txt.gz", 
                              maver = version[1], miver = version[2], subunit = subunit)
    } else {
        ncbi_url <- glue("https://www.arb-silva.de/fileadmin/silva_databases/release_{version}/Exports/taxonomy/ncbi/taxmap_embl-ebi_ena_{subunit}_ref_nr99_{version}.txt.gz", 
                    version = version, subunit = subunit)
        silva_url <- glue("https://www.arb-silva.de/fileadmin/silva_databases/release_{version}/Exports/taxonomy/taxmap_slv_{subunit}_{version}.txt.gz", 
                          version = version, subunit = subunit)
        silva_map_url <- glue("https://www.arb-silva.de/fileadmin/silva_databases/release_{maver}_{miver}/Exports/taxonomy/taxmap_slv_{subunit}_ref_nr_{version}.txt.gz", 
                              version = version, subunit = subunit)
    }
    
    sm_file <- tempfile()
    n_file <- tempfile()
    s_file <- tempfile()
    download.file(url = silva_url, destfile = s_file)
    download.file(url = ncbi_url, destfile = n_file)
    download.file(url = silva_map_url, destfile = sm_file)
    
    # ncbi id to accession crosswalk 
    ncbi_ref <- read.table(gzfile(n_file), fill = TRUE, sep = "\t", header = TRUE)
    ncbi_ref <- ncbi_ref %>% select(-c(start, stop)) %>% 
        rename("ncbi_id" = "ncbi_taxonid")
    # taxonomic path to silva id crosswalk 
    silva <- read.table(gzfile(s_file), fill = TRUE, sep = "\t", header = FALSE)
    colnames(silva) <- c("path", "silva_id", "rank", "notes", "version")
    # silva id to accession crosswalk 
    silva_map <- read.table(gzfile(sm_file), fill = TRUE, sep = "\t", header = TRUE)
    silva_map <- silva_map %>% rename("silva_id" = "taxid" )
    # map acccession to silva id
    silva_combine <- inner_join(silva_map, silva) %>% select(-c(start, stop, notes, version))
    # map ncbi id to silva id
    silva <- left_join(silva_combine, ncbi_ref)
    silva <- silva %>% distinct(ncbi_id, silva_id, submitted_name, submitted_path, organism_name, path, rank) %>% 
        rename("silva_path" = "path", "silva_name" = "organism_name") %>% 
        select(silva_id, ncbi_id, silva_name, silva_path, submitted_name, submitted_path, rank)
    gc()
    return(silva)
}

silva <- get_silva(version = version)


usethis::use_data(silva, overwrite = TRUE, internal = TRUE, version = 3)
