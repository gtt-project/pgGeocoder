
#!/bin/bash

# Inspired by https://github.com/IMI-Tool-Project/imi-enrichment-address/blob/master/tools/download.sh

# 2019(令和元年) ~ 2009(平成21年)
# Don't support <= H20, because oaza level data is not completed
# "[year] [era_year] [oaza_ver] [gaiku_ver]"
YEAR_VERSIONS=(
  "2019 R1  13.0b 18.0a"
  "2018 H30 12.0b 17.0a"
  "2017 H29 11.0b 16.0a"
  "2016 H28 10.0b 15.0a"
  "2015 H27 9.0b 14.0a"
  "2014 H26 8.0b 13.0a"
  "2013 H25 7.0b 12.0a"
  "2012 H24 6.0b 11.0a"
  "2011 H23 5.0b  9.0a"
  "2010 H22 4.0b  8.0a"
  "2009 H21 3.0b  7.0a"
)

function exit_with_usage()
{
  echo "Usage: bash scripts/download_isj.sh [Year (ex. 2019)]" 1>&2
  for i in "${YEAR_VERSIONS[@]}"; do
    year_ver=(`echo "${i}"`)
    year="${year_ver[0]}"
    era_year="${year_ver[1]}"
    echo -e "\t${era_year}: ${year}" 1>&2
  done
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

found=0
for i in "${YEAR_VERSIONS[@]}"; do
  year_ver=(`echo "${i}"`)
  if [ "$1" == "${year_ver[0]}" ]; then
    year="${year_ver[0]}"
    era_year="${year_ver[1]}"
    oaza_ver="${year_ver[2]}"
    gaiku_ver="${year_ver[3]}"
    found=1
    break
  fi
done

if ((!found)); then
  exit_with_usage
fi

echo "year:${year}, era_year:${era_year}, oaza_ver:${oaza_ver}, gaiku_ver:${gaiku_ver}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
OUT_ROOT_DIR=${SCRIPT_DIR}/../data/isj
OUT_YEAR_DIR=${OUT_ROOT_DIR}/${year}

OUT_OAZA_DIR=${OUT_YEAR_DIR}/oaza
OUT_OAZA_ZIP_DIR=${OUT_OAZA_DIR}/zip
OUT_OAZA_CSV_DIR=${OUT_OAZA_DIR}/csv

OUT_GAIKU_DIR=${OUT_YEAR_DIR}/gaiku
OUT_GAIKU_ZIP_DIR=${OUT_GAIKU_DIR}/zip
OUT_GAIKU_CSV_DIR=${OUT_GAIKU_DIR}/csv

mkdir -p ${OUT_YEAR_DIR}

mkdir -p ${OUT_OAZA_DIR}
mkdir -p ${OUT_OAZA_ZIP_DIR}
mkdir -p ${OUT_OAZA_CSV_DIR}

mkdir -p ${OUT_GAIKU_DIR}
mkdir -p ${OUT_GAIKU_ZIP_DIR}
mkdir -p ${OUT_GAIKU_CSV_DIR}

# Download zip files and extract *.csv files
for pref_code in `seq -w 1 47` ; do
  oaza_url="https://nlftp.mlit.go.jp/isj/dls/data/${oaza_ver}/${pref_code}000-${oaza_ver}.zip"
  oaza_zip="${OUT_OAZA_ZIP_DIR}/${pref_code}000-${oaza_ver}.zip"
  if [ ! -e "${oaza_zip}" ] ; then
    curl ${oaza_url} > ${oaza_zip}
  fi
  unzip -j ${oaza_zip} '*.[cC][sS][vV]' -d ${OUT_OAZA_CSV_DIR}

  gaiku_url="https://nlftp.mlit.go.jp/isj/dls/data/${gaiku_ver}/${pref_code}000-${gaiku_ver}.zip"
  gaiku_zip="${OUT_GAIKU_ZIP_DIR}/${pref_code}000-${gaiku_ver}.zip"
  if [ ! -e "${gaiku_zip}" ] ; then
    curl ${gaiku_url} > ${gaiku_zip}
  fi
  unzip -jo ${gaiku_zip} '*.[cC][sS][vV]' -d ${OUT_GAIKU_CSV_DIR}
done

echo -e "\nDone!"
