# swatParallel

A collection of scripts to run SWAT model parameter scans

## Prerequisites

You'll need:
 1. A Fortran compiler
 1. CMake
 1. [SWAT](https://github.com/WatershedModels/SWAT.git)
 1. R with [SWATplusR](https://chrisschuerz.github.io/SWATplusR/articles/SWATplusR.html) installed
 1. Python 3.8 or later


### How to compile the Fortran SWAT code

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

### How to install the SWATPlusR package

In R:
```R
install.packages('remotes')
remotes::install_github('chrisschuerz/SWATplusR')
```

## Key commands to prepare, execute, submit and merge experiment results

Go to the `swatParallel` directory
```
cd swatParallel
```

On mahuika, you'll wand the `R` and `Python` modules to be loaded
```
module load R Python intel
pip install defopt --user
```

Type
```
./swt -h
usage: swt [-h] {clean,prep,run,merge} ...

positional arguments:
  {clean,prep,run,merge}
    clean               Clean the experiment
                        :param config: JSON configuration file
    prep                Prepare
                        :param config: JSON configuration file
    run                 Run
                        :param config: configuration file
    merge               Analyse the results
                        :param config: configuration file

optional arguments:
  -h, --help            show this help message and exit
```
for a list of commands.

Additional help can be obtained by typing `./swt <command> -h`. For instance:
```
./swt prep -h
usage: swt prep [-h] -c CONFIG [-n NUM_PROCS]

Prepare
:param config: JSON configuration file
:param num_procs: number of parallel processes

optional arguments:
  -h, --help            show this help message and exit
  -c CONFIG, --config CONFIG
  -n NUM_PROCS, --num-procs NUM_PROCS
                        (default: 1)
```

Most commands take command line argument `-c <exp.json>` where `exp.json>` is a configuration file in JSON format. Directory `examples/*` contains a number of example configuration files. [Click here to see an example of JSON configuration file](#configuration-file-format)

### Clean the run directory of an experiment


If you want to start from a clean state,
```
./swt clean -c <exp.json>
```
This will delete the run directory for this experiment.


### Prepare an experiment

```
./swt prep -c <exp.json>
```
This will create the run directory structure and create the run scripts.

Note: copying the files can be slow. You can accelerate this step by passing the `-n <num_procs>`. On mahuika, you can submit a job like so:
```
srun --ntasks=1 --cpus-per-task=8 ./swt prep -c examples/ex20/ex20.json -n 8
```
(for instance). In the above, we're using 8 processes from a single node to create the 20 directories.

### Run the experiment

```
./swt run -c <exp.json>
```
This will generate the SLURM script to launch the tasks.

### Merge the experiment

Each worker will run multiple iterations of the SWAT code over different parameter scans. This command merges all the results into one file.
```
./swt merge -c <exp.json>
```

## Configuration file format

An example of a configuration file is
```json
{
    "run_dir": "./run/ex4",
    "project_dir": "../TxtInOut_Ruataniwha_test",
    "swat_exec": "../SWAT/build_intel/src/swat2012.682.ifort.rel",
    "sim": {
        "n_workers": 4,
        "n_threads_per_worker": 8,
        "input": "examples/ex4/ex4.rds",
        "output": {
            "var" : "FLOW_OUT.rch",
            "units": "1:3"
        }
    },
    "scheduler": {
        "slurm": {
            "account": "nesi99999",
            "mem": "2500MB",
            "time": "00:20:00"
        }
    }
}
```
Note the number of workers and the number of threads per worker. The input parameters are set, here, in the `examples/ex4/ex4.rds` file.

## The input file

The input file holds a `tibble` object, which sets the parameter values to change across simulations. In the following, parameters `CN2.mgt` and `ALPHA_BF.gw` are given 10 different values. The column names are important, refer to the SWATPlusR documentation for more information.

```
   CN2.mgt | change = abschg ALPHA_BF.gw | change = absval
1                  7.7217022                    0.95766123
2                -10.5225200                    0.26965267
3                  8.6272708                    0.13610409
4                 -4.5344573                    0.18614407
5                 -1.8126788                    0.28370613
6                  0.6298365                    0.47322254
7                 -0.8084397                    0.49547058
8                 -6.3299731                    0.29937163
9                -10.8317385                    0.04124022
10                -5.5446769                    0.27589847
```
These 10 rows are then split across the workers.




