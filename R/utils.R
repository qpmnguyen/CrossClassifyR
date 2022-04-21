#' @title Checking the version of each matching database
#' @param db (Character). The name of the database. 
#' @return Returns version number as string. 
check_version <- function(db = c("silva", "metaphlan")){
    db <- match.arg(db, c("silva", "metaphlan"))
    ver <- switch(db, 
           "silva" = "138.1"
    )
    message(paste(toupper(db), "version", ver))
    return(ver)
}

rebuild <- function(db){
    db <- match.arg(db, c("ncbi"))
    if (db == "ncbi"){
        taxizedb::db_download_ncbi(overwrite = TRUE)
    }
}