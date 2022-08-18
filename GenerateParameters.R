# Script to generate parameter table for later use in SwatPlusR
# Generates a table with a user-specified number of rows (simulations) from a set of parameters
# with user-specified lower and upper bounds. Rows are generated from Latin hypercube sampling.
# Names of the parameters are set up in a specific format used later by SWATPlusR


# rm(list = ls()) # clean up

library(dplyr)
library(readr)
library(lhs) # for latin hypercube sampling 

# assume working directory is already established

# parameters
nsimulations = 100
set.seed(111)

# Specify parameter names and bounds. A row for each parameter

ParamBounds <- tribble(
  ~ParamName,  ~ParamMin,  ~ParamMax,
  "CN2.mgt | change = abschg",0.,1.,
  "ALPHA_BF.gw | change = absval",0.001,0.999
)


nparams <- nrow(ParamBounds)

# Create the parameter distribution
RanUnitUniform <- randomLHS(nsimulations,nparams)
minimums <- matrix(ParamBounds$ParamMin,nsimulations,nparams,byrow=TRUE)
maximums <- matrix(ParamBounds$ParamMax,nsimulations,nparams,byrow=TRUE)
ParamSetMatrix <- minimums + (maximums-minimums) * RanUnitUniform # Matrix with named columns (and eventually rows)
colnames(ParamSetMatrix) <- ParamBounds$ParamName

ParamSetTibble <- as_tibble(ParamSetMatrix) # set up tibble because this will be expected by SwatPlusR
 # For SwatPlusR, will need to modify tibble names to indicate the file and modification type. 

saveRDS(ParamSetTibble,'ParameterTable.rds')




