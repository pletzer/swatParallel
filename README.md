# swatParallel
A collection of scripts to run parameter scans of SWAT models

## Prerequisites

You'll need:
 1. [SWAT](https://github.com/WatershedModels/SWAT.git)
 2. R with [SWATPlusR](https://chrisschuerz.github.io/SWATplusR/articles/SWATplusR.html)


## Key commands

### Create an experiment

```
swt create -c  <exp.cfg>
```

### Run the experiment

```
swt run -c <exp.cfg> -N <num procs>
```

### Analyse the experiment
```
swt analyse -c <exp.cfg>
```


## Example


