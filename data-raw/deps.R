library(tidyverse)
library(here)
library(glue)
library(jsonlite)
library(data.table)

#' @title Processing metaphlan3 marker information using json
#' @param string The string to the processed as a json file
#' @return A data frame containing the individual taxonomic levels as specified
process_json <- function(string) {
    string <- gsub(string, pattern = "'", replacement = "\"")
    string_l <- jsonlite::fromJSON(txt = string)
    taxon <- string_l$taxon
    split <- str_split(taxon, pattern = "\\|")[[1]]
    df_taxon <- data.frame(t(rep(NA, 9)))
    colnames(df_taxon) <- c("kingdom", "phylum", "class", "order", "family", "genus", 
                            "species", "strain", "full_path")
    p_split <- gsub(split, pattern = "[a-z]__", replacement = "")
    if (length(p_split) != ncol(df_taxon)) {
        p_split <- c(p_split, rep(NA, (ncol(df_taxon) - 1) - length(p_split)))
    }
    print(p_split)
    print(taxon)
    df_taxon[1, ] <- p_split
    return(df_taxon)
}