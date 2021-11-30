
#!/bin/bash

source .env

# Creating the necessary pgGeocoder Tables
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/createTables.sql

# Creating the necessary pgGeocoder Types
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/createTypes.sql

# Load geocoder function
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/pgGeocoder.sql

# Load reverse_geocoder function
psql -U ${DBROLE} -d ${DBNAME} -f ./sql/pgReverseGeocoder.sql

echo -e "\nDone!"
