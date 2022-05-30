library(dplyr)
library(ggplot2)
library(tidyr)
library(gridExtra)
library(lattice)

args <- commandArgs(trailingOnly=TRUE)
nq <- length(args) - 1

# run some checks
if (nq <= 1) {
	print("ERROR: need to provide <path to simulation.rds> <out field index1> <out field index2> ...")
	stopifnot(1 == 0)
}
simulation_file <- args[1]



sim_data <- readRDS(simulation_file)

file_name <- "q.pdf"
pdf(file = file_name)
for (i in 1:nq) {
	field_name <- sprintf("q_%d", i)
	data <- sim_data[[field_name]]
	# got from data, run_1, run_2, ... to date, run, q format
	data_long <- gather(data, run, q, run_1:run_100, factor_key=TRUE)
	p <- ggplot(data = data_long, aes(x = date, y = q, colour = run)) + 
	              geom_line() + theme(legend.position = "none") + ggtitle(field_name)
	print(p)
}
dev.off()
print(sprintf("File %s was saved", file_name))


