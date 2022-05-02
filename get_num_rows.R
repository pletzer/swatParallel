args <- commandArgs(trailingOnly=TRUE)
param_file <- args[1]
param_table <- readRDS(param_file)
cat(sprintf("%d\n", nrow(param_table)))
