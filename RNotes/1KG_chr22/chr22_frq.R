plink2='/Users/gc5k/bin/plink_mac/plink'
gear='java -jar /Users/gc5k/Documents/workspace/FromSVN/GEAR/gear.jar'
pop=read.table("pop.txt", as.is=T, header=T)

for(i in 1:nrow(pop)) {
  frq=paste0(plink2, " --bfile 1kg_chr22 --allow-no-sex --freq --keep ", pop[i,1], " --out ", unlist(strsplit(pop[i,1], ".txt"))[1], "_22")
  print(frq)
  system(frq)
}

fList=dir(pattern="*.frq$")
write.table(fList, "1kg_frq.txt", row.names = F, col.names = F, quote = F)

mpc=paste0(gear, " mpc --meta-batch 1kg_frq.txt --out 1kg_frq")
system(mpc)

mval=read.table("1kg_frq.mval", as.is = T)
barplot(mval[,1])

mvec=read.table("1kg_frq.mvec", as.is = T)
plot(mvec[,1], mvec[,2], bty='n', xlab="mPC 1", ylab="mPC 2", col="grey", pch=16)
idxCEU=which(pop == "CEU.txt")
points(mvec[idxCEU,1], mvec[idxCEU,2], col="green", pch=1, cex=2, lwd=2)

idxCHB=which(pop == "CHB.txt")
points(mvec[idxCHB,1], mvec[idxCHB,2], col="gold", pch=1, cex=2, lwd=2)

idxYRI=which(pop == "YRI.txt")
points(mvec[idxYRI,1], mvec[idxYRI,2], col="black", pch=1, cex=2, lwd=2)
