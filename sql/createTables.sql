create extension postgis;

--
-- for Geocoding
--
create table address_t (
  todofuken varchar(60),
  lat float,
  lon float,
  ttable varchar(40),
  code varchar(2),
  geog geography('POINT')
);

create table address_s (
  todofuken varchar(60),
  shikuchoson varchar(60),
  lat float,
  lon float,
  code varchar(5),
  geog geography('POINT')
);

create table address_o (
  todofuken varchar(60),
  shikuchoson varchar(60),
  ooaza varchar(60),
  tr_ooaza varchar(60),
  lat float,
  lon float,
  code varchar(12),
  geog geography('POINT')
);

create table address (
  todofuken varchar(60),
  shikuchoson varchar(60),
  ooaza varchar(60),
  chiban varchar(60),
  lat float,
  lon float,
  geog geography('POINT')
);

--
-- for Places 
--
create table places (
  id serial,
  owner varchar,
  category varchar,
  name varchar,
  lat float,
  lon float,
  details jsonb,
  geog geography('POINT')
);
