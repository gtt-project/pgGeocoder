--
-- pgReverseGeocoder.ja : Japanese Reverse Geocoder for PostgreSQL
-- Copyright (C) 2018  Mario Basa
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
--
-- このプログラムはフリーソフトウェアです。あなたはこれを、フリーソフトウェ
-- ア財団によって発行された GNU 一般公衆利用許諾契約書(バージョン2か、希
-- 望によってはそれ以降のバージョンのうちどれか)の定める条件の下で再頒布
-- または改変することができます。
-- 
-- このプログラムは有用であることを願って頒布されますが、*全くの無保証* 
-- です。商業可能性の保証や特定の目的への適合性は、言外に示されたものも含
-- め全く存在しません。詳しくはGNU 一般公衆利用許諾契約書をご覧ください。
--  
-- あなたはこのプログラムと共に、GNU 一般公衆利用許諾契約書の複製物を一部
-- 受け取ったはずです。もし受け取っていなければ、フリーソフトウェア財団ま
-- で請求してください(宛先は the Free Software Foundation, Inc., 59
-- Temple Place, Suite 330, Boston, MA 02111-1307 USA)。

-- DROP TYPE geores CASCADE;

CREATE TYPE geores AS (
   code        integer,
   x           double precision,
   y           double precision,
   address     character varying,
   todofuken   character varying,
   shikuchoson character varying,
   ooaza       character varying,
   chiban      character varying,  
   go          character varying
);


--
--   NOTE: The Address Table must have a column named "geog" of type Geography
--

CREATE OR REPLACE FUNCTION reverse_geocoder(numeric, numeric) 
  RETURNS geores AS $$
DECLARE
  mLon ALIAS FOR $1;
  mLat ALIAS FOR $2;
  output geores;
BEGIN
--
-- Setting Default Search Distance to 50 meters
--
  output := reverse_geocoder(mLon,mLat,50);  
  RETURN output;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION reverse_geocoder(numeric, numeric, numeric) 
  RETURNS geores AS $$
DECLARE
  mLon  ALIAS FOR $1;
  mLat  ALIAS FOR $2;
  mDist ALIAS FOR $3;
  
  point     geometry;
  o_bdry    RECORD;
  record    RECORD;
  output    geores;
  s_flag    boolean;
  s_bdry    RECORD;
BEGIN

  s_flag := FALSE;
  SELECT INTO point st_setsrid(st_makepoint(mLon,mLat),4326);
  SELECT INTO o_bdry geom FROM boundary_o WHERE st_intersects(point,geom);
  IF FOUND THEN
    SELECT INTO record todofuken, shikuchoson, ooaza, chiban,
      lon, lat,
      todofuken||shikuchoson||ooaza||chiban AS address,
      st_distance(point::geography,geog) AS dist 
      FROM address 
      WHERE st_intersects(geog,o_bdry.geom::geography) AND st_dwithin(point::geography,geog,mDist) 
      ORDER BY dist LIMIT 1;
      
    IF FOUND THEN
      output.x          := record.lon;
      output.y          := record.lat;
      output.code       := 1;
      output.address    := record.address;
      output.todofuken  := record.todofuken;
      output.shikuchoson:= record.shikuchoson;
      output.ooaza      := record.ooaza;
      output.chiban     := record.chiban;

      RETURN output;
    ELSE
      SELECT INTO record todofuken, shikuchoson, ooaza,
        lon, lat,
        todofuken||shikuchoson||ooaza AS address,
        st_distance(point::geography,geog) AS dist 
        FROM address_o 
        WHERE st_intersects(geog,o_bdry.geom::geography) 
        ORDER BY dist LIMIT 1;
        
      IF FOUND THEN
        output.x          := record.lon;
        output.y          := record.lat;
        output.code       := 2;
        output.address    := record.address;
        output.todofuken  := record.todofuken;
        output.shikuchoson:= record.shikuchoson;
        output.ooaza      := record.ooaza;
        output.chiban     := NULL;

        RETURN output;
      ELSE
        s_flag := TRUE;
      END IF;
    END IF;
  ELSE
    s_flag := TRUE;
  END IF;

  IF s_flag THEN
    SELECT INTO s_bdry geom FROM boundary_s WHERE st_intersects(point,geom);
    IF FOUND THEN
      SELECT INTO record todofuken, shikuchoson, lon, lat,
          todofuken||shikuchoson AS address, 0 AS dist
        FROM address_s AS a
        WHERE st_intersects(a.geog, s_bdry.geom::geography);
      IF FOUND THEN
        output.x          := record.lon;
        output.y          := record.lat;
        output.code       := 3;
        output.address    := record.address;
        output.todofuken  := record.todofuken;
        output.shikuchoson:= record.shikuchoson;
        output.ooaza      := NULL;
        output.chiban     := NULL;

        RETURN output;
      ELSE
        RETURN NULL;
      END IF;
    ELSE
      RETURN NULL;
    END IF;
  END IF;
END;
$$ LANGUAGE plpgsql;
