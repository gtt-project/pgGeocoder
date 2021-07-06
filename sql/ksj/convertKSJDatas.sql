--
-- Inserting the City(Shikuchoson) data into boundary_s Table
--
insert into boundary_s (todofuken, shikuchoson, code, geom)
  select n03_001 as pref_name, coalesce(n03_003, '') || coalesce(n03_004, '') as city_name,
    n03_007 as city_code, st_multi(st_union(geom)) as geom from ksj.admin_boundary
    where n03_007 is not null group by n03_001, n03_003, n03_004, n03_007
  order by n03_007;

--
-- Inserting the Pref(Todofuken) data into boundary_t Table
--
insert into boundary_t (todofuken, code, geom)
  select n03_001 as pref_name, max(left(n03_007, 2)) as pref_code,
    st_multi(st_union(geom)) from ksj.admin_boundary
    group by n03_001 order by pref_code;


--
-- Adjusting the City(Shikuchoson) location in address_s Table
--
-- TODO:

--
-- Adjusting the Pref(Todofuken) location in address_t Table
--
-- TODO:
