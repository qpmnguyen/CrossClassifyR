library(here)
here::i_am("data-raw/metaphlan.R")
source(here("data-raw", "deps.R"))

f <- tempfile()
download.file("https://zenodo.org/record/5668382/files/mpa_v30_CHOCOPhlAn_201901_marker_info.txt.bz2?download=1", 
              destfile = f)

# stream through file
filecon <- file(f, "r")
count <- 1
while (TRUE) {
    line <- readLines(filecon, n = 1)
    if (length(line) == 0) {
        break
    }
    proc_line <- strsplit(line, "\t")[[1]]
    ncbiid <- as.integer(str_split(proc_line[1], "__")[[1]][1])
    # search to see if the queried taxa is already in the database
    search_id <- dbGetQuery(dbcon, "SELECT * FROM taxonomy where ncbiid = ?")
    dbBind(search_id, list(ncbiid))
    queried_id <- dbFetch(search_id)
    if (nrow(queried_id) == 0) {
        dbClearResult(search_id)
        insert_line <- process_json(proc_line[2])
        insert_line <- cbind(ncbiid, insert_line)
        dbAppendTable(conn = dbcon, name = "taxonomy", value = insert_line)
        count <- count + 1
        if (count %% 500 == 0) {
            print(count)
        }
    } else {
        next
    }
}
close(filecon)