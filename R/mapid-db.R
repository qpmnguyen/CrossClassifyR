.mapiddb <- function(df, db) {
    NULL
}

.mapsilva <- function(df){
    df_id <- fullname <- silva_path <- NULL
    ranks <- colnames(df %>% dplyr::select(-df_id))
    max_ranks <- ranks[length(ranks)]
    df_reduced <- df %>% tidyr::unite(col = "fullname", dplyr::all_of(ranks), remove=FALSE, sep = ";") %>% 
        dplyr::mutate(fullname = paste0(fullname, ";")) %>%
        dplyr::mutate(match = !!rlang::sym(max_ranks), rank = max_ranks) %>%
        tidyr::drop_na(!!rlang::sym(max_ranks))
    df_distinct <- df_reduced %>% dplyr::distinct(fullname, rank) %>% 
        dplyr::mutate(fullname = tolower(fullname), rank = tolower(rank))
    test <- dplyr::left_join(df_distinct %>% dplyr::rename("silva_path" = "fullname"), 
                     silva %>% mutate(silva_path = tolower(silva_path)), 
                     by = c("silva_path", "rank"))
    return(NULL)
}
