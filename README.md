# ICME
A pipeline to identify causal mutations in EMS mutant

http://htmlpreview.github.io/?https://raw.githubusercontent.com/xie186/MutFinder/master/MutFinder.html


Method

Re-sequencing reads from wild type and mutant were aligned to TAIR10 reference genome using bwa. SAM files 
generated were then converted to BAM files. PCR duplications were removed using MarkDuplicates.jar in Picard (http://broadinstitute.github.io/picard/). HaplotypeCaller in GATK was then used to identify the SNPs in both 
wild type and mutant samples. We chose the SNPs meet the following requirements: 1) showing homozygous reference 
allele in wild type; 2) showing C->T or G->A mutation between wild type and mutant samples; 3) showing ratios 
of the reads with alternative alleles/read depth > 0.3. 
With SNPs meeting the requirements above, 

References:

bwa reference

Li H. and Durbin R. (2009) Fast and accurate short read alignment with Burrows-Wheeler Transform. Bioinformatics, 25:1754-60. [PMID: 19451168]

