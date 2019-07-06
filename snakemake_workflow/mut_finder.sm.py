#shell.prefix("module load anaconda/5.1.0-py36; source activate snakemake")
raw_dir = config["raw_data_dir"]
SAMPLE = glob_wildcards(raw_dir + "{sample}_1.fq.gz").sample
#print(SAMPLE)
BAM_DIR = "s1_bwa_aln/"
BAM_RMDUP = "s2_picard_rmdup/"
HaplotypeCaller = "s3_HaplotypeCaller_vcf/"
MUT_RADAR = "s4_mutation_radar/"
#cmp_pair = {}
#def read_cmp_list:
#    cmp_list = config["GATK"]["comparison"]
#    with open(cmp_list) as cmp:
#        for line in cmp:
#            line = line.rstrip()
#            ele = line.split("\t")
wt_sample = config["GATK"]["WT"]            
SAMPLE_MUTANT = SAMPLE
SAMPLE_MUTANT.remove(wt_sample)

rule all:
     input: 
         #expand(BAM_DIR + "{sample}.srt.bam", sample = SAMPLE),
         #expand(BAM_RMDUP + "{sample}.rmdup.bam", sample = SAMPLE),
         #expand(HaplotypeCaller + "{mutant}.snp.vcf", mutant = SAMPLE_MUTANT),
         expand(MUT_RADAR + "{mutant}.mut_radar.fil.eff", mutant = SAMPLE_MUTANT),

rule bwa_aln:
    input:
        read1 = raw_dir + "{sample}_1.fq.gz",
        read2 = raw_dir + "{sample}_2.fq.gz",
    params:
        reference = config["bwa"]["reference"],
        cpu_num = config["bwa"]["cpu_num"],
    log: 
        bwa = BAM_DIR + "{sample}.bwa_aln.log"
    output:
        bam = BAM_DIR + "{sample}.srt.bam"
    shell:
        r'''
bwa mem -t 18 -R "@RG\tID:{wildcards.sample}\tPL:ILLUMINA\tLB:{wildcards.sample}\tSM:{wildcards.sample}" {params.reference} {input.read1} {input.read2} |samtools view -bS - |samtools sort -o {output.bam} -
samtools index {output.bam}
'''

rule picard_rmdup:
    input:
        bam = rules.bwa_aln.output.bam
    output:
        bam = BAM_RMDUP + "{sample}.rmdup.bam",
        matrics = BAM_RMDUP + "{sample}.rmdup.matrics",
        log = BAM_RMDUP + "{sample}.log",
    shell:
        '''
java -Xmx10g -jar scripts/picard.jar MarkDuplicates I={input.bam} O={output.bam} M={output.matrics} AS=true 2> {output.log},
samtools index {output.bam}
'''

rule HaplotypeCaller:
    input:
        mutant = BAM_RMDUP + "{mutant}.rmdup.bam",
        wt = BAM_RMDUP + wt_sample + ".rmdup.bam",
        reference = config["GATK"]["reference"]
    output:
        vcf = HaplotypeCaller + "{mutant}.snp.vcf",
        log = HaplotypeCaller + "{mutant}.snp.log",
    shell:
        '''
java -Xmx16g -XX:-UseGCOverheadLimit -jar scripts/GenomeAnalysisTK.jar -T HaplotypeCaller -R {input.reference} -I {input.wt} -I {input.mutant} -stand_call_conf 30 -stand_emit_conf 10 -o {output.vcf} 2> {output.log}
'''

rule mutation_radar:
    """
    Get the figures. 
    Generate snpEff results
    """
    input:
        vcf = HaplotypeCaller + "{mutant}.snp.vcf",
    params: 
        wt = wt_sample,
        mutant = "{mutant}",
        ideogram = config["snpEff"]["ideogram"]
    output:
        mut = MUT_RADAR + "{mutant}.mut_radar.txt",
        pdf = MUT_RADAR + "{mutant}.mut_radar.pdf",
        mut_fil = MUT_RADAR + "{mutant}.mut_radar.fil.vcf",
        eff = MUT_RADAR + "{mutant}.mut_radar.fil.eff",
    shell:
        '''
perl scripts/mutmap_gatk.pl {input.vcf} {params.wt} {params.mutant} |sort -k1,1 -k2,2n > {output.mut}
Rscript scripts/mutmap_snp_index.R --geno_info {params.ideogram} --var_info {output.mut} --out {output.pdf}
perl scripts/mutmap_gener_reg_max.pl {input.vcf} {params.wt} {params.mutant} {output.mut} > {output.mut_fil}
java -jar scripts/snpEff_4.1/snpEff.jar eff -no-downstream -no-intergenic -no-upstream  athalianaTair10 {output.mut_fil}  > {output.eff}
'''
