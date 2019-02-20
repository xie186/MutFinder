#!/usr/bin/perl -w
use strict;

die usage() unless @ARGV == 4; 
sub usage{
    my $die =<<DIE;
perl *.pl <gatk vcf> <wt> <mut> <snp_index>
DIE
}
my ($gatk, $wt, $mut, $snp_index) = @ARGV;


my $win = 2000000;
open INDEX, $snp_index or die "$!";
my ($mut_chr, $mut_stt, $mut_end, $max) = (0,0,0,0);
while(<INDEX>){
    chomp;
    my ($chr, $stt,$end, $value) = split;
    if($max < $value){
	($mut_chr, $mut_stt, $mut_end, $max) = ($chr, $stt - $win, $end + $win, $value);
    }
}

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

sub proc_geno{
    my ($geno) = @_;
    my @sample = split(/\t/, $geno);
    my ($chr, $pos, $id, $ref, $alt, $qual, $filter, $info, $format) = split(/\t/, $geno);
    #if($mut_chr eq $chr && $pos >= $mut_stt && $pos <= $mut_end){
        my ($geno_wt, $geno_mut) = @sample[$index_wt, $index_mut];
        my ($base_wt, $base_mut) = ($ref, $alt);
        if(( ($geno_wt =~ /1\/1/ || $geno_wt =~ /0\/1/)  && $geno_mut =~ /0\/0/) || ($geno_wt =~ /0\/0/ && ($geno_mut =~ /1\/1/ || $geno_mut =~ /0\/1/)) ){
            #print "SUB:$index_wt, $index_mut\t$geno_wt, $geno_mut\n";
            if ( ($geno_wt =~ /1\/1/ || $geno_wt =~ /0\/1/) && $geno_mut =~ /0\/0/){
                ($base_wt, $base_mut) = ($alt, $ref);
            }
            if(($base_wt eq "C" && $base_mut eq "T") || ($base_wt eq "G" && $base_mut eq "A")){
                my ($gt, $ad) = split(/:/, $geno_mut);
                my ($num_wt, $num_mut) = split(/,/, $ad);
                print "$chr\t$pos\t$id\t$ref\t$alt\t$qual\t$filter\t$info\t$geno_wt\t$geno_mut\n";
            }
        }
    #}
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
