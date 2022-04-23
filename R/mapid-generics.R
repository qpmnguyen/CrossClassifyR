#' @title Mapping taxonomic names to NCBI identifiers
#' @description This function takes a data container object (type \code{phyloseq}, \code{data.frame}\\\code{tibble}, 
#'     \code{TreeSummarizedExperiment}) and returns NCBI identifiers.  
#' @param obj A \code{phyloseq} type object or a \code{TreeSummarizedExperiment} type object
#' @param type Approach used to match names with identifiers. Can be either \code{db}, \code{path},
#'     \code{name}. 
#' @param db (String). If type is \code{db}, this argument specifies which db to use. Defaults to NULL. 
#'     Currently only supports \code{silva} and \code{metaphlan}
#' @param rebuild_ncbi (Logical). Indicate whether \code{taxizedb} should re-build the cached NCBI database. 
#' @param ... Other arguments not currently used
#' @details The input is a \code{data.frame}, \code{matrix}, or typical microbiome container that has 
#'     a taxonomic table specified. The schematic of a taxonomic table is a table where the left-most 
#'     column indicates the highest level of the hierarchy (usually kingdom or superkingdom) and the right-most
#'     column specifies the lowest level of the taxonomic hierarchy (usually species, genus or strains). Given 
#'     that format, the \code{type} argument determines how matching is done. 
#'     \itemize{
#'         \item{\code{name}:}{ This matches using the name of the lowest rank in the taxonomic table to the NCBI database.} 
#'         \item{\code{path_*}:}{ Uses a full path matching algorithm as defined in Balvociute and Huson 2017. 
#'             (doi: 10.1186/s12864-017-3501-4)}
#'         \item{\code{db}:}{ Use directly from a database that has a cross-walk between NCBI Ids and the full name path. Currently
#'             only silva and metaphlan are supported. Future support might include RDP}. 
#'     } 
#' @export 
setGeneric("mapid", function(obj, type, ..., rebuild_ncbi = FALSE, db = NULL) standardGeneric("mapid"))


#' @importClassesFrom phyloseq phyloseq
#' @describeIn mapid \code{phyloseq} dispatch
#' @importFrom tibble as_tibble rownames_to_column column_to_rownames
#' @importFrom phyloseq tax_table 
#' @export
setMethod("mapid", "phyloseq", function(obj, type, ..., rebuild_ncbi = FALSE, db = NULL){
    # CHECK ARGUMENTS 
    type <- match.arg(type, choices = c("name", "db"))
    if (type == "db"){
        if (is.null(db)){
            stop("If type is db, requires specifying which db to use. Currently
                 supports silva or metaphlan")
        }
    }
    db <- match.arg(db, choices = c("silva"))
    
    df <- as.data.frame(phyloseq::tax_table(obj)) %>% 
        tibble::rownames_to_column(var = "df_id") %>% 
        tibble::as_tibble()

    if (type == "name"){
        df <- .mapidnames(df = df, rebuild = rebuild_ncbi)
    } else if (type == "db"){
        df <- .mapiddb(df = df, db = db)
    }
    
    df <- df %>% as.data.frame() %>% 
        tibble::column_to_rownames("df_id") %>%
        as.matrix()

    phyloseq::tax_table(obj) <- df
    return(obj)
})

#' @importClassesFrom TreeSummarizedExperiment TreeSummarizedExperiment
#' @describeIn mapid \code{TreeSummarizedExperiment} dispatch
#' @export
setMethod("mapid", "TreeSummarizedExperiment", function(obj, type, ..., rebuild_ncbi = FALSE, db = NULL){
    
})