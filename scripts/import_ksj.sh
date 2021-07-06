
#!/bin/bash

source .env

function exit_with_usage()
{
  echo "Usage: bash scripts/import_ksj.sh [Year (ex. 2021)]" 1>&2
  exit 1
}

if [ $# -ne 1 ]; then
  exit_with_usage
fi

year="$1"
echo "year:${year}"

SCRIPT_DIR=$(cd $(dirname $0); pwd)
IN_ROOT_DIR=${SCRIPT_DIR}/../data/ksj
IN_YEAR_DIR=${IN_ROOT_DIR}/${year}

IN_SHP_DIR=${IN_YEAR_DIR}/shp
IN_SQL_DIR=${IN_YEAR_DIR}/sql

if [ ! -d ${IN_SHP_DIR} ] || [ ! -d ${IN_SQL_DIR} ]; then
  echo "SHP file is not downloaded yet" 1>&2
  exit 2
fi

# Drop ksj tables and schema once
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/ksj/dropKSJTables.sql

# Import sql file
echo "Import sql file"
for sql in ${IN_SQL_DIR}/*.sql ; do
  psql -U ${DBROLE} -d ${DBNAME} -q -f ${sql}
done

# Convert KSJ datas to pgGeocoder boundary_s|t table
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/ksj/convertKSJDatas.sql

echo -e "\nDone!"
