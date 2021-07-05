#!/bin/bash
# ------------------------------------------------------------------------------
# Copyright(c) 2021 Georepublic
#
# Usage:
# ------
#  bash scripts/download_ksj.sh [Year]
#
# Examples:
# ---------
#  bash scripts/download_ksj.sh 2021
#
# ------------------------------------------------------------------------------

#set -e # Exit script immediately on first error.
#set -x # Print commands and their arguments as they are executed.

YEAR_FNAMES=(
  "2021 N03-20210101"
  "2020 N03-20200101"
  "2019 N03-190101"
  "2018 N03-180101"
  "2017 N03-170101"
  "2016 N03-160101"
)

function exit_with_usage()
{
  echo "Usage: bash scripts/download_ksj.sh [Year (ex. 2021)]" 1>&2
  for i in "${YEAR_FNAMES[@]}"; do
    year_fname=(`echo "${i}"`)
    year="${year_fname[0]}"
    echo -e "\t${year}" 1>&2
  done
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

found=0
for i in "${YEAR_FNAMES[@]}"; do
  year_fname=(`echo "${i}"`)
  if [ "$1" == "${year_fname[0]}" ]; then
    year="${year_fname[0]}"
    fname="${year_fname[1]}"
    found=1
    break
  fi
done

if ((!found)); then
  exit_with_usage
fi

echo "year:${year}, fname:${fname}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
OUT_ROOT_DIR=${SCRIPT_DIR}/../data/ksj
OUT_YEAR_DIR=${OUT_ROOT_DIR}/${year}
OUT_ZIP_DIR=${OUT_YEAR_DIR}/zip
OUT_SHP_DIR=${OUT_YEAR_DIR}/shp
OUT_SQL_DIR=${OUT_YEAR_DIR}/sql

mkdir -p ${OUT_YEAR_DIR}
mkdir -p ${OUT_ZIP_DIR}
mkdir -p ${OUT_SHP_DIR}
mkdir -p ${OUT_SQL_DIR}

# Download zip
# echo "Downloading data in ${year} ..."
url="https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-${year}/${fname}_GML.zip"
zip="${OUT_ZIP_DIR}/${fname}_GML.zip"
if [ ! -e "${zip}" ] ; then
  curl -s "${url}" > "${zip}"
fi
unzip -qq -jo ${zip} -d ${OUT_SHP_DIR}

# Generate SQL file
#for shp in `find ${OUT_SHP_DIR} -name '*.shp'`; do
for shp in ${OUT_SHP_DIR}/*.shp; do
  sql=${OUT_SQL_DIR}/`basename ${shp} .shp`.sql
  #echo "${shp} => ${sql}"
  # ogrinfo --format PGDump
  ogr2ogr -s_srs EPSG:4612 \
          -t_srs EPSG:4326 \
          -f PGDump \
          ${sql} \
          ${shp} \
          -lco GEOM_TYPE=geometry \
          -lco GEOMETRY_NAME=geom \
          -lco FID=fid \
          -lco SCHEMA=ksj \
          -lco CREATE_SCHEMA=YES \
          -lco CREATE_TABLE=YES \
          -lco DROP_TABLE=IF_EXISTS \
          -nln ksj.admin_boundary
done

echo -e "\nDone: 1 SQL file generated!"
