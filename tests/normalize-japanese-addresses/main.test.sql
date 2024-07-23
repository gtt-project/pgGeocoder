BEGIN;

CREATE EXTENSION IF NOT EXISTS pgtap;

-- Not used because pgTAP doesn't support custom type, but for reference
CREATE TYPE normalize_result AS (
  pref text,
  city text,
  town text,
  -- other text,
  lat double precision,
  lng double precision,
  level smallint
);
-- DROP TYPE normalize_result;

CREATE FUNCTION geocoder_formatted(address text) RETURNS RECORD AS $$
DECLARE
  res RECORD;
BEGIN
  SELECT
    COALESCE(todofuken::text, '') AS pref,
    COALESCE(shikuchoson::text, '') AS city,
    COALESCE(ooaza::text, '') AS town,
    -- TODO: other,
    -- TODO: lat, lng
    -- CASE WHEN y = -999 THEN NULL
    --   ELSE y
    -- END::double precision AS lat,
    -- CASE WHEN x = -999 THEN NULL
    --   ELSE X
    -- END::double precision AS lng,
    code::smallint AS level
  INTO res
  FROM geocoder(address);

  RETURN res;
END;
$$ LANGUAGE plpgsql;
-- DROP FUNCTION geocoder_formatted(text);

CREATE FUNCTION json_formatted(json_str json) RETURNS RECORD AS $$
DECLARE
  res record;
BEGIN
  SELECT
    *
  INTO res
  FROM json_to_record(json_str) AS (
    pref text,
    city text,
    town text,
    -- TODO: other text,
    -- TODO: lat, lng
    -- lat double precision,
    -- lng double precision,
    level smallint
  );
  RETURN res;
END;
$$ LANGUAGE plpgsql;

SELECT plan(190);
-- DROP FUNCTION json_formatted(json);

-- Regexp replace pattern memo (not complete one):
-- IN: \s*test\('(.+)', async \(\) \=>\s+\{\n\s+const res \= await normalize\(\s*'(.+)',?\s*\)\n\s+expect\(res\).toStrictEqual\((.+)\)\n\s*\}\)
-- OUT: SELECT is(\n  geocoder_formatted('$2'),\n  json_formatted('$3'),\n  '$1'\n);\n

SELECT is(
  geocoder_formatted('大阪府堺市北区新金岡町4丁1−8'),
  json_formatted('{"pref": "大阪府", "city": "堺市北区", "town": "新金岡町四丁", "addr": "1-8", "lat": 34.568184, "lng": 135.519409, "level": 3}'),
  '大阪府堺市北区新金岡町4丁1−8'
);

SELECT is(
  geocoder_formatted('大阪府堺市北区新金岡町４丁１ー８'),
  json_formatted('{"pref": "大阪府", "city": "堺市北区", "town": "新金岡町四丁", "addr": "1-8", "lat": 34.568184, "lng": 135.519409, "level": 3}'),
  '大阪府堺市北区新金岡町４丁１ー８'
);

SELECT is(
  geocoder_formatted('和歌山県串本町串本1234'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "1234", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '和歌山県串本町串本1234'
);

SELECT is(
  geocoder_formatted('和歌山県東牟婁郡串本町串本1234'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "1234", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '和歌山県東牟婁郡串本町串本1234'
);

SELECT is(
  geocoder_formatted('和歌山県東牟婁郡串本町串本千二百三十四'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "1234", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '和歌山県東牟婁郡串本町串本千二百三十四'
);

SELECT is(
  geocoder_formatted('和歌山県東牟婁郡串本町串本一千二百三十四'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "1234", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '和歌山県東牟婁郡串本町串本一千二百三十四'
);

SELECT is(
  geocoder_formatted('和歌山県東牟婁郡串本町串本一二三四'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "1234", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '和歌山県東牟婁郡串本町串本一二三四'
);

SELECT is(
  geocoder_formatted('和歌山県東牟婁郡串本町串本千二三四'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "1234", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '和歌山県東牟婁郡串本町串本千二三四'
);

SELECT is(
  geocoder_formatted('和歌山県東牟婁郡串本町串本千二百三四'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "1234", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '和歌山県東牟婁郡串本町串本千二百三四'
);

-- TODO: Supporting Hiragana mixed search would be nice
-- SELECT is(
--   geocoder_formatted('和歌山県東牟婁郡串本町くじ野川一二三四'),
--   json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "鬮野川", "addr": "1234", "lat": 33.493026, "lng": 135.784941, "level": 3}'),
--   '和歌山県東牟婁郡串本町くじ野川一二三四'
-- );

SELECT is(
  geocoder_formatted('京都府京都市中京区寺町通御池上る上本能寺前町488番地'),
  json_formatted('{"pref": "京都府", "city": "京都市中京区", "town": "上本能寺前町", "addr": "488", "lat": 35.011582, "lng": 135.767914, "level": 3}'),
  '京都府京都市中京区寺町通御池上る上本能寺前町488番地'
);

SELECT is(
  geocoder_formatted('京都府京都市中京区上本能寺前町488'),
  json_formatted('{"pref": "京都府", "city": "京都市中京区", "town": "上本能寺前町", "addr": "488", "lat": 35.011582, "lng": 135.767914, "level": 3}'),
  '京都府京都市中京区上本能寺前町488'
);

SELECT is(
  geocoder_formatted('大阪府大阪市中央区大手前２-１'),
  json_formatted('{"pref": "大阪府", "city": "大阪市中央区", "town": "大手前二丁目", "addr": "1", "lat": 34.687006, "lng": 135.519317, "level": 3}'),
  '大阪府大阪市中央区大手前２-１'
);

-- WONTFIX: Using 24 instead of 二十四軒 seems to be quite rare in Hokkaido
-- SELECT is(
--   geocoder_formatted('北海道札幌市西区24-2-2-3-3'),
--   json_formatted('{"pref": "北海道", "city": "札幌市西区", "town": "二十四軒二条二丁目", "addr": "3-3", "lat": 43.074273, "lng": 141.315099, "level": 3}'),
--   '北海道札幌市西区二十四軒二条2丁目3番3号'
-- );

SELECT is(
  geocoder_formatted('京都府京都市東山区大和大路2-537-1'),
  json_formatted('{"pref": "京都府", "city": "京都市東山区", "town": "大和大路二丁目", "addr": "537-1", "lat": 34.989944, "lng": 135.770967, "level": 3}'),
  '京都府京都市東山区大和大路2-537-1'
);

SELECT is(
  geocoder_formatted('京都府京都市東山区大和大路2丁目五百三十七の1'),
  json_formatted('{"pref": "京都府", "city": "京都市東山区", "town": "大和大路二丁目", "addr": "537-1", "lat": 34.989944, "lng": 135.770967, "level": 3}'),
  '京都府京都市東山区大和大路2丁目五百三十七-1'
);

SELECT is(
  geocoder_formatted('愛知県蒲郡市旭町17番1号'),
  json_formatted('{"pref": "愛知県", "city": "蒲郡市", "town": "旭町", "addr": "17-1", "lat": 34.825785, "lng": 137.218621, "level": 3}'),
  '愛知県蒲郡市旭町17番1号'
);

SELECT is(
  geocoder_formatted('北海道岩見沢市栗沢町万字寿町１−２'),
  json_formatted('{"pref": "北海道", "city": "岩見沢市", "town": "栗沢町万字寿町", "addr": "1-2", "lat": 43.135248, "lng": 141.986658, "level": 3}'),
  '北海道岩見沢市栗沢町万字寿町１−２'
);

SELECT is(
  geocoder_formatted('北海道久遠郡せたな町北檜山区北檜山１９３'),
  json_formatted('{"pref": "北海道", "city": "久遠郡せたな町", "town": "北檜山区北檜山", "addr": "193", "lat": 42.414, "lng": 139.881784, "level": 3}'),
  '北海道久遠郡せたな町北檜山区北檜山１９３'
);

-- FIXME: Adding translate 桧 <=> 檜 is reasonable, because both pronounce "Hinoki" and mean same tree species
-- SELECT is(
--   geocoder_formatted('北海道久遠郡せたな町北桧山区北桧山１９３'),
--   json_formatted('{"pref": "北海道", "city": "久遠郡せたな町", "town": "北檜山区北檜山", "addr": "193", "lat": 42.414, "lng": 139.881784, "level": 3}'),
--   '北海道久遠郡せたな町北桧山区北桧山１９３'
-- );

SELECT is(
  geocoder_formatted('京都府京都市中京区錦小路通大宮東入七軒町466'),
  json_formatted('{"pref": "京都府", "city": "京都市中京区", "town": "七軒町", "addr": "466", "lat": 35.004829, "lng": 135.749797, "level": 3}'),
  '京都府京都市中京区錦小路通大宮東入七軒町466'
);

SELECT is(
  geocoder_formatted('栃木県佐野市七軒町2201'),
  json_formatted('{"pref": "栃木県", "city": "佐野市", "town": "七軒町", "addr": "2201", "lat": 36.305969, "lng": 139.57389, "level": 3}'),
  '栃木県佐野市七軒町2201'
);

SELECT is(
  geocoder_formatted('京都府京都市東山区大和大路通三条下る東入若松町393'),
  json_formatted('{"pref": "京都府", "city": "京都市東山区", "town": "若松町", "addr": "393", "lat": 35.007967, "lng": 135.774082, "level": 3}'),
  '京都府京都市東山区大和大路通三条下る東入若松町393'
);

SELECT is(
  geocoder_formatted('長野県長野市長野東之門町2462'),
  json_formatted('{"pref": "長野県", "city": "長野市", "town": "大字長野東之門町", "addr": "2462", "lat": 36.674892, "lng": 138.178449, "level": 3}'),
  '長野県長野市長野東之門町2462'
);

-- TODO: 字 exists middle of ooaza and koaza name
-- SELECT is(
--   geocoder_formatted('岩手県下閉伊郡普代村第１地割上村４３−２５'),
--   json_formatted('{"pref": "岩手県", "city": "下閉伊郡普代村", "town": "第一地割字上村", "addr": "43-25", "lat": 39.990149, "lng": 141.928282, "level": 3}'),
--   '岩手県下閉伊郡普代村第１地割上村４３−２５'
-- );

SELECT is(
  geocoder_formatted('岩手県花巻市下北万丁目１７４−１'),
  json_formatted('{"pref": "岩手県", "city": "花巻市", "town": "下北万丁目", "addr": "174-1", "lat": 39.394178, "lng": 141.099889, "level": 3}'),
  '岩手県花巻市下北万丁目１７４−１'
);

SELECT is(
  geocoder_formatted('岩手県花巻市十二丁目１１９２'),
  json_formatted('{"pref": "岩手県", "city": "花巻市", "town": "十二丁目", "addr": "1192", "lat": 39.358268, "lng": 141.122331, "level": 3}'),
  '岩手県花巻市十二丁目１１９２'
);

SELECT is(
  geocoder_formatted('岩手県滝沢市後２６８−５６６'),
  json_formatted('{"pref": "岩手県", "city": "滝沢市", "town": "後", "addr": "268-566", "lat": 39.839043, "lng": 141.094179, "level": 3}'),
  '岩手県滝沢市後２６８−５６６'
);

SELECT is(
  geocoder_formatted('青森県五所川原市金木町喜良市千苅６２−８'),
  json_formatted('{"pref": "青森県", "city": "五所川原市", "town": "金木町喜良市", "addr": "千苅62-8", "lat": 40.904317, "lng": 140.486676, "level": 3}'),
  '青森県五所川原市金木町喜良市千苅６２−８'
);

SELECT is(
  geocoder_formatted('岩手県盛岡市盛岡駅西通２丁目９番地１号'),
  json_formatted('{"pref": "岩手県", "city": "盛岡市", "town": "盛岡駅西通二丁目", "addr": "9-1", "lat": 39.698721, "lng": 141.135252, "level": 3}'),
  '岩手県盛岡市盛岡駅西通２丁目９番地１号'
);

SELECT is(
  geocoder_formatted('岩手県盛岡市盛岡駅西通２丁目９の１'),
  json_formatted('{"pref": "岩手県", "city": "盛岡市", "town": "盛岡駅西通二丁目", "addr": "9-1", "lat": 39.698721, "lng": 141.135252, "level": 3}'),
  '岩手県盛岡市盛岡駅西通２丁目９の１'
);

SELECT is(
  geocoder_formatted('岩手県盛岡市盛岡駅西通２の９の１'),
  json_formatted('{"pref": "岩手県", "city": "盛岡市", "town": "盛岡駅西通二丁目", "addr": "9-1", "lat": 39.698721, "lng": 141.135252, "level": 3}'),
  '岩手県盛岡市盛岡駅西通２の９の１'
);

SELECT is(
  geocoder_formatted('岩手県盛岡市盛岡駅西通２丁目９番地１号 マリオス10F'),
  json_formatted('{"pref": "岩手県", "city": "盛岡市", "town": "盛岡駅西通二丁目", "addr": "9-1 マリオス10F", "lat": 39.698721, "lng": 141.135252, "level": 3}'),
  '岩手県盛岡市盛岡駅西通２丁目９番地１号'
);

SELECT is(
  geocoder_formatted('東京都文京区千石4丁目15-7'),
  json_formatted('{"pref": "東京都", "city": "文京区", "town": "千石四丁目", "addr": "15-7", "lat": 35.729052, "lng": 139.740683, "level": 3}'),
  '東京都文京区千石4丁目15－7'
);

SELECT is(
  geocoder_formatted('東京都文京区千石四丁目15-7'),
  json_formatted('{"pref": "東京都", "city": "文京区", "town": "千石四丁目", "addr": "15-7", "lat": 35.729052, "lng": 139.740683, "level": 3}'),
  '東京都文京区千石四丁目15－7'
);

SELECT is(
  geocoder_formatted('東京都文京区千石4丁目15－7'),
  json_formatted('{"pref": "東京都", "city": "文京区", "town": "千石四丁目", "addr": "15-7", "lat": 35.729052, "lng": 139.740683, "level": 3}'),
  '東京都文京区千石4丁目15－7'
);

SELECT is(
  geocoder_formatted('東京都 文京区千石4丁目15－7'),
  json_formatted('{"pref": "東京都", "city": "文京区", "town": "千石四丁目", "addr": "15-7", "lat": 35.729052, "lng": 139.740683, "level": 3}'),
  '東京都 文京区千石4丁目15－7'
);

SELECT is(
  geocoder_formatted('東京都文京区 千石4丁目15－7'),
  json_formatted('{"pref": "東京都", "city": "文京区", "town": "千石四丁目", "addr": "15-7", "lat": 35.729052, "lng": 139.740683, "level": 3}'),
  '東京都文京区 千石4丁目15－7'
);

SELECT is(
  geocoder_formatted('東京都文京区千石4-15-7 '),
  json_formatted('{"pref": "東京都", "city": "文京区", "town": "千石四丁目", "addr": "15-7", "lat": 35.729052, "lng": 139.740683, "level": 3}'),
  '東京都文京区千石4-15-7 '
);

SELECT is(
  geocoder_formatted('和歌山県東牟婁郡串本町串本 833'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "833", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '和歌山県東牟婁郡串本町串本 833'
);

SELECT is(
  geocoder_formatted('和歌山県東牟婁郡串本町串本　833'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "833", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '和歌山県東牟婁郡串本町串本　833'
);

SELECT is(
  geocoder_formatted('東京都世田谷区上北沢４の９の２'),
  json_formatted('{"pref": "東京都", "city": "世田谷区", "town": "上北沢四丁目", "addr": "9-2", "lat": 35.669726, "lng": 139.620901, "level": 3}'),
  '東京都世田谷区上北沢４の９の２'
);

SELECT is(
  geocoder_formatted('東京都品川区東五反田２丁目５－１１'),
  json_formatted('{"pref": "東京都", "city": "品川区", "town": "東五反田二丁目", "addr": "5-11", "lat": 35.624169, "lng": 139.72819, "level": 3}'),
  '東京都品川区東五反田２丁目５－１１'
);

SELECT is(
  geocoder_formatted('東京都世田谷区上北沢四丁目2-1'),
  json_formatted('{"pref": "東京都", "city": "世田谷区", "town": "上北沢四丁目", "addr": "2-1", "lat": 35.669726, "lng": 139.620901, "level": 3}'),
  '東京都世田谷区上北沢四丁目2-1'
);

SELECT is(
  geocoder_formatted('東京都世田谷区上北沢4-2-1'),
  json_formatted('{"pref": "東京都", "city": "世田谷区", "town": "上北沢四丁目", "addr": "2-1", "lat": 35.669726, "lng": 139.620901, "level": 3}'),
  '東京都世田谷区上北沢4-2-1'
);

SELECT is(
  geocoder_formatted('東京都世田谷区上北沢４ー２ー１'),
  json_formatted('{"pref": "東京都", "city": "世田谷区", "town": "上北沢四丁目", "addr": "2-1", "lat": 35.669726, "lng": 139.620901, "level": 3}'),
  '東京都世田谷区上北沢４ー２ー１'
);

SELECT is(
  geocoder_formatted('東京都世田谷区上北沢４－２－１'),
  json_formatted('{"pref": "東京都", "city": "世田谷区", "town": "上北沢四丁目", "addr": "2-1", "lat": 35.669726, "lng": 139.620901, "level": 3}'),
  '東京都世田谷区上北沢４－２－１'
);

SELECT is(
  geocoder_formatted('東京都品川区西五反田2丁目31-6'),
  json_formatted('{"pref": "東京都", "city": "品川区", "town": "西五反田二丁目", "addr": "31-6", "lat": 35.626368, "lng": 139.721005, "level": 3}'),
  '東京都品川区西五反田2丁目31-6'
);

SELECT is(
  geocoder_formatted('東京都品川区西五反田2-31-6'),
  json_formatted('{"pref": "東京都", "city": "品川区", "town": "西五反田二丁目", "addr": "31-6", "lat": 35.626368, "lng": 139.721005, "level": 3}'),
  '東京都品川区西五反田2-31-6'
);

SELECT is(
  geocoder_formatted('大阪府大阪市此花区西九条三丁目２－１６'),
  json_formatted('{"pref": "大阪府", "city": "大阪市此花区", "town": "西九条三丁目", "addr": "2-16", "lat": 34.684074, "lng": 135.467031, "level": 3}'),
  '大阪府大阪市此花区西九条三丁目２－１６'
);

SELECT is(
  geocoder_formatted('大阪府大阪市此花区西九条三丁目2番16号'),
  json_formatted('{"pref": "大阪府", "city": "大阪市此花区", "town": "西九条三丁目", "addr": "2-16", "lat": 34.684074, "lng": 135.467031, "level": 3}'),
  '大阪府大阪市此花区西九条三丁目2番16号'
);

SELECT is(
  geocoder_formatted('大阪府大阪市此花区西九条3-2-16'),
  json_formatted('{"pref": "大阪府", "city": "大阪市此花区", "town": "西九条三丁目", "addr": "2-16", "lat": 34.684074, "lng": 135.467031, "level": 3}'),
  '大阪府大阪市此花区西九条3-2-16'
);

SELECT is(
  geocoder_formatted('大阪府大阪市此花区西九条３丁目２－１６'),
  json_formatted('{"pref": "大阪府", "city": "大阪市此花区", "town": "西九条三丁目", "addr": "2-16", "lat": 34.684074, "lng": 135.467031, "level": 3}'),
  '大阪府大阪市此花区西九条３丁目２－１６'
);

SELECT is(
  geocoder_formatted('千葉県鎌ケ谷市中佐津間２丁目１５－１４－９'),
  json_formatted('{"pref": "千葉県", "city": "鎌ケ谷市", "town": "中佐津間二丁目", "addr": "15-14-9", "lat": 35.800253, "lng": 140.002133, "level": 3}'),
  '千葉県鎌ケ谷市中佐津間２丁目１５－１４－９'
);

SELECT is(
  geocoder_formatted('岐阜県不破郡関ケ原町関ヶ原１７０１−６'),
  json_formatted('{"pref": "岐阜県", "city": "不破郡関ケ原町", "town": "大字関ケ原", "addr": "1701-6", "lat": 35.368524, "lng": 136.464997, "level": 3}'),
  '岐阜県不破郡関ケ原町関ヶ原１７０１−６'
);

SELECT is(
  geocoder_formatted('岐阜県関ケ原町関ヶ原１７０１−６'),
  json_formatted('{"pref": "岐阜県", "city": "不破郡関ケ原町", "town": "大字関ケ原", "addr": "1701-6", "lat": 35.368524, "lng": 136.464997, "level": 3}'),
  '岐阜県関ケ原町関ヶ原１７０１−６'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東4丁目14-イ22'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-イ22", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東4丁目14-イ22'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東4丁目14ーイ22'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-イ22", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東4丁目14-イ22'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東四丁目十四ーイ二十二'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-イ22", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東4丁目14-イ22'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東四丁目１４ーイ２２'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-イ22", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東4丁目14-イ22'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東四丁目１４のイ２２'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-イ22", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東4丁目14のイ22'
);

SELECT is(
  geocoder_formatted('岩手県花巻市南万丁目127'),
  json_formatted('{"pref": "岩手県", "city": "花巻市", "town": "南万丁目", "addr": "127", "lat": 39.387522, "lng": 141.088029, "level": 3}'),
  '岩手県花巻市南万丁目127'
);

SELECT is(
  geocoder_formatted('和歌山県東牟婁郡串本町田並1512'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "田並", "addr": "1512", "lat": 33.48681, "lng": 135.717844, "level": 3}'),
  '和歌山県東牟婁郡串本町田並1512'
);

SELECT is(
  geocoder_formatted('神奈川県川崎市多摩区東三田1-2-2'),
  json_formatted('{"pref": "神奈川県", "city": "川崎市多摩区", "town": "東三田一丁目", "addr": "2-2", "lat": 35.612653, "lng": 139.549014, "level": 3}'),
  '神奈川県川崎市多摩区東三田1-2-2'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東４の１４のイ２２'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-イ22", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東４の１４のイ２２'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東４ー１４ーイ２２'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-イ22", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東４ー１４ーイ２２'
);

SELECT is(
  geocoder_formatted('富山県富山市三番町1番23号'),
  json_formatted('{"pref": "富山県", "city": "富山市", "town": "三番町", "addr": "1-23", "lat": 36.688141, "lng": 137.217397, "level": 3}'),
  '富山県富山市三番町1番23号'
);

-- WONTFIX: Using 3 instead of 三番町 seems to be quite rare in Toyama
-- SELECT is(
--   geocoder_formatted('富山県富山市3-1-23'),
--   json_formatted('{"pref": "富山県", "city": "富山市", "town": "三番町", "addr": "1-23", "lat": 36.688141, "lng": 137.217397, "level": 3}'),
--   '富山県富山市3-1-23'
-- );

SELECT is(
  geocoder_formatted('富山県富山市中央通り3-1-23'),
  json_formatted('{"pref": "富山県", "city": "富山市", "town": "中央通り三丁目", "addr": "1-23", "lat": 36.689604, "lng": 137.222128, "level": 3}'),
  '富山県富山市中央通り3-1-23'
);

SELECT is(
  geocoder_formatted('埼玉県南埼玉郡宮代町大字国納３０9－１'),
  json_formatted('{"pref": "埼玉県", "city": "南埼玉郡宮代町", "town": "大字国納", "addr": "309-1", "lat": 36.038996, "lng": 139.697478, "level": 3}'),
  '埼玉県南埼玉郡宮代町大字国納３０9－１'
);

SELECT is(
  geocoder_formatted('埼玉県南埼玉郡宮代町国納３０9－１'),
  json_formatted('{"pref": "埼玉県", "city": "南埼玉郡宮代町", "town": "大字国納", "addr": "309-1", "lat": 36.038996, "lng": 139.697478, "level": 3}'),
  '埼玉県南埼玉郡宮代町国納３０9－１'
);

SELECT is(
  geocoder_formatted('大阪府高槻市奈佐原２丁目１－２ メゾンエトワール'),
  json_formatted('{"pref": "大阪府", "city": "高槻市", "town": "奈佐原二丁目", "addr": "1-2 メゾンエトワール", "lat": 34.861189, "lng": 135.579573, "level": 3}'),
  '大阪府高槻市奈佐原２丁目１－２ メゾンエトワール'
);

SELECT is(
  geocoder_formatted('埼玉県八潮市大字大瀬１丁目１－１'),
  json_formatted('{"pref": "埼玉県", "city": "八潮市", "town": "大瀬一丁目", "addr": "1-1", "lat": 35.808825, "lng": 139.84291, "level": 3}'),
  '埼玉県八潮市大字大瀬１丁目１－１'
);

SELECT is(
  geocoder_formatted('岡山県笠岡市大宜1249－1'),
  json_formatted('{"pref": "岡山県", "city": "笠岡市", "town": "大宜", "addr": "1249-1", "lat": 34.506729, "lng": 133.473295, "level": 3}'),
  '岡山県笠岡市大宜1249－1'
);

-- FIXME: Adding translate 冝 <=> 宜 is reasonable, because 冝 is 異体字 of 宜
-- SELECT is(
--   geocoder_formatted('岡山県笠岡市大冝1249－1'),
--   json_formatted('{"pref": "岡山県", "city": "笠岡市", "town": "大宜", "addr": "1249-1", "lat": 34.506729, "lng": 133.473295, "level": 3}'),
--   '岡山県笠岡市大冝1249－1'
-- );

SELECT is(
  geocoder_formatted('岡山県岡山市中区さい33-2'),
  json_formatted('{"pref": "岡山県", "city": "岡山市中区", "town": "さい", "addr": "33-2", "lat": 34.680505, "lng": 133.948429, "level": 3}'),
  '岡山県岡山市中区さい33-2'
);

-- TODO: ISJ 2023 dataset is using 'さい', but using 外字 seems to be correct (https://www.city.okayama.jp/shisei/0000020679.html)
-- SELECT is(
--   geocoder_formatted('岡山県岡山市中区穝33-2'),
--   json_formatted('{"pref": "岡山県", "city": "岡山市中区", "town": "さい", "addr": "33-2", "lat": 34.680505, "lng": 133.948429, "level": 3}'),
--   '岡山県岡山市中区穝33-2'
-- );

SELECT is(
  geocoder_formatted('千葉県松戸市栄町３丁目１６６－５'),
  json_formatted('{"pref": "千葉県", "city": "松戸市", "town": "栄町三丁目", "addr": "166-5", "lat": 35.803015, "lng": 139.905619, "level": 3}'),
  '千葉県松戸市栄町３丁目１６６－５'
);

-- TODO: CI dataset doesn't support old 新宿区三栄町 address
-- SELECT is(
--   geocoder_formatted('東京都新宿区三栄町１７－１６'),
--   json_formatted('{"pref": "東京都", "city": "新宿区", "town": "四谷三栄町", "addr": "17-16", "lat": 35.688757, "lng": 139.725668, "level": 3}'),
--   '東京都新宿区三栄町１７－１６'
-- );

-- SELECT is(
--   geocoder_formatted('東京都新宿区三榮町１７－１６'),
--   json_formatted('{"pref": "東京都", "city": "新宿区", "town": "四谷三栄町", "addr": "17-16", "lat": 35.688757, "lng": 139.725668, "level": 3}'),
--   '東京都新宿区三榮町１７－１６'
-- );

SELECT is(
  geocoder_formatted('新潟県新潟市中央区礎町通１ノ町１９６８−１'),
  json_formatted('{"pref": "新潟県", "city": "新潟市中央区", "town": "礎町通一ノ町", "addr": "1968-1", "lat": 37.920235, "lng": 139.049572, "level": 3}'),
  '新潟県新潟市中央区礎町通１ノ町１９６８−１'
);

SELECT is(
  geocoder_formatted('新潟県新潟市中央区礎町通１の町１９６８−１'),
  json_formatted('{"pref": "新潟県", "city": "新潟市中央区", "town": "礎町通一ノ町", "addr": "1968-1", "lat": 37.920235, "lng": 139.049572, "level": 3}'),
  '新潟県新潟市中央区礎町通１の町１９６８−１'
);

SELECT is(
  geocoder_formatted('新潟県新潟市中央区礎町通１の町１９６８の１'),
  json_formatted('{"pref": "新潟県", "city": "新潟市中央区", "town": "礎町通一ノ町", "addr": "1968-1", "lat": 37.920235, "lng": 139.049572, "level": 3}'),
  '新潟県新潟市中央区礎町通１の町１９６８の１'
);

-- WONTFIX: Using 1 instead of 一ノ町 seems to be quite rare in Niigata
-- SELECT is(
--   geocoder_formatted('新潟県新潟市中央区礎町通1-1968-1'),
--   json_formatted('{"pref": "新潟県", "city": "新潟市中央区", "town": "礎町通一ノ町", "addr": "1968-1", "lat": 37.920235, "lng": 139.049572, "level": 3}'),
--   '新潟県新潟市中央区礎町通1-1968-1'
-- );

SELECT is(
  geocoder_formatted('新潟県新潟市中央区上大川前通11番町1881-2'),
  json_formatted('{"pref": "新潟県", "city": "新潟市中央区", "town": "上大川前通十一番町", "addr": "1881-2", "lat": 37.927874, "lng": 139.049152, "level": 3}'),
  '新潟県新潟市中央区上大川前通11番町1881-2'
);

-- WONTFIX: Using 11 instead of 十一番町 seems to be quite rare in Niigata
-- SELECT is(
--   geocoder_formatted('新潟県新潟市中央区上大川前通11-1881-2'),
--   json_formatted('{"pref": "新潟県", "city": "新潟市中央区", "town": "上大川前通十一番町", "addr": "1881-2", "lat": 37.927874, "lng": 139.049152, "level": 3}'),
--   '新潟県新潟市中央区上大川前通11-1881-2'
-- );

SELECT is(
  geocoder_formatted('新潟県新潟市中央区上大川前通十一番町1881-2'),
  json_formatted('{"pref": "新潟県", "city": "新潟市中央区", "town": "上大川前通十一番町", "addr": "1881-2", "lat": 37.927874, "lng": 139.049152, "level": 3}'),
  '新潟県新潟市中央区上大川前通十一番町1881-2'
);

SELECT is(
  geocoder_formatted('埼玉県上尾市壱丁目１１１'),
  json_formatted('{"pref": "埼玉県", "city": "上尾市", "town": "大字壱丁目", "addr": "111", "lat": 35.957701, "lng": 139.570578, "level": 3}'),
  '埼玉県上尾市壱丁目１１１'
);

-- FIXME: Wiki 壱丁目 (https://ja.wikipedia.org/wiki/%E5%A3%B1%E4%B8%81%E7%9B%AE) describes variants,
--        so, supporting this would be nice. Just converting 壱 to 1 may be enough.
-- SELECT is(
--   geocoder_formatted('埼玉県上尾市一丁目１１１'),
--   json_formatted('{"pref": "埼玉県", "city": "上尾市", "town": "大字壱丁目", "addr": "111", "lat": 35.957701, "lng": 139.570578, "level": 3}'),
--   '埼玉県上尾市一丁目１１１'
-- );

-- SELECT is(
--   geocoder_formatted('埼玉県上尾市一町目１１１'),
--   json_formatted('{"pref": "埼玉県", "city": "上尾市", "town": "大字壱丁目", "addr": "111", "lat": 35.957701, "lng": 139.570578, "level": 3}'),
--   '埼玉県上尾市一町目１１１'
-- );

-- SELECT is(
--   geocoder_formatted('埼玉県上尾市壱町目１１１'),
--   json_formatted('{"pref": "埼玉県", "city": "上尾市", "town": "大字壱丁目", "addr": "111", "lat": 35.957701, "lng": 139.570578, "level": 3}'),
--   '埼玉県上尾市壱町目１１１'
-- );


-- SELECT is(
--   geocoder_formatted('埼玉県上尾市1-111'),
--   json_formatted('{"pref": "埼玉県", "city": "上尾市", "town": "大字壱丁目", "addr": "111", "lat": 35.957701, "lng": 139.570578, "level": 3}'),
--   '埼玉県上尾市1-111'
-- );

SELECT is(
  geocoder_formatted('神奈川県横浜市港北区大豆戸町１７番地１１'),
  json_formatted('{"pref": "神奈川県", "city": "横浜市港北区", "town": "大豆戸町", "addr": "17-11", "lat": 35.513492, "lng": 139.625651, "level": 3}'),
  '神奈川県横浜市港北区大豆戸町１７番地１１'
);

---- TODO: pgGeocoder doesn't support level search
-- test('It should get the level `1` with `神奈川県横浜市港北区大豆戸町１７番地１１`', async () => {
--   const res = await normalize('神奈川県横浜市港北区大豆戸町１７番地１１', {
--     level: 1
--   })
--   expect(res).toStrictEqual({ "pref": "神奈川県", "city": "", "town": "", "addr": "横浜市港北区大豆戸町17番地11", "lat": null, "lng": null, "level": 1})
-- })

-- test('It should get the level `2` with `神奈川県横浜市港北区大豆戸町１７番地１１`', async () => {
--   const res = await normalize('神奈川県横浜市港北区大豆戸町１７番地１１', {
--     level: 2
--   })
--   expect(res).toStrictEqual({ "pref": "神奈川県", "city": "横浜市港北区", "town": "", "addr": "大豆戸町17番地11", "lat": null, "lng": null, "level": 2})
-- })

-- test('It should get the level `3` with `神奈川県横浜市港北区大豆戸町１７番地１１`', async () => {
--   const res = await normalize('神奈川県横浜市港北区大豆戸町１７番地１１', {
--     level: 3
--   })
--   expect(res).toStrictEqual({ "pref": "神奈川県", "city": "横浜市港北区", "town": "大豆戸町", "addr": "17-11", "lat": 35.513492, "lng": 139.625651, "level": 3})
-- })

-- test('It should get the level `2` with `神奈川県横浜市港北区`', async () => {
--   const res = await normalize('神奈川県横浜市港北区', {
--     level: 3
--   })
--   expect(res).toStrictEqual({ "pref": "神奈川県", "city": "横浜市港北区", "town": "", "addr": "", "lat": null, "lng": null, "level": 2})
-- })

-- test('It should get the level `1` with `神奈川県`', async () => {
--   const res = await normalize('神奈川県', {
--     level: 3
--   })
--   expect(res).toStrictEqual({ "pref": "神奈川県", "city": "", "town": "", "addr": "", "lat": null, "lng": null, "level": 1})
-- })

SELECT is(
  geocoder_formatted('神奈川県あいうえお市'),
  json_formatted('{ "pref": "神奈川県", "city": "", "town": "", "addr": "あいうえお市", "lat": null, "lng": null, "level": 1}'),
  'It should get the level `1` with `神奈川県あいうえお市`'
);

SELECT is(
  geocoder_formatted('東京都港区あいうえお'),
  json_formatted('{ "pref": "東京都", "city": "港区", "town": "", "addr": "あいうえお", "lat": null, "lng": null, "level": 2}'),
  'It should get the level `2` with `東京都港区あいうえお`'
);

SELECT is(
  geocoder_formatted('あいうえお'),
  json_formatted('{ "pref": "", "city": "", "town": "", "addr": "あいうえお", "lat": null, "lng": null, "level": 0}'),
  'It should get the level `0` with `あいうえお`'
);

SELECT is(
  geocoder_formatted('東京都江東区豊洲1丁目2-27'),
  json_formatted('{ "pref": "東京都", "city": "江東区", "town": "豊洲一丁目", "addr": "2-27", "lat": 35.661813, "lng": 139.792044, "level": 3}'),
  '東京都江東区豊洲1丁目2-27'
);

SELECT is(
  geocoder_formatted('東京都江東区豊洲 1丁目2-27'),
  json_formatted('{ "pref": "東京都", "city": "江東区", "town": "豊洲一丁目", "addr": "2-27", "lat": 35.661813, "lng": 139.792044, "level": 3}'),
  '東京都江東区豊洲 1丁目2-27'
);

SELECT is(
  geocoder_formatted('東京都江東区豊洲 1-2-27'),
  json_formatted('{ "pref": "東京都", "city": "江東区", "town": "豊洲一丁目", "addr": "2-27", "lat": 35.661813, "lng": 139.792044, "level": 3}'),
  '東京都江東区豊洲 1-2-27'
);

SELECT is(
  geocoder_formatted('東京都 江東区 豊洲 1-2-27'),
  json_formatted('{ "pref": "東京都", "city": "江東区", "town": "豊洲一丁目", "addr": "2-27", "lat": 35.661813, "lng": 139.792044, "level": 3}'),
  '東京都 江東区 豊洲 1-2-27'
);

SELECT is(
  geocoder_formatted('東京都江東区豊洲 １ー２ー２７'),
  json_formatted('{ "pref": "東京都", "city": "江東区", "town": "豊洲一丁目", "addr": "2-27", "lat": 35.661813, "lng": 139.792044, "level": 3}'),
  '東京都江東区豊洲 １ー２ー２７'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東四丁目１４ーイ２２ ジオロニアマンション'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-イ22 ジオロニアマンション", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東4丁目14-イ２２ ジオロニアマンション'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東四丁目１４ーＡ２２ ジオロニアマンション'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-A22 ジオロニアマンション", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東4丁目14-Ａ２２ ジオロニアマンション'
);

SELECT is(
  geocoder_formatted('東京都町田市木曽東四丁目一四━Ａ二二 ジオロニアマンション'),
  json_formatted('{"pref": "東京都", "city": "町田市", "town": "木曽東四丁目", "addr": "14-A22 ジオロニアマンション", "lat": 35.564817, "lng": 139.429661, "level": 3}'),
  '東京都町田市木曽東4丁目一四━Ａ二二 ジオロニアマンション'
);

SELECT is(
  geocoder_formatted('東京都江東区豊洲 一丁目2-27'),
  json_formatted('{ "pref": "東京都", "city": "江東区", "town": "豊洲一丁目", "addr": "2-27", "lat": 35.661813, "lng": 139.792044, "level": 3}'),
  '東京都江東区豊洲 一丁目2-27'
);

SELECT is(
  geocoder_formatted('東京都江東区豊洲 四-2-27'),
  json_formatted('{ "pref": "東京都", "city": "江東区", "town": "豊洲四丁目", "addr": "2-27", "lat": 35.653798, "lng": 139.800664, "level": 3}'),
  '東京都江東区豊洲 四-2-27'
);

SELECT is(
  geocoder_formatted('石川県七尾市藤橋町亥45番地1'),
  json_formatted('{ "pref": "石川県", "city": "七尾市", "town": "藤橋町", "addr": "亥45-1", "lat": 37.041154, "lng": 136.941183, "level": 3}'),
  '石川県七尾市藤橋町亥45番地1'
);

SELECT is(
  geocoder_formatted('石川県七尾市藤橋町亥四十五番地1'),
  json_formatted('{ "pref": "石川県", "city": "七尾市", "town": "藤橋町", "addr": "亥45-1", "lat": 37.041154, "lng": 136.941183, "level": 3}'),
  '石川県七尾市藤橋町亥四十五番地1'
);

SELECT is(
  geocoder_formatted('石川県七尾市藤橋町 亥 四十五番地1'),
  json_formatted('{ "pref": "石川県", "city": "七尾市", "town": "藤橋町", "addr": "亥45-1", "lat": 37.041154, "lng": 136.941183, "level": 3}'),
  '石川県七尾市藤橋町 亥 四十五番地1'
);

SELECT is(
  geocoder_formatted('石川県七尾市藤橋町 亥 45-1'),
  json_formatted('{ "pref": "石川県", "city": "七尾市", "town": "藤橋町", "addr": "亥45-1", "lat": 37.041154, "lng": 136.941183, "level": 3}'),
  '石川県七尾市藤橋町 亥 45-1'
);

SELECT is(
  geocoder_formatted('和歌山県和歌山市 七番丁 19'),
  json_formatted('{ "pref": "和歌山県", "city": "和歌山市", "town": "七番丁", "addr": "19", "lat": 34.230447, "lng": 135.171994, "level": 3}'),
  '和歌山県和歌山市 七番丁19'
);

-- TODO: Supporting this would be nice
-- SELECT is(
--   geocoder_formatted('和歌山県和歌山市7番町19'),
--   json_formatted('{ "pref": "和歌山県", "city": "和歌山市", "town": "七番丁", "addr": "19", "lat": 34.230447, "lng": 135.171994, "level": 3}'),
--   '和歌山県和歌山市7番町19'
-- );

SELECT is(
  geocoder_formatted('和歌山県和歌山市十二番丁45'),
  json_formatted('{ "pref": "和歌山県", "city": "和歌山市", "town": "十二番丁", "addr": "45", "lat": 34.232035, "lng": 135.172088, "level": 3}'),
  '和歌山県和歌山市十二番丁45'
);

SELECT is(
  geocoder_formatted('和歌山県和歌山市12番丁45'),
  json_formatted('{ "pref": "和歌山県", "city": "和歌山市", "town": "十二番丁", "addr": "45", "lat": 34.232035, "lng": 135.172088, "level": 3}'),
  '和歌山県和歌山市12番丁45'
);

-- WONTFIX: Incase of Wakayama, 12-45 seems not to be rare, but for consistency of 富山市三番町 and 新潟市中央区11番町 cases
-- SELECT is(
--   geocoder_formatted('和歌山県和歌山市12-45'),
--   json_formatted('{ "pref": "和歌山県", "city": "和歌山市", "town": "十二番丁", "addr": "45", "lat": 34.232035, "lng": 135.172088, "level": 3}'),
--   '和歌山県和歌山市12-45'
-- );

SELECT is(
  geocoder_formatted('兵庫県宝塚市東洋町1番1号'),
  json_formatted('{ "pref": "兵庫県", "city": "宝塚市", "town": "東洋町", "addr": "1-1", "lat": 34.797971, "lng": 135.363236, "level": 3}'),
  '兵庫県宝塚市東洋町1番1号'
);

-- FIXME: Adding translate 塚 <=> 塚 is reasonable, because 塚 is 異体字 of 塚
-- SELECT is(
--   geocoder_formatted('兵庫県宝塚市東洋町1番1号'),
--   json_formatted('{ "pref": "兵庫県", "city": "宝塚市", "town": "東洋町", "addr": "1-1", "lat": 34.797971, "lng": 135.363236, "level": 3}'),
--   '兵庫県宝塚市東洋町1番1号'
-- );

SELECT is(
  geocoder_formatted('北海道札幌市中央区北三条西３丁目１－５６マルゲンビル３Ｆ'),
  json_formatted('{ "pref": "北海道", "city": "札幌市中央区", "town": "北三条西三丁目", "addr": "1-56マルゲンビル3F", "lat": 43.065075, "lng": 141.351683, "level": 3}'),
  '北海道札幌市中央区北三条西３丁目１－５６マルゲンビル３Ｆ'
);

SELECT is(
  geocoder_formatted('北海道札幌市北区北２４条西６丁目１−１'),
  json_formatted('{ "pref": "北海道", "city": "札幌市北区", "town": "北二十四条西六丁目", "addr": "1-1", "lat": 43.090538, "lng": 141.340527, "level": 3}'),
  '北海道札幌市北区北２４条西６丁目１−１'
);

SELECT is(
  geocoder_formatted('堺市北区新金岡町4丁1−8'),
  json_formatted('{"pref": "大阪府", "city": "堺市北区", "town": "新金岡町四丁", "addr": "1-8", "lat": 34.568184, "lng": 135.519409, "level": 3}'),
  '堺市北区新金岡町4丁1−8'
);

SELECT is(
  geocoder_formatted('串本町串本1234'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "1234", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '串本町串本1234'
);

SELECT is(
  geocoder_formatted('広島県府中市府川町315'),
  json_formatted('{"pref": "広島県", "city": "府中市", "town": "府川町", "addr": "315", "lat": 34.567649, "lng": 133.236891, "level": 3}'),
  '広島県府中市府川町315'
);

-- TODO: 府中市 exists in both 東京都 and 広島県. It is hard to distinguish them now, but supporting this would be nice.
-- SELECT is(
--   geocoder_formatted('府中市府川町315'),
--   json_formatted('{"pref": "広島県", "city": "府中市", "town": "府川町", "addr": "315", "lat": 34.567649, "lng": 133.236891, "level": 3}'),
--   '府中市府川町315'
-- );

SELECT is(
  geocoder_formatted('府中市宮西町2丁目24番地'),
  json_formatted('{"pref": "東京都", "city": "府中市", "town": "宮西町二丁目", "addr": "24", "lat": 35.669764, "lng": 139.477636, "level": 3}'),
  '府中市宮西町2丁目24番地'
);

SELECT is(
  geocoder_formatted('三重県三重郡菰野町大字大強原2796'),
  json_formatted('{"pref": "三重県", "city": "三重郡菰野町", "town": "大字大強原", "addr": "2796", "lat": 35.028963, "lng": 136.530668, "level": 3}'),
  '三重県三重郡菰野町大字大強原2796'
);

SELECT is(
  geocoder_formatted('三重県三重郡菰野町大強原2796'),
  json_formatted('{"pref": "三重県", "city": "三重郡菰野町", "town": "大字大強原", "addr": "2796", "lat": 35.028963, "lng": 136.530668, "level": 3}'),
  '三重県三重郡菰野町大強原2796'
);

SELECT is(
  geocoder_formatted('福岡県北九州市小倉南区大字井手浦874'),
  json_formatted('{"pref": "福岡県", "city": "北九州市小倉南区", "town": "大字井手浦", "addr": "874", "lat": 33.77509, "lng": 130.893088, "level": 3}'),
  '福岡県北九州市小倉南区大字井手浦874'
);

SELECT is(
  geocoder_formatted('福岡県北九州市小倉南区井手浦874'),
  json_formatted('{"pref": "福岡県", "city": "北九州市小倉南区", "town": "大字井手浦", "addr": "874", "lat": 33.77509, "lng": 130.893088, "level": 3}'),
  '福岡県北九州市小倉南区井手浦874'
);

SELECT is(
  geocoder_formatted('沖縄県那覇市小禄１丁目５番２３号１丁目マンション３０１'),
  json_formatted('{"pref": "沖縄県", "city": "那覇市", "town": "小禄一丁目", "addr": "5-23 一丁目マンション301", "lat": 26.192719, "lng": 127.679409, "level": 3}'),
  '沖縄県那覇市小禄１丁目５番２３号１丁目マンション３０１'
);

SELECT is(
  geocoder_formatted('香川県仲多度郡まんのう町勝浦字家六２０９４番地１'),
  json_formatted('{"pref": "香川県", "city": "仲多度郡まんのう町", "town": "勝浦", "addr": "家六2094-1", "lat": 34.097457, "lng": 133.97318, "level": 3}'),
  '香川県仲多度郡まんのう町勝浦字家六２０９４番地１'
);

SELECT is(
  geocoder_formatted('香川県仲多度郡まんのう町勝浦家六２０９４番地１'),
  json_formatted('{"pref": "香川県", "city": "仲多度郡まんのう町", "town": "勝浦", "addr": "家六2094-1", "lat": 34.097457, "lng": 133.97318, "level": 3}'),
  '香川県仲多度郡まんのう町勝浦家六２０９４番地１'
);

SELECT is(
  geocoder_formatted('愛知県あま市西今宿梶村一３８番地４'),
  json_formatted('{"pref": "愛知県", "city": "あま市", "town": "西今宿梶村一", "addr": "38-4", "lat": 35.2002, "lng": 136.831606, "level": 3}'),
  '愛知県あま市西今宿梶村一３８番地４'
);

SELECT is(
  geocoder_formatted('香川県丸亀市原田町字東三分一１９２６番地１'),
  json_formatted('{"pref": "香川県", "city": "丸亀市", "town": "原田町", "addr": "東三分一1926-1", "lat": 34.258954, "lng": 133.78778, "level": 3}'),
  '香川県丸亀市原田町字東三分一１９２６番地１'
);

SELECT is(
  geocoder_formatted('串本町串本千二百三十四'),
  json_formatted('{"pref": "和歌山県", "city": "東牟婁郡串本町", "town": "串本", "addr": "1234", "lat": 33.470358, "lng": 135.779952, "level": 3}'),
  '串本町串本千二百三十四 (都道府県無し, 郡無し)'
);

SELECT is(
  geocoder_formatted('せたな町北檜山区北檜山１９３'),
  json_formatted('{"pref": "北海道", "city": "久遠郡せたな町", "town": "北檜山区北檜山", "addr": "193", "lat": 42.414, "lng": 139.881784, "level": 3}'),
  'せたな町北檜山区北檜山１９３ (都道府県無し, 郡無し)'
);

SELECT is(
  geocoder_formatted('岩手県花巻市十二丁目７０４'),
  json_formatted('{"pref": "岩手県", "city": "花巻市", "town": "十二丁目", "addr": "704", "lat": 39.358268, "lng": 141.122331, "level": 3}'),
  '岩手県花巻市十二丁目７０４'
);

SELECT is(
  geocoder_formatted('岩手県花巻市12丁目７０４'),
  json_formatted('{"pref": "岩手県", "city": "花巻市", "town": "十二丁目", "addr": "704", "lat": 39.358268, "lng": 141.122331, "level": 3}'),
  '岩手県花巻市12丁目７０４'
);

SELECT is(
  geocoder_formatted('岩手県花巻市１２丁目７０４'),
  json_formatted('{"pref": "岩手県", "city": "花巻市", "town": "十二丁目", "addr": "704", "lat": 39.358268, "lng": 141.122331, "level": 3}'),
  '岩手県花巻市１２丁目７０４'
);

SELECT is(
  geocoder_formatted('京都府京都市中京区河原町二条下ル一之船入町537-50'),
  json_formatted('{"pref": "京都府", "city": "京都市中京区", "town": "一之船入町", "addr": "537-50", "level": 3, "lat": 35.01217, "lng": 135.769483}'),
  '京都府京都市中京区河原町二条下ル一之船入町537-50'
);

SELECT is(
  geocoder_formatted('京都府宇治市莵道森本8−10'),
  json_formatted('{"pref": "京都府", "city": "宇治市", "town": "莵道森本", "addr": "8-10", "level": 3, "lat": 34.904244, "lng": 135.827041}'),
  '京都府宇治市莵道森本8−10'
);

-- FIXME: Adding translate 舟 <=> 船 is reasonable, because 舟 is one of variants of 船
-- SELECT is(
--   geocoder_formatted('京都府京都市中京区河原町二条下ル一之舟入町537-50'),
--   json_formatted('{"pref": "京都府", "city": "京都市中京区", "town": "一之船入町", "addr": "537-50", "level": 3, "lat": 35.01217, "lng": 135.769483}'),
--   '京都府京都市中京区河原町二条下ル一之舟入町537-50（船と舟のゆらぎ）'
-- );

-- FIXME: Adding translate 莵 <=> 菟 is reasonable, because 莵 is one of variants of 菟
-- SELECT is(
--   geocoder_formatted('京都府宇治市菟道森本8−10'),
--   json_formatted('{"pref": "京都府", "city": "宇治市", "town": "莵道", "addr": "森本8-10", "level": 3, "lat": 34.904244, "lng": 135.827041}'),
--   '京都府宇治市莵道森本8−10（莵と菟のゆらぎ）'
-- );

-- TODO: Allowing omitting 県 will be difficult, but supporting this would be nice.
-- -- 「都道府県」の文字列を省略した場合
-- SELECT is(
--   geocoder_formatted('岩手花巻市１２丁目７０４'),
--   json_formatted('{"pref": "岩手県", "city": "花巻市", "town": "十二丁目", "addr": "704", "lat": 39.358268, "lng": 141.122331, "level": 3}'),
--   '岩手花巻市１２丁目７０４'
-- );

-- FIXME: Adding translate 巿 <=> 市 is reasonable, because 巿 is one of variants of 市
-- SELECT is(
--   geocoder_formatted('千葉県巿川巿巿川1丁目'),
--   json_formatted('{"pref": "千葉県", "city": "市川市", "town": "市川一丁目", "addr": "", "level": 3, "lat": 35.731849, "lng": 139.909029}'),
--   '千葉県巿川巿巿川1丁目（市(し、いち)と巿(ふつ)のゆらぎ）'
-- );

SELECT is(
  geocoder_formatted('京都市北区紫野東御所田町'),
  json_formatted('{"pref": "京都府", "city": "京都市北区", "town": "紫野東御所田町", "addr": "", "level": 3, "lat": 35.039861, "lng": 135.753474}'),
  '京都市北区紫野東御所田町'
);

SELECT is(
  geocoder_formatted('鹿児島市山下町'),
  json_formatted('{"pref": "鹿児島県", "city": "鹿児島市", "town": "山下町", "addr": "", "level": 3, "lat": 31.596716, "lng": 130.55643}'),
  '鹿児島市山下町'
);

SELECT is(
  geocoder_formatted('市川市八幡1丁目1番1号'),
  json_formatted('{"pref": "千葉県", "city": "市川市", "town": "八幡一丁目", "addr": "1-1", "level": 3, "lat": 35.720285, "lng": 139.932528}'),
  '市川市八幡1丁目1番1号'
);

-- WONTFIX: Even supporting omitting 県, this case will be quite hard to support.
-- SELECT is(
--   geocoder_formatted('千葉市川市八幡1丁目1番1号'),
--   json_formatted('{"pref": "千葉県", "city": "市川市", "town": "八幡一丁目", "addr": "1-1", "level": 3, "lat": 35.720285, "lng": 139.932528}'),
--   '千葉市川市八幡1丁目1番1号'
-- );

SELECT is(
  geocoder_formatted('石川郡石川町字長久保185-4'),
  json_formatted('{"pref": "福島県", "city": "石川郡石川町", "town": "字長久保", "addr": "185-4", "level": 3, "lat": 37.155602, "lng": 140.446048}'),
  '石川郡石川町字長久保185-4'
);

-- TODO: It would be nice to support omitting 県
-- SELECT is(
--   geocoder_formatted('福島石川郡石川町字長久保185-4'),
--   json_formatted('{"pref": "福島県", "city": "石川郡石川町", "town": "字長久保", "addr": "185-4", "level": 3, "lat": 37.155602, "lng": 140.446048}'),
--   '福島石川郡石川町字長久保185-4'
-- );

SELECT is(
  geocoder_formatted('広島市西区商工センター六丁目9番39号'),
  json_formatted('{"pref": "広島県", "city": "広島市西区", "town": "商工センター六丁目", "addr": "9-39", "level": 3, "lat": 34.36812, "lng": 132.388293}'),
  '広島市西区商工センター六丁目9番39号 (町丁目に長音符(ー)が入る場合で、丁目の数字がその後に続く場合)'
);

SELECT is(
  geocoder_formatted('新潟県新潟市西区流通センター一丁目1-1'),
  json_formatted('{"pref": "新潟県", "city": "新潟市西区", "town": "流通センター一丁目", "addr": "1-1", "level": 3, "lat": 37.866158, "lng": 138.998185}'),
  '新潟県新潟市西区流通センター一丁目1-1 (町丁目に長音符(ー)が入る場合で、丁目の数字が 1 の場合)'
);

SELECT is(
  geocoder_formatted('青森県八戸市北インター工業団地4丁目1-1'),
  json_formatted('{"pref": "青森県", "city": "八戸市", "town": "北インター工業団地四丁目", "addr": "1-1", "level": 3, "lat": 40.556931, "lng": 141.426763}'),
  '青森県八戸市北インター工業団地4丁目1-1 (町丁目に長音符(ー)が入る場合)'
);

SELECT is(
  geocoder_formatted('富山県高岡市オフィスパーク1-1'),
  json_formatted('{"pref": "富山県", "city": "高岡市", "town": "オフィスパーク", "addr": "1-1", "level": 3, "lat": 36.670088, "lng": 136.998867}'),
  '富山県高岡市オフィスパーク1-1'
);

SELECT is(
  geocoder_formatted('福井県三方上中郡若狭町若狭テクノバレー1-1'),
  json_formatted('{"pref": "福井県", "city": "三方上中郡若狭町", "town": "若狭テクノバレー", "addr": "1-1", "level": 3, "lat": 35.477349, "lng": 135.859423}'),
  '福井県三方上中郡若狭町若狭テクノバレー1-1'
);

SELECT is(
  geocoder_formatted('埼玉県越谷市大字蒲生3795-1'),
  json_formatted('{"pref": "埼玉県", "city": "越谷市", "town": "大字蒲生", "addr": "3795-1", "level": 3, "lat": 35.860429, "lng": 139.790945}'),
  '埼玉県越谷市大字蒲生3795-1'
);

SELECT is(
  geocoder_formatted('埼玉県越谷市蒲生茜町9-3'),
  json_formatted('{"pref": "埼玉県", "city": "越谷市", "town": "蒲生茜町", "addr": "9-3", "level": 3, "lat": 35.866741, "lng": 139.7888}'),
  '埼玉県越谷市蒲生茜町9-3'
);

SELECT is(
  geocoder_formatted('埼玉県川口市大字芝字宮根3938-5'),
  json_formatted('{"pref": "埼玉県", "city": "川口市", "town": "大字芝", "addr": "字宮根3938-5", "level": 3, "lat": 35.843399, "lng": 139.690803}'),
  '埼玉県川口市大字芝字宮根3938-5'
);

SELECT is(
  geocoder_formatted('北海道上川郡東神楽町14号北1番地'),
  json_formatted('{"pref": "北海道", "city": "上川郡東神楽町", "town": "十四号", "addr": "北1", "level": 3, "lat": 43.693918, "lng": 142.463511}'),
  '北海道上川郡東神楽町14号北1番地'
);

SELECT is(
  geocoder_formatted('北海道上川郡東神楽町十四号北1番地'),
  json_formatted('{"pref": "北海道", "city": "上川郡東神楽町", "town": "十四号", "addr": "北1", "level": 3, "lat": 43.693918, "lng": 142.463511}'),
  '北海道上川郡東神楽町十四号北1番地'
);

-- FIXME: Adding translate 弥 <=> 彌 is reasonable, because 弥 is one of variants of 彌
-- SELECT is(
--   geocoder_formatted('愛知県名古屋市瑞穂区弥富町'),
--   json_formatted('{"pref": "愛知県", "city": "名古屋市瑞穂区", "town": "彌富町", "addr": "", "level": 3, "lat": 35.132011, "lng": 136.955457 }'),
--   '愛知県名古屋市瑞穂区弥富町'
-- );

SELECT is(
  geocoder_formatted('東京都千代田区永田町1-2-3-レジデンス億万101'),
  json_formatted('{"pref": "東京都", "city": "千代田区", "town": "永田町一丁目", "addr": "2-3-レジデンス億万101", "lat": 35.675895, "lng": 139.746306, "level": 3}'),
  '東京都千代田区永田町1-2-3-レジデンス億万101 (号の後にハイフンで漢数字末尾に含んだマンション名が続き、号室が数値の場合)'
);

SELECT is(
  geocoder_formatted('東京都千代田区三番町２番地４三番町ＫＳビル１０階'),
  json_formatted('{"pref": "東京都", "city": "千代田区", "town": "三番町", "addr": "2-4三番町KSビル10階", "lat": 35.690557, "lng": 139.743591, "level": 3}'),
  '東京都千代田区三番町２番地４三番町ＫＳビル１０階(番地と建物名が混ざり、「番」が消えることがないこと)'
);

SELECT is(
  geocoder_formatted('東京都千代田区神田美土代町９番地７千代田２１ビル７階'),
  json_formatted(concat('{',
    '"pref": "東京都",',
    '"city": "千代田区",',
    '"town": "神田美土代町",',
    '"addr": "9-7千代田21ビル7階",',
    '"lat": 35.693283,',
    '"lng": 139.765581,',
    '"level": 3',
  '}')::json),
  '東京都千代田区神田美土代町９番地７千代田２１ビル７階(「7千代田」が「7000代田」にならないこと)'
);

SELECT is(
  geocoder_formatted('神奈川県川崎市川崎区駅前本町１５番５十五番館ビル'),
  json_formatted('{"pref": "神奈川県", "city": "川崎市川崎区", "town": "駅前本町", "addr": "15-5十五番館ビル", "lat": 35.532434, "lng": 139.6996, "level": 3}'),
  '神奈川県川崎市川崎区駅前本町１５番５十五番館ビル(「５十五番館ビル」が「番」が消えずに「5十五番館ビル」となる)'
);

-- 途中にスペースを含むケース
-- https://github.com/geolonia/normalize-japanese-addresses/issues/180
SELECT is(
  (SELECT ARRAY[todofuken, shikuchoson, ooaza]::text[] FROM geocoder('京都府京都市 下京区上之町999')),
  (SELECT ARRAY['京都府', '京都市下京区', '上之町']), -- '999'
  '京都府京都市　下京区上之町999'
);

SELECT is(
  (SELECT ARRAY[todofuken, shikuchoson, ooaza]::text[] FROM geocoder('宮城県仙台市 若林区土樋999')),
  (SELECT ARRAY['宮城県', '仙台市若林区', '土樋']), -- '999'
  '宮城県仙台市 若林区土樋999'
);

SELECT is(
  (SELECT ARRAY[todofuken, shikuchoson, ooaza]::text[] FROM geocoder('青森県上北郡 横浜町字三保野888')),
  (SELECT ARRAY['青森県', '上北郡横浜町', '字三保野']), -- '888'
  '青森県上北郡 横浜町字三保野888'
);

-- TODO: It would be nice to support omitting last 町 in ooaza
-- -- 町丁目内の文字列の「町」の省略に関連するケース
-- SELECT is(
--   geocoder_formatted('東京都江戸川区西小松川12-345'),
--   json_formatted('{"pref": "東京都", "city": "江戸川区", "town": "西小松川町", "addr": "12-345", "level": 3, "lat": 35.698405, "lng": 139.862007}'),
--   '東京都江戸川区西小松川12-345'
-- );

-- TODO: It would be nice to support omitting last 町 between ooaza and koaza
-- SELECT is(
--   geocoder_formatted('滋賀県長浜市木之本西山123-4'),
--   json_formatted('{"pref": "滋賀県", "city": "長浜市", "town": "木之本町西山", "addr": "123-4", "level": 3, "lat": 35.496171, "lng": 136.204177}'),
--   '滋賀県長浜市木之本西山123-4'
-- );

-- 自治体内に町あり/なしが違うだけでほぼ同じ名前の町丁目が共存しているケース
SELECT is(
  geocoder_formatted('福島県須賀川市西川町123-456'),
  json_formatted('{"pref": "福島県", "city": "須賀川市", "town": "西川町", "addr": "123-456", "level": 3, "lat": 37.294611, "lng": 140.359974}'),
  '福島県須賀川市西川町123-456'
);

SELECT is(
  geocoder_formatted('福島県須賀川市西川123-456'),
  json_formatted('{"pref": "福島県", "city": "須賀川市", "town": "西川", "addr": "123-456", "level": 3, "lat": 37.296938, "lng": 140.343569}'),
  '福島県須賀川市西川123-456'
);

SELECT is(
  geocoder_formatted('広島県三原市幸崎久和喜12-345'),
  json_formatted('{"pref": "広島県", "city": "三原市", "town": "幸崎久和喜", "addr": "12-345", "level": 3, "lat": 34.348481, "lng": 133.067756}'),
  '広島県三原市幸崎久和喜12-345'
);

SELECT is(
  geocoder_formatted('広島県三原市幸崎町久和喜24-56'),
  json_formatted('{"pref": "広島県", "city": "三原市", "town": "幸崎町久和喜", "addr": "24-56", "level": 3, "lat": 34.352656, "lng": 133.055612}'),
  '広島県三原市幸崎町久和喜24-56'
);

-- 漢数字を含む町丁目については、後続の丁目や番地が壊れるので町の省略を許容しない
SELECT is(
  geocoder_formatted('愛知県名古屋市瑞穂区十六町１丁目123-4'),
  json_formatted('{"pref": "愛知県", "city": "名古屋市瑞穂区", "town": "十六町一丁目", "addr": "123-4", "level": 3, "lat": 35.128862, "lng": 136.936585}'),
  '愛知県名古屋市瑞穂区十六町１丁目123-4'
);

-- 大字◯◯と◯◯町が共存するケース
SELECT is(
  geocoder_formatted('埼玉県川口市新堀999-888'),
  json_formatted('{"pref": "埼玉県", "city": "川口市", "town": "大字新堀", "addr": "999-888", "level": 3, "lat": 35.827425, "lng": 139.783579}'),
  '埼玉県川口市新堀999-888'
);

SELECT is(
  geocoder_formatted('埼玉県川口市大字新堀999-888'),
  json_formatted('{"pref": "埼玉県", "city": "川口市", "town": "大字新堀", "addr": "999-888", "level": 3, "lat": 35.827425, "lng": 139.783579}'),
  '埼玉県川口市大字新堀999-888'
);

SELECT is(
  geocoder_formatted('埼玉県川口市新堀町999-888'),
  json_formatted('{"pref": "埼玉県", "city": "川口市", "town": "新堀町", "addr": "999-888", "level": 3, "lat": 35.825057, "lng": 139.781901}'),
  '埼玉県川口市新堀町999-888'
);

SELECT is(
  geocoder_formatted('埼玉県川口市大字新堀町999-888'),
  json_formatted('{"pref": "埼玉県", "city": "川口市", "town": "新堀町", "addr": "999-888", "level": 3, "lat": 35.825057, "lng": 139.781901}'),
  '埼玉県川口市大字新堀町999-888'
);

-- 町から始まる町丁目について、町を省略した場合は寄せない
SELECT '''' || COALESCE(ooaza, '') || '''' AS town, code AS level
  FROM geocoder('東京都荒川区屋５丁目');
\gset
SELECT isnt(:town::text, '町屋５丁目',
  '東京都荒川区屋５丁目 の町を省略した場合');
SELECT is(:level, 2);

SELECT '''' || COALESCE(ooaza, '') || '''' AS town, code AS level
  FROM geocoder('石川県輪島市野町桶戸');
\gset
SELECT isnt(:town::text, '町野町桶戸',
  '石川県輪島市町野町桶戸 の前側の町（町の名前の一部で、接尾の町に当たらない）を省略した場合');
SELECT is(:level, 2);

-- TODO: It would be nice to support omitting 町 between ooaza and koaza
-- SELECT is(
--   geocoder_formatted('石川県輪島市町野桶戸'),
--   json_formatted('{"pref": "石川県", "city": "輪島市", "town": "町野町桶戸", "addr": "", "level": 3, "lat": 37.414993, "lng":  137.092547}'),
--   '石川県輪島市町野町桶戸 の後側の町を省略した場合'
-- );

SELECT '''' || COALESCE(shikuchoson, '') || '''' AS city,
  '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市下京区西中筋通北小路通上る丸屋町');
\gset
SELECT is(:city::text, '京都市下京区',
  '京都府京都市下京区西中筋通北小路通上る丸屋町 京都の通り名削除と町の省略がコンフリクトするケース');
SELECT isnt(:town::text, '北小路町');
SELECT is(:town::text, '丸屋町');

SELECT '''' || COALESCE(shikuchoson, '') || '''' AS city,
  '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市下京区麓町123');
\gset
SELECT is(:city::text, '京都市下京区',
  '京都府京都市下京区油小路通高辻下ル麓町123');
SELECT is(:town::text, '麓町'); -- 123

-- 番地・号の分離: 京都の住所では「一号|1号..」などが「一番町」に正規化されてはいけない
SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区主計町一番一号');
\gset
SELECT isnt(:town::text, '一番町',
  '京都府京都市上京区主計町一番一号');
SELECT is(:town::text, '主計町'); -- 1-1

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区主計町二番二号');
\gset
SELECT isnt(:town::text, '二番町',
  '京都府京都市上京区主計町二番二号');
SELECT is(:town::text, '主計町'); -- 2-2

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区主計町三番三号');
\gset
SELECT isnt(:town::text, '三番町',
  '京都府京都市上京区主計町三番三号');
SELECT is(:town::text, '主計町'); -- 3-3

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区中務町５４３番２１号');
\gset
SELECT isnt(:town::text, '一番町',
  '京都府京都市上京区中務町５４３番２１号');
SELECT is(:town::text, '中務町'); -- 543-21

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区晴明町1番３号');
\gset
SELECT isnt(:town::text, '三番町',
  '京都府京都市上京区晴明町1番３号');
SELECT is(:town::text, '晴明町'); -- 1-3

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区主計町1番地3');
\gset
SELECT isnt(:town::text, '一番町',
  '京都府京都市上京区主計町1番地3');
SELECT is(:town::text, '主計町'); -- 1-3

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区主計町123番');
\gset
SELECT is(:town::text, '主計町',
  '京都府京都市上京区主計町123番'); -- 123

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区主計町123番地');
\gset
SELECT is(:town::text, '主計町',
  '京都府京都市上京区主計町123番地'); -- 123

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区主計町1番2-403号');
\gset
SELECT is(:town::text, '主計町',
  '京都府京都市上京区主計町1番2-403号'); -- 1-2-403号

SELECT skip('京都府京都市上京区あああ通り主計町1番2-403号 通り名を含むケース', 2);
SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区あああ通り主計町1番2-403号');
\gset
SELECT is(:town::text, '主計町',
  '京都府京都市上京区あああ通り主計町1番2-403号'); -- 1-2-403号

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('愛知県名古屋市緑区鳴海町字アイウエオ100番200号');
\gset
SELECT is(:town::text, '鳴海町',
  '京都以外の字は正しく分離される'); -- 字アイウエオ100-200

-- TODO: https://github.com/geolonia/normalize-japanese-addresses/pull/163 で解消される予定
SELECT skip('京都府京都市上京区主計町1番1号おはようビル301号室 ビル名に号が含まれるケース', 3);
SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('京都府京都市上京区主計町1番1号おはようビル301号室');
\gset
SELECT isnt(:town::text, '一番町',
  '京都府京都市上京区主計町1番1号おはようビル301号室 ビル名に号が含まれるケース');
SELECT is(:town::text, '主計町'); -- 1-1 おはようビル301号室

-- TODO: Shall we support this case?
-- test('should handle unicode normalization', async () => {
--   const address = `茨城県つくば市筑穂１丁目１０−４`.normalize('NFKD')
--   const resp = await normalize(address)
--   expect(resp.city).toEqual('つくば市')
-- })

-- test('latとlngのデータがない場合はnullを返す', async () => {
--   const res = await normalize('大分県大分市田中町3丁目1-12')
--   expect(res.lat).toEqual(null)
--   expect(res.lng).toEqual(null)
-- })

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('北海道滝川市一の坂町西');
\gset
SELECT is(:town::text, '',
  '町丁目名が判別できなかった場合、残った住所には漢数字->数字などの変換処理を施さない'); -- 一の坂町西

SELECT '''' || COALESCE(ooaza, '') || '''' AS town
  FROM geocoder('東京都文京区小石川1');
\gset
SELECT is(:town::text, '小石川一丁目',
  '丁目の数字だけあるときは正しく「一丁目」まで補充できる');

-- TODO: It would be nice to support building name case
-- SELECT '''' || COALESCE(ooaza, '') || '''' AS town
--   FROM geocoder('東京都文京区小石川1ビル名');
-- \gset
-- SELECT is(:town::text, '小石川一丁目',
--   '丁目の数字だけあるときは正しく「一丁目」まで補充できる（以降も対応）'); -- ビル名

-- FIXME: Adding translate 麩 <=> 麸 is reasonable, because 麩 is one of variants of 麸
-- SELECT '''' || COALESCE(ooaza, '') || '''' AS town, code AS level
--   FROM geocoder('愛知県津島市池麩町');
-- \gset
-- SELECT is(:town::text, '池麸町',
--   '旧漢字対応 (麩 -> 麸)');
-- SELECT is(:level, 3);

-- TODO: Supporting Kanji => Hiragana conversion search would be nice
-- SELECT '''' || COALESCE(ooaza, '') || '''' AS town, code AS level
--   FROM geocoder('愛知県安城市柿碕町');
-- \gset
-- SELECT is(:town::text, '柿さき町',
--   '柿碕町|柿さき町');
-- SELECT is(:level, 3);

-- 漢数字の小字のケース
SELECT '''' || COALESCE(ooaza, '') || '''' AS town, code AS level
  FROM geocoder('愛知県豊田市西丹波町三五十');
\gset
SELECT is(:town::text, '西丹波町',
  '愛知県豊田市西丹波町三五十'); -- 三五十
SELECT is(:level, 3);

SELECT '''' || COALESCE(ooaza, '') || '''' AS town, code AS level
  FROM geocoder('広島県府中市栗柄町名字八五十2459');
\gset
SELECT is(:town::text, '栗柄町',
  '広島県府中市栗柄町名字八五十2459 小字以降は現在のところ無視される'); -- 名字八五十2459
SELECT is(:level, 3);

SELECT * FROM finish();

ROLLBACK;
