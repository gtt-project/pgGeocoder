--
-- assumes that address_t,address_s,address_o,address
-- have been created already.
--

--
-- updating the ttable field to point to address table
--
update address_t set ttable = 'address';

--
-- creating index for address_t
--
create index address_t1 on address_t(todofuken);
create index address_t2 on address_t(code);

--
-- creating index for address_s
--
create index address_s1 on address_s(todofuken);
create index address_s2 on address_s(shikuchoson);
create index address_s3 on address_s(code);

--
-- creating index for address_o
--
create index address_o1 on address_o(todofuken);
create index address_o2 on address_o(shikuchoson);
create index address_o3 on address_o(ooaza);
create index address_o4 on address_o(code);

--
-- creating index for address
--
create index address1 on address(todofuken);
create index address2 on address(shikuchoson);
create index address3 on address(ooaza);
create index address4 on address(chiban);

--
-- for Reverse Geocoding
--
create index address_o_g_idx on address_o using gist( geog );
create index address_g_idx on address using gist( geog );

--
-- Vacuuming everything
--
VACUUM FULL;
