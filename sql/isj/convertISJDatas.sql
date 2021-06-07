--
-- Inserting the Gaiku data into address Table
--
insert into address (todofuken, shikuchoson, ooaza, chiban, lat, lon)
  select t_name, s_name, o_name, gaiku, lat, lon from isj.gaiku;

insert into address (todofuken, shikuchoson, ooaza, chiban, lat, lon)
  select t_name, s_name, o_name, gaiku, lat, lon from isj.gaiku_with_koaza;

--
-- Inserting the Oaza data into address_o Table
--
insert into address_o (todofuken, shikuchoson, ooaza, lat, lon)
  select t_name, s_name, o_name, lat, lon from oaza;

--
-- Creating a temporary Shikuchoson table from the Oaza table
--
create table shikuchoson as
  select todofuken, shikuchoson, st_centroid(st_union(st_makepoint(lon,lat))) as geom from address_o 
  group by todofuken, shikuchoson order by todofuken, shikuchoson;

--
-- Inserting the created data into the pgGeocoder Shikuchoson table
--
insert into address_s (todofuken, shikuchoson)
  select todofuken, shikuchoson, st_y(geom), st_x(geom) from shikuchoson;

--
-- Creating a Temporary Todofuken table from the Oaza table
--
create table todofuken as
  select todofuken, st_centroid(st_union(st_makepoint(lon,lat))) as geom from address_o
  group by todofuken;

--
-- Inserting the created data into the pgGeocoder Todofuken table
--
insert into address_t (todofuken, lat, lon)
  select todofuken, st_y(geom), st_x(geom) from todofuken;
