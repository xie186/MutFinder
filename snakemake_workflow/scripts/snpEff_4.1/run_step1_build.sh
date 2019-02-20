java -jar /group/bioinfo/apps/apps/snpEff-3.6/snpEff.jar build 


###################
mkdir /scratch/conte/x/xie186/data/ara/snpEff_database/TAIR10
#cp /scratch/conte/x/xie186/data/ara/TAIR10_chr_all.fasta /scratch/conte/x/xie186/data/ara/snpEff_database/TAIR10/sequences.fa
#cp /scratch/conte/x/xie186/data/ara/TAIR10_GFF3_genes.gff /scratch/conte/x/xie186/data/ara/snpEff_database/TAIR10/genes.gff

cp  Arabidopsis_thaliana.TAIR10.23.dna.toplevel.fa /scratch/conte/x/xie186/data/ara/snpEff_database/TAIR10/sequences.fa
cp Arabidopsis_thaliana.TAIR10.23.gtf /scratch/conte/x/xie186/data/ara/snpEff_database/TAIR10/genes.gtf

java -jar /scratch/conte/x/xie186/software/snpEff_4.1/snpEff.jar build -c snpEff_TAIR10.config TAIR10
