# swatParallel

A collection of scripts to run SWAT model parameter scans

## Prerequisites

You'll need:
 1. A Fortran compiler
 1. CMake
 1. [SWAT](https://github.com/WatershedModels/SWAT.git)
 1. R with [SWATplusR](https://chrisschuerz.github.io/SWATplusR/articles/SWATplusR.html) installed
 1. Python 3.8 or later, with package `defopt` installed


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

On mahuika, you'll want the `R` and `Python` modules to be loaded
```
source swt_mahuika.sh
```
You'll also need to install `defopt`,
```
pip install defopt --user
```


Type
```
usage: swt [-h] {clean,prep,run,merge,plot} ...

positional arguments:
  {clean,prep,run,merge,plot}
    clean               Clean the experiment
                        :param config: JSON configuration file
    prep                Prepare
                        :param config: JSON configuration file
                        :param num_procs: number of parallel processes
    run                 Create SLURM run script
                        :param config: configuration file
    merge               Analyse the results
                        :param config: configuration file
    plot                Plot the results
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
This will generate the SLURM script to launch the tasks. To submit the script, type
```
sbatch run/<exp>/run.sl
```
Typically, `run.sl` will submit an array of jobs. You can track the execution of the jobs with
```
squeue --me
```
and you will see something like
```
squeue --me
JOBID         USER     ACCOUNT   NAME        CPUS MIN_MEM PARTITI START_TIME     TIME_LEFT STATE    NODELIST(REASON)    
27110315      pletzera nesi99999 python         2    512M large   May 22 21:40     1:03:12 RUNNING  wbn234              
27114447_0    pletzera nesi99999 swt-20w-8t    16    500M large   May 23 01:34       57:18 RUNNING  wbn234              
27114447_1    pletzera nesi99999 swt-20w-8t    16    500M large   May 23 01:34       57:18 RUNNING  wbn185              
27114447_2    pletzera nesi99999 swt-20w-8t    16    500M large   May 23 01:34       57:18 RUNNING  wbn185              
27114447_3    pletzera nesi99999 swt-20w-8t    16    500M large   May 23 01:34       57:18 RUNNING  wbn216              
```
Each job will generate a file `slurm-<jobid>_<workerid>.out`. It's good to inspect these files to check that the execution was successful. You can also check that the execution was successful with
```
sacct -j <jobid>
```
(Here, `<jobid>` would be 27114447.)


### Merge the experiment

Each worker will run multiple iterations of the SWAT code over different parameter scans. This command merges all the results into `parameter.rds` and `simulation.rds` files under the run directory specified in the configuration file.
```
./swt merge -c <exp.json>
```

You can read the results in R using:
```R
param <- readRDS("<run_dir>/parameter.rds")
simul <- readRDS("<run_dir>/simulation.rds")
```
where `<run_dir>` is run directory defined in the `<exp.json>` file. 

An example of parameter values is:
```R
param
# A tibble: 100 × 2
       CN2 ALPHA_BF
     <dbl>    <dbl>
 1   9.63    0.941 
 2 -11.2     0.329 
 3 -11.8     0.0926
 4  -3.25    0.445 
 5  -7.36    0.383 
 6 -10.6     0.945 
 7   0.917   0.133 
 8 -10.3     0.321 
 9 -14.2     0.893 
10  -2.70    0.802 
# … with 90 more rows
```

An example of simulation data is:
```R
names(simul)
[1] "q_1" "q_2" "q_3"
colnames(simul$q_2)
  [1] "date"    "run_1"   "run_2"   "run_3"   "run_4"   "run_5"   "run_6"  
  [8] "run_7"   "run_8"   "run_9"   "run_10"  "run_11"  "run_12"  "run_13" 
 [15] "run_14"  "run_15"  "run_16"  "run_17"  "run_18"  "run_19"  "run_20" 
 [22] "run_21"  "run_22"  "run_23"  "run_24"  "run_25"  "run_26"  "run_27" 
 [29] "run_28"  "run_29"  "run_30"  "run_31"  "run_32"  "run_33"  "run_34" 
 [36] "run_35"  "run_36"  "run_37"  "run_38"  "run_39"  "run_40"  "run_41" 
 [43] "run_42"  "run_43"  "run_44"  "run_45"  "run_46"  "run_47"  "run_48" 
 [50] "run_49"  "run_50"  "run_51"  "run_52"  "run_53"  "run_54"  "run_55" 
 [57] "run_56"  "run_57"  "run_58"  "run_59"  "run_60"  "run_61"  "run_62" 
 [64] "run_63"  "run_64"  "run_65"  "run_66"  "run_67"  "run_68"  "run_69" 
 [71] "run_70"  "run_71"  "run_72"  "run_73"  "run_74"  "run_75"  "run_76" 
 [78] "run_77"  "run_78"  "run_79"  "run_80"  "run_81"  "run_82"  "run_83" 
 [85] "run_84"  "run_85"  "run_86"  "run_87"  "run_88"  "run_89"  "run_90" 
 [92] "run_91"  "run_92"  "run_93"  "run_94"  "run_95"  "run_96"  "run_97" 
 [99] "run_98"  "run_99"  "run_100"
```
The rows are the dates and the columns are the simulation results for each of the parameter values in `parameter.rds`. 

### Generate plots of the experiment

Once the results are merged you can plot the results with
```
./swt plot -c <exp.json>
```
This will generate <run_dir>/simulation.pdf.

![alt Example of a simulation plot](https://github.com/pletzer/swatParallel/blob/main/figures/simulation-0.png)


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




