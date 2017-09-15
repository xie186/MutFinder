#color <- c(rgb(79,129,189,max = 255), rgb(192,80,77,max = 255), rgb(155,187,89,max = 255), rgb(128,100,162,max=255), rgb(75,172,198,max=255), rgb(247,150,70,max=255), rgb(44,77,117,max=255))
#class <- c("Coding", "IG", "Intron", "ncRNA", "pseudogene", "TE", "UTR") 
color <- c(rgb(79,129,189,max = 255), rgb(192,80,77,max = 255))
class <- c("Repress", "Activate")
library(hash)
h_col <- hash( keys=class, values=color )
draw_var_dis_geno<-function(var,
   			    ideo="/scratch/conte/x/xie186/data/ara/info_geno_len/TAIR10_chr_all.ideogram",
                            output
 		            ){
    pdf(output, width =6, height =4);
    ideo <-read.table(ideo)
    var <-read.table(var)
    tot_len<-sum(ideo[ideo[,2] != 0, ][,3])
    maxi<-max(ideo[ideo[,2] != 0, ][,3]);
    chr_num <- length(ideo[ideo[,2] != 0, ][,3]);
    par(lend=1)

    DIST <- 500000;
    UNIT <- 1000000;
    plot(1,type="n",xlim=c(0,maxi/UNIT),ylim=c(0,10),axes =F, xlab="Chromsome (Mb)", ylab="");
    axis(1, labels = T)

    height = 1.6
    for(i in levels(ideo[,1])){
        info <- ideo[ideo[,1] == i,];
        var_info <- var[var[,1] == i,];
        num<-2 * (as.numeric(substr(i,4,nchar(i))) - 1);
    
        #rect(xleft, ybottom, xright, ytop
	rect_col = rgb(79,129,189,max = 255)
        rect(info[1,2]/UNIT, num -0.1, (info[1,3]-DIST)/UNIT, num, col = rect_col, border="NA")
        xx<-c((info[1,3]-DIST)/UNIT, (info[1,3]-DIST)/UNIT,(info[1,3])/UNIT);
        yy<-c(num -0.1,num,num -0.05);
        polygon(xx, yy, col = rect_col, lty = 2, lwd = 2, border = "NA")
   
        rect((info[2,2] + DIST)/UNIT, num -0.1, (info[2,3])/UNIT, num, col = rect_col, border="NA")
        xx<-c((info[2,2] + DIST)/UNIT, (info[2,2] + DIST)/UNIT, (info[2,2])/UNIT);
        yy<-c(num -0.1,num,num -0.05);
        polygon(xx, yy, col = rect_col, lty = 2, lwd = 2, border = "NA")
        
        text(info[1,2]/UNIT -1 , num -0.05, adj=1, labels=i, xpd=T, cex=0.8)
        
        #x0, y0, x1 = x0, y1 = y0,
        segments(0, num + height/2, info[2,3]/UNIT, num + height/2 ,col= "gray", lty = "dashed")
        segments(0, num + height, info[2,3]/UNIT, num + height ,col= "gray")

        lines( (var_info[ ,2] + var_info[ ,3])/(UNIT*2),  num + var_info[ ,4] * height , col="royalblue" )

    }

    max_index <- which.max(var[,4]) 
    tem_chr <- var[max_index,] 
    pos <- 2 * (as.numeric(substr(tem_chr[1,1], 4, 5)) -1)
    print(max_index)
    print(pos)
    print(tem_chr)
    points((tem_chr[1, 2] + tem_chr[1, 3])/(UNIT*2), pos + tem_chr[1, 4] * height, pch = "*", lwd=10, col="darkred") 
    #legend(25,4,class, cex=0.7, col = color, pch=".",lty=1, ,lwd=2, bty = "n")

    dev.off()
}

Args <- commandArgs();
print("Useage: R --vanilla --slave --geno_info [genome information] --var_info [var func class] --out [output] < draw_var_dis_geno.R")
for (i in 1:length(Args)) {
    if (Args[i] == "--geno_info") geno_info = Args[i+1]
    if (Args[i] == "--var_info") var_info = Args[i+1]
    if (Args[i] == "--out") out = Args[i+1]
}
draw_var_dis_geno(var_info, geno_info, out)
