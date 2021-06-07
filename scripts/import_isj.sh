
#!/bin/bash

source .env

function exit_with_usage()
{
  echo "Usage: bash scripts/import_isj.sh [Year (ex. 2019)]" 1>&2
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

year="$1"
echo "year:${year}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
IN_ROOT_DIR=${SCRIPT_DIR}/../data/isj
IN_YEAR_DIR=${IN_ROOT_DIR}/${year}

IN_OAZA_DIR=${IN_YEAR_DIR}/oaza
IN_OAZA_CSV_DIR=${IN_OAZA_DIR}/csv

IN_GAIKU_DIR=${IN_YEAR_DIR}/gaiku
IN_GAIKU_CSV_DIR=${IN_GAIKU_DIR}/csv

if [ ! -d ${IN_OAZA_CSV_DIR} ] || [ ! -d ${IN_GAIKU_CSV_DIR} ]; then
  echo "CSV files are not downloaded yet" 1>&2
  exit 2
fi

# Drop isj tables and schema once
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/isj/dropISJTables.sql

# Create isj schema and tables
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/isj/createISJTables.sql


OAZA_TABLE="isj.oaza"
GAIKU_TABLE="isj.gaiku"
if ((year > 2016)); then
  GAIKU_TABLE="isj.gaiku_with_koaza"
fi

# Import oaza csv files
echo "Import oaza csv files"
for csv in ${IN_OAZA_CSV_DIR}/*.csv ; do
  psql -U ${DBROLE} -d ${DBNAME} -c "\copy ${OAZA_TABLE} from '${csv}' with delimiter ',' csv header;"
done

# Import gaiku csv files
echo "Import gaiku csv files"
for csv in ${IN_GAIKU_CSV_DIR}/*.csv ; do
  psql -U ${DBROLE} -d ${DBNAME} -c "\copy ${GAIKU_TABLE} from '${csv}' with delimiter ',' csv header;"
done

# Convert ISJ datas to pgGeocoder address tables
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/isj/convertISJDatas.sql

# Run the maintTables.sql to create proper indexes to the pgGeocoder Tables
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/maintTables.sql

# Load geocoder function
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/pgGeocoder.sql

# Load reverse_geocoder function
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/pgReverseGeocoder.sql

# Normalize oaza data
psql -U ${DBROLE} -d ${DBNAME} -c "update address_o set tr_ooaza = normalizeAddr(ooaza);"

echo -e "\nDone!"
