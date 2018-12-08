plink2='/Users/gc5k/bin/plink_mac/plink'
dat="1kg_chr22"
K=200

pca=paste(plink2, "--bfile ", dat, " --extract snp.extract --pca ", K, " --out", dat)
system(pca)

snpCnt=nrow(read.table("snp.extract", as.is = T))
eTab=matrix(0, snpCnt, K+2)
for(i in 1:K) {
  egwas=paste0(plink2, " --allow-no-sex --extract snp.extract --linear --bfile ", dat, " --pheno ", dat, ".eigenvec --mpheno ", i, " --out ", dat, "_e")
  system(egwas)
  eRes=read.table(paste0(dat, "_e.assoc.linear"), as.is = T, header = T)
  eTab[,i+2] = format(scale(eRes$BETA), digits = 4)
}
eTab[,1]=eRes$SNP
eTab[,2]=eRes$A1
write.table(eTab, "1kg_PPSR.score", row.names = F, col.names = F, quote = F)

#