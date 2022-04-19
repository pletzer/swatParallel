# swatParallel
A collection of scripts to run SWAT model parameter scans

## Prerequisites

You'll need:
 1. CMake
 1. [SWAT](https://github.com/WatershedModels/SWAT.git)
 2. R with [SWATplusR](https://chrisschuerz.github.io/SWATplusR/articles/SWATplusR.html)


### Building SWAT 

On Unix/Linux/Mac OSX:
```
git clone https://github.com/WatershedModels/SWAT.git
cd SWAT
mkdir build
cd build
cmake ..
cmake --build . 
```

On mahuika, we recommend to use the Intel compiler
```
module load intel CMake
cd SWAT
mkdir build
cd build
FC=ifort cmake ..
cmake --build . 
```

On Windows, the following should work (not tested)
```
cd SWAT
mkdir build
cd build
FC=ifx cmake -G "NMake Makefiles" ..
cmake --build .
```

### Installing SWATPlusR

In R:
```R
install.packages('remotes')
remotes::install_github('chrisschuerzls/SWATplusR')
```

## Key commands

### Prepare an experiment

```
./swt prep -c  <exp.cfg>
```

### Run the experiment

```
./swt run -c <exp.cfg>
```

### Analyse the experiment
```
./swt analyse -c <exp.cfg>
```

## Configuration file



## Example


