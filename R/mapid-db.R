.mapiddb <- function(df, db) {
    db <- match.arg(db, c("silva", "metaphlan"))
    if (db == "silva"){
        match <- silva
    }
    silva
    ranks <- colnames(df %>% dplyr::select(-df_id))
    df_fullname <- df %>% tidyr::unite(col = "full_path", all_of(ranks), remove = FALSE, sep = ";")
    left_join(df_fullname, match, by = "full_path")
    
    
    
}