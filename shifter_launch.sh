#!/bin/bash
#SBATCH -N 1
#SBATCH -C gpu
#SBATCH -q debug
#SBATCH -t 00:10:00
#SBATCH -J climsim
#SBATCH -A m4334
#SBATCH --mail-user=frieldskatherine@gmail.com
#SBATCH --gpus-per-node=1

# Paths on NERSC (make sure these dirs exist in your $HOME or $SCRATCH)
INPUTDATA=/pscratch/sd/k/kfrields/climsim-online-data/inputdata
SHARED=/global/homes/k/kfrields/shared_e3sm
SCRATCH_DIR=/pscratch/sd/k/kfrields/climsim-online-data/scratch


srun -n 1 shifter --image=docker:katherinefrields/e3sm-climsim:latest \
    --volume=$INPUTDATA:/storage/inputdata \
    --volume=$SHARED:/storage/shared_e3sm \
    --volume=$SCRATCH_DIR:/scratch \
    python example_job_submit_mmf.py
