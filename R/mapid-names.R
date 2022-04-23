#' @title Internal function to map identifiers to names 
#' @param df Taxonomy Table converted to data frame format. There should be a column titled 
#'     \code{df_id} which represents the identifiers used in the original data set 
#'     (e.g. \code{taxa_names} from a \code{phyloseq}) 
#' @param rebuild (Logical). Indicate whether to re-download the NCBI database used to query
#' @importFrom tidyr unite 
#' @importFrom dplyr mutate all_of select distinct left_join
#' @importFrom purrr pmap_chr
#' @importFrom rlang sym
#' @importFrom magrittr %>% 
#' @importFrom taxizedb db_path db_download_ncbi
.mapidnames <- function(df, rebuild = FALSE){
    # TODO: reminder that the first column will always be df_ids
    # TODO: Reminder to implement a check_rank function first to ensure that 
    # df is in the correct format.  
    df_id <- fullname <- NULL
    if (!file.exists(taxizedb::db_path("ncbi")) | rebuild == TRUE){
        message("Downloading NCBI database")
        taxizedb::db_download_ncbi(overwrite = TRUE)
    }
    ranks <- colnames(df %>% dplyr::select(-df_id))
    max_ranks <- ranks[length(ranks)]
    message("Using ", max_ranks, " to match")
    df <- df %>% tidyr::unite(col = "fullname", dplyr::all_of(ranks), remove=FALSE) %>% 
        dplyr::mutate(match = !!rlang::sym(max_ranks), rank = max_ranks) 
    
    df_distinct <- dplyr::distinct(df, fullname, match, rank)
    df_distinct <- df_distinct %>% dplyr::mutate(ncbi = purrr::pmap_chr(df_distinct, .matching))
    
    final_match <- dplyr::left_join(df, df_distinct, by = c("fullname", "match", "rank")) %>% 
        dplyr::select(-c(rank, match, fullname))
    return(final_match)
}

#' Perform proper matching using taxizedb and Jaccard distances
#' @keywords internal
#' @param fullname The full name separated by "_" for resolving ambiguous matching
#' @param match The column of the string to match and passed to taxizedb
#' @importFrom taxizedb name2taxid classification
#' @importFrom dplyr filter pull 
#' @importFrom stringdist stringdist
.matching <- function(fullname, match, rank, ..., threshold=0.1){
    name <- NULL
    if (is.na(match)){
        out <- NA_character_
    } else {
        ref_ranks <- c("superkingdom", "phylum", "class", "order", "family", "genus")
        id <- taxizedb::name2taxid(match, out_type = "summary")
        if (nrow(id) == 1){
            out <- id$id
        } else if (nrow(id) == 0) {
            out <- NA_character_
        } else {
            class <- taxizedb::classification(id$id)
            class <- Filter(class, f = function(x){
                q_name <- x %>% dplyr::filter(rank %in% ref_ranks) %>% dplyr::pull(name) %>%
                    tolower() %>% paste(collapse = "_")
                r_name <- fullname %>% tolower()
                dist <- stringdist::stringdist(q_name, r_name, method = "jaccard")
                dist <= threshold
            })
            if (length(class) >= 2 | length(class) == 0){
                out <- NA_character_
            } else {
                out <- names(class)
            }
        }
    }
    return(out)
}


