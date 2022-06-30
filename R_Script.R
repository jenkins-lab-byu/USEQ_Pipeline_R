cat("\n**LOADING PACKAGES**\n\n")
suppressPackageStartupMessages(library(minfi))
suppressPackageStartupMessages(library(glmnet))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(argparse))

## set up parser
parser = ArgumentParser(description='script to build sgr files for each chromosome using beta value .csv files')
parser$add_argument('--base_dir', type='character', help='full path to base directory where you would like USEQ_Prep directory and SGR files to be created')
parser$add_argument('--control_betas', type='character', help='full path to control beta values')
parser$add_argument('--treatment_betas', type='character', help='full path to treatment beta values')
parser$add_argument('--illumina_annotation', type='character', help='full path to Illumina annotation file')
parser$add_argument('--USEQ_Prep', type='character', help='full path to USEQ_Prep Folder')


args = parser$parse_args()

## get arguments
base_dir=args$base_dir
control_betas=args$control_betas
treatment_betas=args$treatment_betas
illumina_annotation=args$illumina_annotation
illumina_annotation=args$illumina_annotation
USEQ_Prep=args$USEQ_Prep

# Set directory where you want the USEQ_Prep directory and files to be put
path_to_my_dir <- base_dir
setwd(path_to_my_dir)
print(paste("Home Directory has been set to", path_to_my_dir, sep = " "))
path_to_USEQ_Prep <- USEQ_Prep

# Read Control Betas, Treatment Betas, and the desired annotation file (This one is EPIC)
print("Reading in Control Beta Values")
control <- read.csv(control_betas, row.names = 1,check.names = FALSE)
print("Reading in Treatment Beta Values")
treatment <- read.csv(treatment_betas,row.names = 1,check.names = FALSE)
print("Reading in Annotation File")
ann_EPIC <- read.csv(illumina_annotation,row.names = 1,check.names = FALSE)

# Merge Each File
print("Merging Annotation File")
print("Merging Control Betas File")
mydf <- merge(ann_EPIC,control,by=0)
rownames(mydf) <- mydf$Row.names
mydf$Row.names  <- NULL
print("Finished Merging Annotation File")
print("Finished Merging Control Betas File")
print("Merging Treatment Betas File")
mydf <- merge(mydf,treatment,by=0)
rownames(mydf) <- mydf$Row.names
mydf$Row.names  <- NULL
print("Finished Merging Treatment Betas File")
head(mydf[,c(1:10)])

# Create SGR files for the USEQ Pipeline

chr<-c("chr1","chr2","chr3","chr4","chr5","chr6","chr7","chr8","chr9","chr10","chr11","chr12","chr13","chr14","chr15","chr16","chr17","chr18","chr19","chr20","chr21","chr22","chrX","chrY")


# Something to try to improve this loop write.table(utms, file=paste(x, ".mean", sep=""))
# This should make it so that you don't need the extra directories that are made for each chromosome

print("Creating .sgr chromosomes files in USEQ_Prep folder for each sample")
count = 0
for(i in colnames(mydf)){
  count <- count + 1
  setwd(path_to_USEQ_Prep)
  dir.create(i)
  setwd(i)
  x<-mydf[,c("CHR","START",i)]
  print(paste("Creating .sgr chromosomes files for sample",count,"of",(length(colnames(mydf))),sep = " "))
  for(i in chr){
    c<-subset(x,CHR == i)
    colnames(c)<-NULL
    write.table(c,i,sep="\t",row.names=FALSE)}
  filez<-list.files()
  for(i in filez){
    file.rename(i,paste(i,".sgr",sep=""))}
}
print("Finished!")
