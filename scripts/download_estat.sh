#!/bin/bash
# ------------------------------------------------------------------------------
# Copyright(c) 2013-2021 Georepublic
#
# Usage:
# ------
#	./download_estat.sh [Census Year]
#
# Examples:
# ---------
#	./download.sh A002005212015
#	./download.sh A002005212010
#	./download.sh A002005212005
#	./download.sh A002005512000
#
# ------------------------------------------------------------------------------

set -e # Exit script immediately on first error.
#set -x # Print commands and their arguments as they are executed.


TCODE=${1:-"A002005212015"}
mkdir -p "${TCODE}"

URL="https://www.e-stat.go.jp/gis/statmap-search/data"

# Download 47 prefecture shapes
for i in $(seq -f "%02g" 1 47); do
  # echo "Downloading prefecture ${i} in ${TCODE} ..."
  LINK="${URL}?dlserveyId=${TCODE}&code=${i}&coordSys=1&format=shape&downloadType=5"
  FILE="${TCODE}/pref_${i}.zip"
  wget -O "${FILE}" "${LINK}"
  sleep 5
done

# Unzip SHP files
echo "============================================================="
echo "Unzipping SHP files "

DATA=`find ./${TCODE}/ -name '*.zip'`

counter=0
for i in $DATA
do
	unzip -q -o -d ${TCODE}/shp $i
	let counter=counter+1
	echo -ne "."
done

echo -e "\nDone: ${counter} SHP files unzipped!"

# Merge SHP files
echo "============================================================="
echo "Merging SHP files"

DATA=`find ./${TCODE}/shp -name '*.shp'`
FILE="./${TCODE}/japan.shp"
rm -f "./${TCODE}/japan.*"

counter=0
for i in $DATA
do
	export SHAPE_ENCODING="UTF-8"

	if [ -f ${FILE} ]
	then
		ogr2ogr -f "ESRI Shapefile" -update -append ${FILE} "${i}"
	else
		ogr2ogr -f "ESRI Shapefile" ${FILE} "${i}" -t_srs EPSG:4326 -lco ENCODING=SJIS
	fi

	echo -ne "."
	let counter=counter+1
done

echo -e "\nDone: ${counter} SHP files merged!"
echo "============================================================="
