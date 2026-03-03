#!/bin/bash
#SBATCH -N 1
#SBATCH -C gpu
#SBATCH -q debug
#SBATCH -t 00:03:00
#SBATCH -J climsim
#SBATCH -A m4334
#SBATCH --mail-user=frieldskatherine@gmail.com
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --gpus-per-node=1

# Paths on NERSC (make sure these dirs exist in your $HOME or $SCRATCH
SHARED=/global/homes/k/kfrields/shared_e3sm


srun -n 1 shifter --image=docker:katherinefrields/e3sm-climsim_2:latest \
    --volume=/pscratch/sd/k/kfrields/climsim-online-data/inputdata:/storage/inputdata \
    --volume=/pscratch/sd/k/kfrields/climsim-online-data/scratch:/scratch \
    python /global/homes/k/kfrields/climsim-online/E3SM/climsim_scripts/example_job_submit_mmf.py

#python /global/homes/k/kfrields/climsim-online/E3SM/climsim_scripts/diff_mmf.py

#--volume=/pscratch/sd/k/kfrields/climsim-online-data/scratch:/scratch \
#--volume=/pscratch/sd/k/kfrields/hugging/E3SM-MMF-online-runs:/scratch \
