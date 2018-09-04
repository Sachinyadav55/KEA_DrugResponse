#!/bin/bash
# DrugResponse_sample_test_multi.sh: Example of piping DrugResponse package to test cancer samples
# Input: folder with multiple samples
# Usage:
# DrugResponse_sample_test_URL.sh path.to.folder

E_FILE_NOT_EXIST=70
E_DOWNLOAD_FAIL=71
E_MV_FAIL=72
E_UNZIP_FAIL=73
E_TEST_FAIL=74

INPUT=$1
DATAPATH='../data_fix'

echo "Download CEL file from NCBI"

var1=$(sed 's/.\{3\}$//' <<< "$INPUT")
URLIN="ftp://ftp.ncbi.nih.gov/geo/series/"$var1"nnn/"$INPUT"/suppl/"$INPUT"_RAW.tar"

if wget $URLIN; then
echo "Download successful"
else
echo "Fail to download"
exit $E_DOWNLOAD_FAIL
fi

if tar -xvf $INPUT"_RAW.tar"; then
echo "unzip successful"
else
echo "Fail to unzip"
exit $E_UNZIP_FAIL
fi

if gunzip *gz; then
echo "unzip successful"
else
echo "Fail to unzip"
exit $E_UNZIP_FAIL
fi

#temp=$INPUT"*CEL"
#echo $temp
#CEL_FILES=(*CEL)

mkdir mtemp

for i in *.[Cc][Ee][Ll]
do
#IFS='.' read -a array <<< "$i"
#echo $i
mv $i mtemp
if R -q -e "library(DrugResponse);library(affy);DrugResponse.predict('temp','cel','$i','$DATAPATH')"; then
echo "test for $i successful"
else
echo "Fail to process cel files"
rm -r mtemp
rm GSM*
rm *tar
rm *_tp.txt
exit $E_TEST_FAIL
fi
mv mtemp/$i .
done

#paste -d',' *_tp.txt > $INPUT"_exp_N.csv"

rm -r mtemp
rm GSM*
rm *tar
rm *_tp.txt
echo "done"
exit 0
