#!/bin/bash

set -e # Exit script immediately on first error.
#set -x # Print commands and their arguments as they are executed.

DIR=$(cd $(dirname $0); pwd)

source "${DIR}/../.env"
source "${DIR}/.env.test"

# TODO: Drop DB if exists

createdb -U ${DBROLE} ${TESTDBNAME}
psql -U ${DBROLE} -d ${TESTDBNAME} -f "${DIR}/../sql/createTables.sql"
psql -U ${DBROLE} -d ${TESTDBNAME} -f "${DIR}/../sql/pgGeocoder.sql"
psql -U ${DBROLE} -d ${TESTDBNAME} -f "${DIR}/../sql/pgReverseGeocoder.sql"

psql -U ${DBROLE} -d ${TESTDBNAME} -c "COPY pggeocoder.address_t(todofuken, lat, lon, code) FROM '${DIR}/fixtures/address_t.csv' WITH CSV HEADER;"
psql -U ${DBROLE} -d ${TESTDBNAME} -c "COPY pggeocoder.address_s(todofuken, shikuchoson, lat, lon, code) FROM '${DIR}/fixtures/address_s.csv' WITH CSV HEADER;"
psql -U ${DBROLE} -d ${TESTDBNAME} -c "COPY pggeocoder.address_o(todofuken, shikuchoson, ooaza, lat, lon, code) FROM '${DIR}/fixtures/address_o.csv' WITH CSV HEADER;"

psql -U ${DBROLE} -d ${TESTDBNAME} -c "UPDATE pggeocoder.address_t SET geog = ST_SetSRID(ST_MakePoint(lon, lat), 4326)::GEOGRAPHY;"
psql -U ${DBROLE} -d ${TESTDBNAME} -c "UPDATE pggeocoder.address_s SET geog = ST_SetSRID(ST_MakePoint(lon, lat), 4326)::GEOGRAPHY;"
psql -U ${DBROLE} -d ${TESTDBNAME} -c "UPDATE pggeocoder.address_o SET geog = ST_SetSRID(ST_MakePoint(lon, lat), 4326)::GEOGRAPHY;"
psql -U ${DBROLE} -d ${TESTDBNAME} -c "UPDATE pggeocoder.address_o SET tr_ooaza = normalizeAddr(ooaza);"

psql -U ${DBROLE} -d ${TESTDBNAME} -f "${DIR}/../sql/maintTables.sql"