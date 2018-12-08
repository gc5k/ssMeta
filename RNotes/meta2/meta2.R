gear='java -jar /Users/gc5k/Documents/workspace/FromSVN/GEAR/gear.jar'
CurDir=getwd()

###1 Generate nss
Dir=list.dirs()
Dir=Dir[-1]
for(i in 1:length(Dir)) {
  setwd(Dir[i])
  bed=list.files(pattern = ".bed")
  datIn=strsplit(bed, ".bed")[[1]]
  datOut = paste0(datIn, "_ht")
  phe=list.files(pattern = ".phe")
  covar=list.files(pattern = ".covar")

  nss=paste(gear, " nss --bfile ", datIn, 
            " --pheno ", phe, " --mpheno 1 ",
            " --covar ", covar, " --covar-number 1 2 3 4 5",
            " --out ", datOut)
  print(nss)
  system(nss)
  setwd(CurDir) #return back
}

###ppsr
mspower=paste(gear, " mwpower --reg 0.95 --alpha 0.01 --beta 0.05 --test 250000 --out mw")
system(mspower)
#ref_A.frq is the reference allele calcuated in Oxford
ms1=paste(gear, " mwscore --bfile ./Oxford/Oxford500 --encode mw.encode --refallele ref_A.frq --out Oxford500")
system(ms1)
ms2=paste(gear, " mwscore --bfile ./Edinburgh/Edinburgh500 --encode mw.encode --refallele ref_A.frq --out Edinburgh500")
system(ms2)

ov=paste(gear, " mw --verbose --set1 Oxford500.profile --set2 Edinburgh500.profile --encode mw.encode --out overlap")
system(ov)
ovScore=read.table("overlap.mw", as.is = T)
hist(ovScore$V5, main="PPSR regression", xlab="Relatedness", breaks = 25)


###2 projected pc
pp1kg=paste(gear, " profile --bfile ../1KG_chr22/1kg_chr22 --score ../1KG_chr22/1kg_PPSR.score --out 1kg")
system(pp1kg)
ppOx=paste(gear, " profile --bfile Oxford/Oxford500 --score ../1KG_chr22/1kg_PPSR.score --out Oxford500")
system(ppOx)
ppEd=paste(gear, " profile --bfile Edinburgh/Edinburgh500 --score ../1KG_chr22/1kg_PPSR.score --out Edinburgh500")
system(ppEd)

refPC=read.table("1kg.profile", as.is = T, header = T)
oxPC=read.table("Oxford500.profile", as.is = T, header = T)
edPC=read.table("Edinburgh500.profile", as.is = T, header = T)
plot(refPC[,3], refPC[,4], col="grey", pch=16, cex=0.5, bty='n', xlab="E 1", ylab="E 2")
points(oxPC[,3], oxPC[,4], col="red", pch=16, cex=0.5)
points(edPC[,3], edPC[,4], col="green", pch=16, cex=1)
legend("topright", legend = c("Ox", "Ed"), col=c("red", "green"), pch=16, cex=0.5, bty ='n')
#a red point in the middle

###metapca
mpc=paste(gear, "mpc --meta-batch mpc.txt --out mpc")
system(mpc)
layout(matrix(1:2, 1, 2))
mval=read.table("mpc.mval", as.is = T)
barplot(mval[,1], border = F)
mvec=read.table("mpc.mvec", as.is = T)
plot(mvec[,1], mvec[,2], bty='n', xlab="mpc 1", ylab="mpc 2", pch=16)

###oath
Dir=list.dirs()
Dir=Dir[-1]
#parameter [need further automation]
Dat=c("Edinburgh500", "Oxford500")
Size=c(500, 500)
model=c("1", "2","3")
model_code="1_2_3"
for(i in 1:length(Dir)) {
  setwd(Dir[i])
  oath=paste0(gear, " oath --cm ", Dat[i], "_ht.m.nss ",
            " --nss-gz-batch ", Dat[i], "_ht.list.nss ",
            " -n ", Size[i],
            " --keep-nss ", paste(model, collapse = " "),
            " --out ", Dat[i], "_", paste(model, collapse = "_"))
  print(oath)
  system(oath)
  setwd(CurDir) #return back
}

##LambdaMeta
#make lambdaMeta.batch file, lambdaMeta_size.txt
lam=paste(gear, " lam --verbose --meta-gz-batch lambdaMeta.batch --qt-size lambdaMeta_size.txt --out tt")
system(lam)
lam_chi=read.table(gzfile("tt.1-2.lam.gz"), as.is = T, header = T)
plot(lam_chi$ChiExp, lam_chi$ChiObs.beta., xlab="Theoretical chisq", ylab="Observed chisq", bty='n', pch=16, cex=0.5)
abline(a=0, b=1, lty=2, col="red")
metaGC=lam_chi$ChiObs.beta.[ceiling(nrow(lam_chi)/2)]/lam_chi$ChiExp[ceiling(nrow(lam_chi)/2)]
legend("topleft", legend = paste0("metaGC=", format(metaGC, digits = 4)), pch=1, col="white", bty='n')

##GWAMA
gwama=paste(gear, " gmeta --keep-atgc --meta-gz-batch lambdaMeta.batch --qt-size lambdaMeta_size.txt --out tt")
system(gwama)
