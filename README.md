# TaxaSetsUtils: Additional convenience functions to use taxonomic sets for microbiome analysis  

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->


This package provides utility functions to work with microbe sets. Some current (or planned) features:   

- [ ] Attaching NCBI ids to taxonomic tables using both conventional name queries as well as via lookups tables (e.g. for databases such as SILVA and ChocoPhlAn)
- [ ] Use more complex path-matching approaches (e.g. [Balvocuiute & Huson](https://bmcgenomics.biomedcentral.com/articles/10.1186/s12864-017-3501-4))  
- [ ] Generate complementary `BiocSet` based on the dataset identifier (e.g. `taxa_names` in `phyloseq`) if multiple OTUs/ASVs are matched to the same genus/species.  
- [ ] Attach sets from prepared ontologies such as BugSigDB  
