--
-- Adding geometry column to temporary Gaiku/Oaza tables
--
alter table isj.gaiku add column geom geometry('POINT', 4326);
update isj.gaiku set geom = st_setsrid(st_makepoint(lon, lat), 4326);
create index gaiku_geom_idx on isj.gaiku using gist(geom);

alter table isj.gaiku_with_koaza add column geom geometry('POINT', 4326);
update isj.gaiku_with_koaza set geom = st_setsrid(st_makepoint(lon, lat), 4326);
create index gaiku_with_koaza_geom_idx on isj.gaiku_with_koaza using gist(geom);

alter table isj.oaza add column geom geometry('POINT', 4326);
update isj.oaza set geom = st_setsrid(st_makepoint(lon, lat), 4326);
create index oaza_geom_idx on isj.oaza using gist(geom);

--
-- Inserting the Gaiku data into address Table
--
insert into address (todofuken, shikuchoson, ooaza, chiban, lat, lon, geog)
  select pref_name, city_name, oaza_name, gaiku_code, lat, lon, geom::geography from isj.gaiku;

insert into address (todofuken, shikuchoson, ooaza, chiban, lat, lon, geog)
  select pref_name, city_name, oaza_name, gaiku_code, lat, lon, geom::geography from isj.gaiku_with_koaza;

--
-- Inserting the Oaza data into address_o Table
--
insert into address_o (todofuken, shikuchoson, ooaza, lat, lon)
  select pref_name, city_name, oaza_name, lat, lon from isj.oaza;

--
-- Creating a temporary Shikuchoson table from the Oaza table
--
create table isj.shikuchoson as
  select todofuken, shikuchoson, st_centroid(st_union(st_makepoint(lon,lat))) as geom from address_o 
  group by todofuken, shikuchoson order by todofuken, shikuchoson;

--
-- Inserting the created data into the pgGeocoder Shikuchoson table
--
insert into address_s (todofuken, shikuchoson, lat, lon)
  select todofuken, shikuchoson, st_y(geom), st_x(geom) from isj.shikuchoson;

--
-- Creating a Temporary Todofuken table from the Oaza table
--
create table isj.todofuken as
  select todofuken, st_centroid(st_union(st_makepoint(lon,lat))) as geom from address_o
  group by todofuken;

--
-- Inserting the created data into the pgGeocoder Todofuken table
--
insert into address_t (todofuken, lat, lon)
  select todofuken, st_y(geom), st_x(geom) from isj.todofuken;
