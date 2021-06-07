
#!/bin/bash

source .env

# Create basic tables
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/createTables.sql

# Load geocoder function
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/pgGeocoder.sql

# Load reverse_geocoder function
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/pgReverseGeocoder.sql

echo -e "\nDone!"
