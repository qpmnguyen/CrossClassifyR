## code to prepare `DATASET` dataset goes here
library(data.table)
library(tidyverse)
library(here)

here::i_am("data-raw/silva.R")

here("sources/silva.R")
df <- read_table(gzfile("../sources/taxmap_slv_ssu_ref_138.1.txt.gz"))




df %>% mutate(root. = str_remove_all(root., " <.*?>")) %>% filter(no.rank == "genus") %>%
    filter(str_detect(root., "Bacteria")) %>%
    filter(str_detect(root., "group")) %>%
    slice(10)


df2 <- readDNAStringSet(filepath = "../sources/silva_nr99_v138.1_train_set.fa.gz")
names(df2)[names(df2) %>% str_detect("Chlorobi")][1:10]


usethis::use_data(DATASET, overwrite = TRUE)
