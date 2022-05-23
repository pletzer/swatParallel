library(dplyr)

args <- commandArgs(trailingOnly=TRUE)
run_dir <- args[1]

regex_path <- sprintf("%s/worker_*", run_dir)
worker_dirs <- Sys.glob(regex_path)

parameter_list <- list()
simulation_list <- list()
for (worker_dir in worker_dirs) {
	result_path <- sprintf("%s/result.rds", worker_dir)
	result <- readRDS(result_path)

	worker_id <- basename(worker_dir)

	parameter_list[[worker_id]] <- result$parameter$values
 	simulation_list[[worker_id]] <- result$simulation
}

parameter <- dplyr::bind_rows(parameter_list)
simulation <- dplyr::bind_cols(simulation_list)

date <- simulation["date...1"]

simulation <- simulation %>% select(-contains("date"))

# put back the date
simulation["date"] <- date

parameter_file <- sprintf("%s/parameter.rds", run_dir)
print(sprintf("...writing parameter values to %s\n", parameter_file))
saveRDS(parameter, file = parameter_file)

simulation_file <- sprintf("%s/simulation.rds", run_dir)
print(sprintf("...writing simulation values to %s\n", simulation_file))
saveRDS(simulation, file = simulation_file)

print("SUCCESS")