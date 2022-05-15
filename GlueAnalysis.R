# Script to do GLUE analysis of model simulation output
# rm(list = ls()) # clean up

library(dplyr)
library(readr)
library(hydroGOF) # for fit statistics
library(Hmisc) # for weighted quantiles

#### Set up parameters and files

# assume working directory is script location

ParametersFile <- "ParameterTable.rds" # The set of parameters used for the simulations. Include path if not in same directory as working directory
PredictionsFile <- "Results.rds" #  A table of the results. Simulation/Run number across columns. First column will be the date
ObservationsFile <- "Observations.csv" # file with observations table

#### Read inputs

Parameters <- readRDS(ParamSetTribble,ParmaetersFile) # it might be better to read these from the SwatplusR output to ensure correct alignment
nparams <- ncol(Parameters) # no column with the run ID. So assume run number is same as row number

Preds <- readRDS(ParamSetTribble,PredictionsFile)

Obs <- read_csv(file=ObservationsFile,)
nobs <- nrow(Obs)


##### Analyse results

## 1 Calculate fit metric for each simulation

FitStat <- rep(as.double(0),nsimulations)
for (isim in 1:nsimulations){
  FitStat[isim] <- NSE(Preds[,isim],Obs$y)
}

## 2 Select simulations with satisfactory performance

RowSimOK <- which(FitStat > FitCutoff)
nSimulationsOK <- length(RowSimOK)
ParamSetMatrix <- ParamSetMatrix[RowSimOK,]
FitStat <- FitStat[RowSimOK]
Preds <- Preds[,RowSimOK+1] # allow for the first column to be the dates. Also assume alignment between the parameter rows and the output columns 
colnames(Preds) <- paste0("Run",RowSimOK)
rownames(ParamSetMatrix) <-  paste0("Run",RowSimOK)

## 3.3 Best parameters

RowFitBest <- which.max(FitStat) # row number of best fit in the behavioural set
FitBest <- FitStat[RowFitBest]
IDBest <- IDSimOK[RowFitBest]

ParamBest <- ParamSet[RowFitBest,]
PredsBest <- Preds[,RowFitBest]

## 3.4 GLUE predictions

SumFitStat <- sum(FitStat)
FitWeight <- FitStat/SumFitStat
PredsLower <- c(rep(0,nobs))
PredsUpper <- c(rep(0,nobs))
for (iobs in 1:nobs){
  PredsLower[iobs] <- wtd.quantile(Preds[iobs,],weights = FitWeight,probs=c(0.05),normwt=TRUE)
  PredsUpper[iobs] <- wtd.quantile(Preds[iobs,],weights = FitWeight,probs=c(0.95),normwt=TRUE)
}

PredsBoundsGlue <- tibble(PredsLower,PredsBest,PredsUpper)

##### Output key results

# reduced set of parameters
# output bounds
# fit statistics
# reduced outputs

