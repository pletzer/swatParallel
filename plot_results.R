library(dplyr)
library(ggplot2)
library(tidyr)
library(stringr)

args <- commandArgs(trailingOnly=TRUE)
nargs <- length(args)

# run some checks
if (nargs < 3) {
    print("ERROR: need to provide <path to simulation.rds> <field_name> <field_units>")
    stopifnot(1 == 0)
}
simulation_file <- args[1]
name <- args[2]
unit_lst <- eval(parse(text=args[3]))

sim_data <- readRDS(simulation_file)

output_file_name <- str_replace(simulation_file, "simulation.rds", sprintf("%s.pdf", name))
pdf(file = output_file_name, width = 10, height = 8)
for (i in unit_lst) {
    field_name <- sprintf("%s_%d", name, i)
    data <- sim_data[[field_name]]
    nms <- names(select(data, contains("run_")))
    # go from data, run_1, run_2, ... to date, run, q format
    data_long <- gather(data, run, name, nms[1]:nms[length(nms)], factor_key=TRUE)
    p <- ggplot(data = data_long, aes(x = date, y = name, colour = run)) + 
                  geom_line() + theme(legend.position = "none") + ggtitle(field_name)
    print(p)
}
dev.off()
print(sprintf("File %s was saved", output_file_name))
print("SUCCESS")


