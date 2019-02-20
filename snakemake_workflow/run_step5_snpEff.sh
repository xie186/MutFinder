
awk '$1=="chr2" && $2 > 14406584' output.raw.snps.indels.vcf > output.raw.snps.indels_candi.vcf
java -jar /scratch/conte/x/xie186/software/snpEff_4.1/snpEff.jar eff -no-downstream -no-intergenic -no-upstream  athalianaTair10 output.raw.snps.indels_candi.vcf > output.raw.snps.indels_candi.eff

perl mutmap_gener_region.pl output.raw.snps.indels.vcf CZZ013  CZZ014 chr2,14406584,19641252 > output.raw.snps.indels_candi_var.vcf


perl mutmap_gener_region.pl output.raw.snps.indels.vcf CZZ013  CZZ016 chr1,5000000,18504478 > output.snps_candi_var_2-2.vcf
java -jar /scratch/conte/x/xie186/software/snpEff_4.1/snpEff.jar eff -s output.snps_candi_var_2-2.html -no-downstream -no-intergenic -no-upstream  athalianaTair10 output.snps_candi_var_2-2.vcf > output.snps_candi_var_2-2.eff

perl mutmap_gener_region.pl output.raw.snps.indels.vcf CZZ013  CZZ015  chr1,0,4940389 > output.snps_candi_var_7-8.vcf
java -jar /scratch/conte/x/xie186/software/snpEff_4.1/snpEff.jar eff -s output.snps_candi_var_7-8.html -no-downstream -no-intergenic -no-upstream  athalianaTair10 output.snps_candi_var_7-8.vcf > output.snps_candi_var_7-8.eff
