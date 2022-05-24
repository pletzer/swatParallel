library(dplyr)
library(stringr)

args <- commandArgs(trailingOnly=TRUE)
run_dir <- args[1]

regex_path <- sprintf("%s/worker_*", run_dir)
worker_dirs <- Sys.glob(regex_path)

result_path <- sprintf("%s/worker_0000/result.rds", run_dir)
result <- readRDS(result_path)
date <- result$simulation$q_1$date
output_field_names <- names(result$simulation)

parameter_list <- list()
simulation_list <- list()
for (worker_dir in worker_dirs) {

	# get the path to this workers's result file
	result_path <- sprintf("%s/result.rds", worker_dir)

	# read the results
	result <- readRDS(result_path)

	# extract the worker Id, eg "0001"
	worker_id <- str_replace(basename(worker_dir), "worker_", "")

	# store the parameter values
	parameter_list[[worker_id]] <- result$parameter$values

	# store the simulation output values, but without the date, and for each output field
	for (output_field_name in output_field_names) {
		simulation_list[[output_field_name]][[worker_id]] <- result$simulation[[output_field_name]] %>% select(-contains("date"))
	}
}

# merge the tables
parameter <- dplyr::bind_rows(parameter_list)

simulation <- list()
for (output_field_name in output_field_names) {

	simulation[[output_field_name]] <- dplyr::bind_cols(simulation_list[[output_field_name]])

	# rename the columns run_1, run_2, ... run_n
	simulation[[output_field_name]] <- rename(simulation[[output_field_name]], run_ = colnames(simulation[[output_field_name]]))

	# add the date back to the simulation table, at column 1
	simulation[[output_field_name]] <- cbind(date = date, simulation[[output_field_name]])
}

# save the results to file
parameter_file <- sprintf("%s/parameter.rds", run_dir)
print(sprintf("...writing parameter values to %s", parameter_file))
saveRDS(parameter, file = parameter_file)

simulation_file <- sprintf("%s/simulation.rds", run_dir)
print(sprintf("...writing simulation values to %s", simulation_file))
saveRDS(simulation, file = simulation_file)

print("SUCCESS")