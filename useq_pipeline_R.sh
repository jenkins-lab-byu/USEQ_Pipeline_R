### Paths to necessary files for USEQ Analysis

# Path to base directory where you want your USEQ files to be created. Don't forget to add a "/" at the end as we want the files to be created inside this directory.
base_dir="/Volumes/Research_Data/USEQ_Analyses/Completed_Studies/Low_Income_vs_High_Income_FASZT/"

# Path to Control Beta values (Make sure it is a .csv file CG's are in the rows and sample names are in the columns)
control_betas="/Volumes/Research_Data/USEQ_Analyses/Completed_Studies/Low_Income_vs_High_Income_FASZT/under_40k_betas.csv"

# Path to Treatment Beta values (Make sure it is a .csv file and that CG's are in the rows and sample names are in the columns)
treatment_betas="/Volumes/Research_Data/USEQ_Analyses/Completed_Studies/Low_Income_vs_High_Income_FASZT/over_100k_betas.csv"

# Path to Treatment Beta values (Make sure it is a .csv file and that CG's are in the rows and that CHR and START are in the columns)
illumina_annotation="/Volumes/Research_Data/My_Github/USEQ-Pipeline/Annotation_Files/EPIC_array_annotation.csv"

# Path to useq_prep_r.R script (This file can be downloaded from this github link: )
sgr_script="/Volumes/Research_Data/My_Github/USEQ-Pipeline/R_Script.R"

# Path to Sgr2Bar program
Sgr2Bar="/Volumes/Research_Data/My_Github/USEQ-Pipeline/USeq_9.3.3/Apps/Sgr2Bar"

# Path to MethylationArrayScanner program
MethylationArrayScanner="/Volumes/Research_Data/My_Github/USEQ-Pipeline/USeq_9.3.3/Apps/MethylationArrayScanner"

# Path to EnrichedRegionMaker program
EnrichedRegionMaker="/Volumes/Research_Data/My_Github/USEQ-Pipeline/USeq_9.3.3/Apps/EnrichedRegionMaker"

# Path to Control group names (Must be comma delimited with no spaces)
Control_Samples=X10879,X11303,X20058,X20100,X20130,X50135,X10002,X10005,X10030,X10037,X10043,X10050,X10057,X10075,X10076,X10125,X10141,X10142,X10145,X10154,X10182,X10191,X10199,X10200,X10230,X10241,X10242,X10262,X10265,X10266,X10283,X10306,X10315,X10316,X10321,X10334,X10346,X10354,X10368,X10375,X10396,X10399,X10410,X10420,X10423,X10432,X10450,X10451,X10468,X10503,X10510,X10511,X10533,X10548,X10586,X10602,X10610,X10613,X10671,X10702,X10720,X10762,X10766,X10854,X10857,X10951,X10977,X10980,X11005,X11010,X11026,X11068,X11093,X11128,X11132,X11136,X11197,X11200,X11207,X11210,X11235,X11236,X11247,X11260,X11263,X11278,X11284,X11312,X11358,X11456,X11459,X11460,X11467,X11489,X11490,X11492,X11495,X20003,X20004,X20005

# Path to Testing group names (Must be comma delimited with no spaces)
Treatment_Samples=X10124,X10526,X10990,X20055,X30266,X30267,X70032,X10007,X10010,X10011,X10014,X10017,X10020,X10031,X10034,X10038,X10045,X10055,X10071,X10079,X10080,X10086,X10093,X10097,X10100,X10113,X10118,X10131,X10137,X10148,X10151,X10152,X10158,X10161,X10163,X10169,X10185,X10206,X10209,X10225,X10226,X10240,X10244,X10247,X10248,X10255,X10258,X10263,X10273,X10278,X10288,X10291,X10292,X10293,X10322,X10324,X10325,X10327,X10330,X10350,X10363,X10367,X10409,X10416,X10424,X10430,X10441,X10442,X10444,X10446,X10455,X10458,X10463,X10486,X10487,X10514,X10518,X10529,X10541,X10545,X10551,X10565,X10572,X10614,X10616,X10625,X10632,X10637,X10645,X10647,X10662,X10663,X10664,X10668,X10672,X10674,X10681,X10684,X10713,X10721



###########
## Creating USEQ Directories ##
###########
echo ""
echo "**** Creating USEQ Directories ****"
echo ""

# Change to USEQ_prep directory
cd $base_dir
mkdir USEQ_Prep
mkdir USEQ_Results_Forward
mkdir USEQ_Results_Reverse
USEQ_Prep="${base_dir}/USEQ_Prep/"
cd $USEQ_Prep

###########
## Creating SGR Files ##
###########
echo ""
echo "**** Running R-Script and Creating SGR Files ****"
echo ""

# Rscript $sgr_script --base_dir $base_dir --control_betas $control_betas --treatment_betas $treatment_betas --illumina_annotation $illumina_annotation --USEQ_Prep $USEQ_Prep

###########
## Converting SGR Files to Bar Files ##
###########
echo ""
echo "**** Converting SGR Files to Bar Files ****"
echo ""

# Convert .sgr files to .bar files
for d in ./*/ ; do (java -jar $Sgr2Bar -f $USEQ_Prep${d} -v H_Sapiens_Feb_2009); done

###########
## Removing SGR files ##
###########
echo ""
echo "**** Removing SGR files ****"
echo ""

# Remove .sgr files
for d in ./*/ ; do (cd "$d" && rm *.sgr); done


###########
## Removing Leftover Subdirectories ##
###########
echo ""
echo "**** Removing Leftover Subdirectories ****"
echo ""

# Move any file in the sub directory and place it into the working directory
for d in ./*/ ; do (cd "$d" && find . -mindepth 2 -type f -print -exec mv {} . \;); done

# Remove subdirectories
for d in ./*/ ; do (cd "$d" && rm -R -- */); done


###########
## Running Sliding Window Analysis Forward ##
###########
echo ""
echo "**** Running Sliding Window Analysis Forward ****"
echo ""

#Sliding Window Analysis
java -jar $MethylationArrayScanner -s ../USEQ_Results_Forward -d $USEQ_Prep -c $Control_Samples -t $Treatment_Samples -n

###########
## Creating Output Using Enriched Region Maker App ##
###########
echo ""
echo "**** Creating Forward Output Using Enriched Region Maker App ****"
echo ""

#Creating output using enriched region maker app
java -jar $EnrichedRegionMaker -f ../USEQ_Results_Forward/windowData1000bp0.2MinPse.swi -i 0,1 -s 0.2,10


###########
## Running Sliding Window Analysis Reverse ##
###########
echo ""
echo "**** Running Sliding Window Analysis Reverse ****"
echo ""

java -jar $MethylationArrayScanner -s ../USEQ_Results_Reverse -d $USEQ_Prep -t $Control_Samples -c $Treatment_Samples -n


###########
## Creating Output Using Enriched Region Maker App ##
###########
echo ""
echo "**** Creating Reverse Output Using Enriched Region Maker App ****"
echo ""

#Creating output using enriched region maker app
java -jar $EnrichedRegionMaker -f ../USEQ_Results_Reverse/windowData1000bp0.2MinPse.swi -i 0,1 -s 0.2,10
echo "Finished!"