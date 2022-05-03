library(dplyr)

args <- commandArgs(trailingOnly=TRUE)
run_dir <- args[1]

regex_path <- sprintf("%s/worker_*", run_dir)
worker_dirs <- Sys.glob(regex_path)

results <- list()
for (worker_dir in worker_dirs) {
	result_path <- sprintf("%s/result.rds", worker_dir)
 	results[[worker_dir]] <- readRDS(result_path)
}

file_name <- sprintf("%s/results.rds", run_dir)
saveRDS(results, file = file_name)
print("SUCCESS")