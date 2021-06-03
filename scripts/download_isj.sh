
#!/bin/bash

# Inspired by https://github.com/IMI-Tool-Project/imi-enrichment-address/blob/master/tools/download.sh

function exit_with_usage()
{
  echo "usage: bash scripts/download_isj.sh [位置参照情報のデータ整備年度 (例:R1 ※R1,H30~H21のいずれか)]" 1>&2
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

# 令和元年(2019) ~ 平成21年(2009)
# Don't support <= H20, because oaza level data is not completed
# "[era_year] [year] [oaza_ver] [gaiku_ver]"
YEAR_VERSIONS=(
  "R1  2019 13.0b 18.0a"
  "H30 2019 12.0b 17.0a"
  "H29 2017 11.0b 16.0a"
  "H28 2016 10.0b 15.0a"
  "H27 2015 9.0b 14.0a"
  "H26 2014 8.0b 13.0a"
  "H25 2013 7.0b 12.0a"
  "H24 2012 6.0b 11.0a"
  "H23 2011 5.0b  9.0a"
  "H22 2010 4.0b  8.0a"
  "H21 2009 3.0b  7.0a"
)

found=0
for i in "${YEAR_VERSIONS[@]}"; do
  year_ver=(`echo "${i}"`)
  if [ "$1" == "${year_ver[0]}" ]; then
    era_year="${year_ver[0]}"
    year="${year_ver[1]}"
    oaza_ver="${year_ver[2]}"
    gaiku_ver="${year_ver[3]}"
    found=1
    break
  fi
done

if ((!found)); then
  exit_with_usage
fi

echo "era_year:${era_year}, year:${year}, oaza_ver:${oaza_ver}, gaiku_ver:${gaiku_ver}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
OUT_ROOT_DIR=${SCRIPT_DIR}/../data/isj
OUT_YEAR_DIR=${OUT_ROOT_DIR}/${year}
OUT_OAZA_DIR=${OUT_YEAR_DIR}/oaza
OUT_GAIKU_DIR=${OUT_YEAR_DIR}/gaiku

mkdir -p ${OUT_YEAR_DIR}
mkdir -p ${OUT_OAZA_DIR}
mkdir -p ${OUT_GAIKU_DIR}

# Download zip files and extract only *.csv files
for pref_no in `seq -w 47` ; do
  oaza_url="https://nlftp.mlit.go.jp/isj/dls/data/${oaza_ver}/${pref_no}000-${oaza_ver}.zip"
  oaza_zip="${OUT_OAZA_DIR}/${pref_no}000-${oaza_ver}.zip"
  if [ ! -e "${oaza_zip}" ] ; then
    curl ${oaza_url} > ${oaza_zip}
  fi
  unzip -j ${oaza_zip} '*.[cC][sS][vV]' -d ${OUT_OAZA_DIR}

  gaiku_url="https://nlftp.mlit.go.jp/isj/dls/data/${gaiku_ver}/${pref_no}000-${gaiku_ver}.zip"
  gaiku_zip="${OUT_GAIKU_DIR}/${pref_no}000-${gaiku_ver}.zip"
  if [ ! -e "${gaiku_zip}" ] ; then
    curl ${gaiku_url} > ${gaiku_zip}
  fi
  unzip -j ${gaiku_zip} '*.[cC][sS][vV]' -d ${OUT_GAIKU_DIR}
done

echo "Completed!"
