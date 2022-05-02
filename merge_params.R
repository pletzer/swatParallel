library(dplyr)

library(dplyr)
args <- commandArgs(trailingOnly=TRUE)
run_dir <- args[1]

regex_path <- sprintf("%s/worker_*", run_dir)
worker_dirs <- Sys.glob(regex_path)

params <- tibble()
for (worker_dir in worker_dirs) {
	result_file <- sprintf("%s/result.rds", worker_dir)
	res <- readRDS(result_file)
	params <- bind_rows(params, res$parameter$values)
}

file_name <- sprintf("%s/parameter_values.rds", run_dir)
saveRDS(params, file = file_name)
print("SUCCESS")