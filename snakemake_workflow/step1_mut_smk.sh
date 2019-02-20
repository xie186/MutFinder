module load anaconda/5.1.0-py36; source activate snakemake
module load bioinfo
module load java/8

snakemake --dag -s mut_finder.sm.py --configfile config.yaml --cluster-config cluster.json |dot -Tpng > dag.png


snakemake -s mut_finder.sm.py --configfile config.yaml --cluster-config cluster.json -j 100 --cluster "qsub -m e -q {cluster.queue} -l walltime={cluster.time} -l nodes=1:ppn={cluster.n} -e {cluster.error} -N {cluster.name} -o {cluster.output}" 

