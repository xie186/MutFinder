#!/usr/bin/perl -w
use strict;

die usage() unless @ARGV == 3; 
sub usage{
    my $die =<<DIE;
perl *.pl <gatk vcf> <wt> <mut> 
DIE
}
my ($gatk, $wt, $mut) = @ARGV;
open GATK, $gatk or die "$!";
my %rec_snp;
my %rec_pos;
my ($index_wt, $index_mut) = ("NA", "NA");
while(<GATK>){
    chomp;
    next if /^##/;
    if(/#CHROM/){
        ($index_wt, $index_mut) = &proc_header($_);
        #print "$index_wt, $index_mut\n";
    }else{
        &proc_geno($_);
    }
}

foreach my $chr(keys %rec_snp){
    my @snp = @{$rec_snp{$chr}};
    my $num = @snp;
    for(my $i = 0; $i < $num - 4; ++$i){
        my $mid = (${$rec_pos{$chr}}[$i] + ${$rec_pos{$chr}}[$i+4])/2;
        my $aver = ($snp[$i] + $snp[$i+1] + $snp[$i + 2] + $snp[$i + 3] + $snp[$i + 4])/5;
        print "$chr\t${$rec_pos{$chr}}[$i]\t${$rec_pos{$chr}}[$i+4]\t$aver\n";
    }
}

sub proc_geno{
    my ($geno) = @_;
    my @sample = split(/\t/, $geno);
    my ($chr,$pos,$id,$ref,$alt,$qual,$filter,$info, $format) = split(/\t/, $geno);
    my ($base_wt, $base_mut) = ($ref, $alt);
    my ($geno_wt, $geno_mut) = @sample[$index_wt, $index_mut];
    #print "SUB:$index_wt, $index_mut\t$geno_wt, $geno_mut\n";
    #GT:AD:DP:GQ:PL
    if($geno_wt =~ /0\/0/ && $geno_mut !~ /0\/0/ && $geno_mut !~ /\.\/\./){
    #if($geno_wt =~ /0\/0/ &&  $geno_mut !~ /\.\/\./){
        if(($base_wt eq "C" && $base_mut eq "T") || ($base_wt eq "G" && $base_mut eq "A")){
            my ($ref_gt, $ref_ad) = split(/:/, $geno_wt);
            my ($ref_num_wt, $ref_num_mut) = split(/,/, $ref_ad);
            if($ref_num_mut == 0 && $ref_num_wt + $ref_num_mut >=10){
                my ($gt, $ad) = split(/:/, $geno_mut);
                my ($num_wt, $num_mut) = split(/,/, $ad);
                ## GT:AD:DP:GQ:PL	1/1:.:.:3:45,3,0	0/0:37,0:37:99:0,114,2348
                ## In this example, the genotype is given as 1/1, but the AD is give as .
                ## This will lead error. This is why we use $ad ne '.'
                if($ad ne '.' && $num_wt + $num_mut > 0 && $num_mut/($num_wt + $num_mut) > 0.3){ #we excluded SNPs with SNP-index of <0.3 from the analysis as they may represent spurious SNPs called due to sequencing and/or alignment errors.
                    push @{$rec_snp{$chr}}, $num_mut/($num_wt + $num_mut);
                    push @{$rec_pos{$chr}}, $pos;
                    #print "$chr\t$pos\t$ref\t$alt\t$geno_wt\t$geno_mut\n";
                }
            }
        }
    }
}

sub proc_header{
    my ($header) = @_;
    #CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO    FORMAT  CZZ013  CZZ014
    my @ele = split(/\t/, $header);
    my ($index_wt, $index_mut) = ("NA", "NA");
    for(my $i = 0; $i < @ele; ++$i){
        if($ele[$i] eq "$wt"){
            $index_wt = $i;
        }
        if($ele[$i] eq "$mut"){
            $index_mut = $i;
        }
    }
    return ($index_wt, $index_mut);
}
