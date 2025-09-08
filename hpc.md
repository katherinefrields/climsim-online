# Evaluating Online Performance on HPC cluster using apptainer/singularity container

Many HPC clusters do not support Docker but instead use Singularity (now known as Apptainer). This guide provides instructions for running a hybrid-ML simulation on an HPC cluster using an Apptainer/Singularity container. The instructions are based on the NCAR Derecho cluster, which uses a PBS-based job scheduling system.

## Download the Precompiled .sif Image

We have prepared a precompiled .sif image for the hybrid-ML simulation. You can download it from [this zenodo link](https://zenodo.org/records/15786767).

## Running the hybrid-ML simulation

### Interactive session

To run the simulation interactively on the Derecho cluster, follow these steps:

First request an interactive session with the following command:
```
qsub -I -l select=1:ncpus=2:mem=40GB -A UHAR0026 -q casper@casper-pbs -l walltime=06:00:00
```

Then navigate to the directory where you have the .sif image and run the following command to load Apptainer module and launch the singularity shell:
```
module load apptainer
singularity shell \
            --nv --cleanenv \
            --bind /glade/derecho/scratch/zeyuanhu/climsim/inputdata:/storage/inputdata \
            --bind /glade/derecho/scratch/zeyuanhu/climsim/scratch:/scratch \
            ./updated-climsim-image.sif
```
Replace `/glade/derecho/scratch/zeyuanhu/climsim/` with the path to your own directory. Ensure the following subdirectories exist under your directory:
- `inputdata`: For download E3SM input data.
- `scratch`: For all output data generated during the run.


Inside the Singularity shell, execute the following commands to launch an example hybrid simulation:
```
cd /climsim/E3SM/climsim_scripts/
python example_job_submit_nnwrapper_v4_constrained.py
```

The first time you run the simulation, the E3SM input data will be auto-downloaded. You can monitor the progress by checking the output files in the `scratch` directory.

### Batch job submission

To run the simulation as a batch job, create a PBS job script. Below is an example:

```
#!/bin/bash
#PBS -N climsim-test
#PBS -A UHAR0026
#PBS -j oe
#PBS -k eod
#PBS -q develop 
#PBS -r y
#PBS -l walltime=06:00:00
#PBS -l select=1:ncpus=32:mpiprocs=32:mem=64GB
#PBS -l job_priority=economy

# Load required modules
module load apptainer

singularity exec \
    --nv --cleanenv \
    --bind /glade/derecho/scratch/zeyuanhu/climsim/inputdata:/storage/inputdata \
    --bind /glade/derecho/scratch/zeyuanhu/climsim/scratch:/scratch \
    ./updated-climsim-image.sif \
    python3 /climsim/E3SM/climsim_scripts/example_job_submit_nnwrapper_v2.py
```

### Running a customized job script

If you want to run a customized job script instead of the provided example scripts, you can bind additional directories to the container by adding more --bind options.

For instance, suppose you have created a customized job script named test_32core.py and want to bind the /glade/work directory to the container. In the test_32core.py script, you can configure it to use 32 CPU cores by setting `max_mpi_per_node` and `max_task_per_node` as in the following line:
```
if 'CPU' in arch : max_mpi_per_node,atm_nthrds  =  32,1 ; max_task_per_node = 32
```

Below is the PBS script for submitting the customized job script:
```
#!/bin/bash
#PBS -N climsim-test
#PBS -A UHAR0026
#PBS -j oe
#PBS -k eod
#PBS -q develop 
#PBS -r y
#PBS -l walltime=06:00:00
#PBS -l select=1:ncpus=32:mpiprocs=32:mem=64GB
#PBS -l job_priority=economy

# Load required modules
module load apptainer

singularity exec \
    --nv --cleanenv \
    --bind /glade/work \
    --bind /glade/derecho/scratch/zeyuanhu/climsim/inputdata:/storage/inputdata \
    --bind /glade/derecho/scratch/zeyuanhu/climsim/scratch:/scratch \
    ./updated-climsim-image.sif \
    python3 /glade/work/zeyuanhu/climsim-online/example_scripts/test_32core.py
```

`--bind /glade/work \` allows the container image to access the /glade/work directory on the host machine. You can add more `--bind` options to bind additional directories as needed.

## Memory requirements

On Derecho, to run the example unet simulation (i.e., `example_job_submit_nnwrapper_v4_constrained` script), when we set to use 128 CPU cores, we need to request 64GB memory for the job. When we use 32 CPU cores, we need to request 16GB memory for the job. Again to set number of CPU cores, you can modify the `max_mpi_per_node` and `max_task_per_node` in the customized job script (below will use 128 CPU cores):
```
if 'CPU' in arch : max_mpi_per_node,atm_nthrds  =  128,1 ; max_task_per_node = 128
```