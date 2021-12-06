# pgGeocoderのご紹介

2021/12/04(土) FOSS4G Japan 2021 Online  
合同会社Georepublic Japan　長瀬　興

---

# 自己紹介

<div class="grid grid-cols-[70%,30%]">
  <div>

  * 名前: Ko Nagase
  * 仕事: 合同会社 Georepublic Japan - 開発者
    * 主に既存システムのメンテナンス担当
    * ここ数年はRedmine関連システムのメンテナンス・開発を担当
  * コミュニティ活動:
    * [Redmineパッチ会](https://redmine-patch.connpass.com/)、[redmine.tokyo](https://redmine.tokyo/)に参加
    * redmine.tokyo 第20回勉強会 [LT発表資料](https://www.slideshare.net/geosanak/redmineredmine-gtt-geotasktracker-plugin)
  * GitHub: [@sanak](https://github.com/sanak)
    * 最近の活動は、主に [GTT Project](https://github.com/gtt-project) 関連
  * Twitter: [@geosanak](https://twitter.com/geosanak) (※ROM専です...)
  * 趣味: ポケモンGO (青TL50、※最近サボり気味...)

  </div>
  <div class="flex flex-col items-center gap-4">
    <img src="https://avatars.githubusercontent.com/sanak" class="w-40 h-40"/>
    <img src="https://upload.wikimedia.org/wikipedia/commons/3/3f/Redmine_logo.svg" class="h-15"/>
    <img src="https://avatars.githubusercontent.com/gtt-project" class="w-25 h-25"/>
  </div>
</div>

---

# 合同会社Georepublic Japan

<div class="grid grid-cols-[70%,30%]">
  <div>

  * 位置情報テクノロジー企業
  * URL: https://georepublic.info/ja/
  * FOSS4G・OSMなどに強い技術者・開発者が複数在籍
  * OSGeo日本支部の団体会員
  * 所在地:
    * 東京オフィス: SENQ霞が関
    * 神戸オフィス: 摂津本山駅近く
  * お仕事募集中です

  </div>
<div class="flex flex-col items-center gap-4">
<img src="/georepublic_logo_512_512.png" class="w-50 h-50"/>
<img src="/georepublic_logo_400dpi_orig.png" class="h-15"/>
</div>
</div>

---

# My City Report for Citizens

<div class="grid grid-cols-[60%,40%]">
  <div>
  <img src="https://www.mycityreport.jp/_next/image?url=https%3A%2F%2Fassets.mycityreport.jp%2Fbanners%2Fcities%2F90000.png&w=256&q=75" class="h-10" style="margin-bottom: 10px">

  URL: **https://www.mycityreport.jp**

  <p className="text-[#e91d63] font-bold">
  まちで見つけた「こまった」を、市民と自治体で<br>
  簡単に共有することができるサービス
  </p>

  * サーバはAWS上で稼働し、ジオコーダサーバの内部で pgGeocoder を利用

  </div>
  <div>
    <img src="https://www.mycityreport.jp/_next/image?url=%2Fpictures%2Fgovernments%2Fmcrgov%402x.png&w=1920&q=75" class="w-100" style="margin-left: auto; margin-right: auto"/>
  </div>
</div>

---

# 最近の住所・ジオコーダ関連の話題

* 2020/05/28 経産省が [IMIコンポーネントツール](https://info.gbiz.go.jp/tools/imi_tools/) で [住所変換コンポーネント](https://github.com/IMI-Tool-Project/imi-enrichment-address/) を公開
* 2020/06/01 Geoloniaが [Community Geocoder](https://community-geocoder.geolonia.com/) を公開 ([Geolonia blog](https://blog.geolonia.com/2020/06/01/community-geocoder.html))
* 2021/03/02 Geoloniaが [住所API](https://github.com/geolonia/japanese-addresses) をGitHub Pagesで公開 ([Geolonia blog](https://blog.geolonia.com/2021/03/02/address-api.html))
* 2021/03/28 Geoloniaが [住所正規化用のNodeモジュール](https://github.com/geolonia/normalize-japanese-addresses) を公開 ([Geolonia blog](https://blog.geolonia.com/2021/03/28/normalize-japanese-addresses.html))
* 2021/05/20 Geoloniaが [オープンソースの逆ジオコーダ](https://github.com/geolonia/open-reverse-geocoder) をベクトルタイルで作成 ([Geolonia blog](https://blog.geolonia.com/2021/05/20/open-reverse-geocoder.html))
* 2021/05/31 政府CIOポータルがベース・レジストリに関する [ディスカッションペーパー](https://cio.go.jp/dp2021_03) を公開
* 2021/06/01 AWSが [Amazon Location Service](https://aws.amazon.com/jp/location/) をリリース
* 2021/12/01 Geoloniaが日本の住所におけるデジタル化の課題をまとめたホワイトペーパーを無料公開 ([Geolonia プレスリリース](https://geolonia.com/pressrelease/2021/12/01/whitepaper-dx.html))

その他、OSM-ja MLでの住所表記に関するディスカッションなど...

<div v-click class="text-2xl" style="margin-top: 50px">

**実はGeorepublic内で古くから使われていたジオコーダ(pgGeocoder)が...！**

</div>

---

# アジェンダ

<style>
  li {
    font-size: 1.5rem;
  }
</style>

* pgGeocoderとは
* pgGeocoderの仕組み
* 逆ジオコーディング時の課題
* 位置参照情報のデータ読み込みスクリプト対応
* 逆ジオコーディングの改善
* その他の改善
* 今後の課題・展望

---

# pgGeocoderとは (1/3)

<div class="grid grid-cols-[50%,50%] gap-4">
  <div>

  * GeorepublicメンバーのMarioさん(GitHub:[@mbasa](https://github.com/mbasa))が、2010年11月、Georepublic入社前に開発した、PostgreSQL/PostGISベースのオープンソースの日本の住所ジオコーダ・逆ジオコーダ
  * URL: **https://github.com/mbasa/pgGeocoder**
  * ライセンス: GPL v2

  <div class="flex flex-row justify-center gap-10" style="padding-top: 30px">
    <div>
      <img src="https://wiki.postgresql.org/images/a/a4/PostgreSQL_logo.3colors.svg" class="h-30">
    </div>
    <div>
      <img src="https://upload.wikimedia.org/wikipedia/commons/7/7b/Logo_square_postgis.png" class="h-30">
    </div>
  </div>
  </div>
  <div>
    <img src="/github-mbasa.png"/>
  </div>
</div>

---

# pgGeocoderとは (2/3)

<div class="grid grid-cols-[50%,50%] gap-4">
  <div>

  * 基準となる住所データは、国土交通省の位置参照情報(ISJ)の街区レベル、大字・町丁目レベルデータ(ポイント形式のCSVファイル)を使用
  * URL: http://nlftp.mlit.go.jp/isj/index.html


  </div>
  <div>
    <img src="/isj-web-site.png"/>
  </div>
</div>

---

# pgGeocoderとは (3/3)

<div class="grid grid-cols-[50%,50%] gap-4">
  <div>

  * PostGISやpgRoutingのようなPostgreSQLの拡張機能(EXTENSION)でなく、テーブル定義、戻り値型定義、PL/pgSQL関数(`geocoder`/`reverse_geocoder`)定義、インデックス作成などのメンテナンス定義のみのシンプルな構成
    * PostGISさえあれば、ホスティングされたPostgreSQL(AWS RDSや、GCP Cloud SQLなど)上でも動作可能
  * インターフェースは `psql` やJDBCドライバなどによるSQL操作のみ
    * **※Web APIサービスとして動作させる場合は、別途開発が必要**

  </div>
  <div>
  
  例:
  1. `psql` でデータベースに接続:
     ```bash
     $ psql -U postgres addresses
     ```
  2. `geocoder` 関数を呼び出し:
     ```sql
     SELECT * FROM geocoder('神奈川県横浜市西区みなとみらい３−６−３');
     ```
  3. 結果:
     ```text
      code |     x      |     y     |             address             | todofuken | shikuchoson |     ooaza      | chiban | go 
     ------+------------+-----------+---------------------------------+-----------+-------------+----------------+--------+----
         2 | 139.632805 | 35.458282 | 神奈川県横浜市西区みなとみらい三丁目6番 | 神奈川県   | 横浜市西区    | みなとみらい三丁目 | 6      | 
     (1 row)
     ```

  </div>
</div>

---

# pgGeocoderの仕組み (1/7)

* 位置参照情報(ISJ)の街区レベル、大字・町丁目レベルデータ(ポイント形式のCSVファイル)を、街区(`address`)テーブル、大字(`address_o`)テーブルに読み込み

<style>
  table {
    font-size: 0.85rem;
    border-width: thin;
  }
  thead {
    background-color: #ccc
  }
  th, td {
    border-width: thin;
    padding: 0.1rem;
  }
</style>

<div class="grid grid-cols-[50%,50%] gap-4">
  <div>

  **街区(address)テーブル**

  |   カラム名   |     型      |           備考         |
  |-------------|-------------|-----------------------|
  | todofuken   | varchar(60) | 都道府県名              |
  | shikuchoson | varchar(60) | 市区町村名              |
  | ooaza       | varchar(60) | 大字・丁目 + 小字・通称名 |
  | chiban      | varchar(60) | 街区符号・地番           |
  | lat         | float       | 緯度                   |
  | lon         | float       | 経度                   |
  
  </div>
  <div>

  **大字(address_o)テーブル**

  |   カラム名   |     型      |         備考         |
  |-------------|-------------|---------------------|
  | todofuken   | varchar(60) | 都道府県名            |
  | shikuchoson | varchar(60) | 市区町村名            |
  | ooaza       | varchar(60) | 大字町丁目名          |
  | tr_ooaza    | varchar(60) | 正規化した大字町丁目名  |
  | lat         | float       | 緯度                 |
  | lon         | float       | 経度                 |

  </div>
</div>

---

# pgGeocoderの仕組み (2/7)

* 大字(`address_o`)テーブルから、市区町村名・都道府県名でのGROUP BY句を使用して、上位の市区町村(`address_s`)テーブル、都道府県(`address_t`)テーブルにデータを取り込み
* 緯度・経度については、各市区町村・都道府県の緯度・経度の重心(`ST_Centroid(ST_Union(ST_MakePoint(lon, lat)))`)で代用

<style>
  table {
    font-size: 0.85rem;
    border-width: thin;
  }
  thead {
    background-color: #ccc
  }
  th, td {
    border-width: thin;
    padding: 0.1rem;
  }
</style>

<div class="grid grid-cols-[50%,50%] gap-4">
  <div>

  **市区町村(address_s)テーブル**

  |   カラム名   |     型      |    備考   |
  |-------------|-------------|----------|
  | todofuken   | varchar(60) | 都道府県名 |
  | shikuchoson | varchar(60) | 市区町村名 |
  | lat         | float       | 緯度      |
  | lon         | float       | 経度      |
  
  </div>
  <div>

  **都道府県(address_t)テーブル**

  |   カラム名   |     型      |              備考             |
  |-------------|-------------|------------------------------|
  | todofuken   | varchar(60) | 都道府県名                     |
  | lat         | float       | 緯度                          |
  | lon         | float       | 経度                          |
  | ttable      | varchar(40) | 街区テーブル名(`address`)を指定  |

  </div>
</div>

---

# pgGeocoderの仕組み (3/7)

* データ取り込み・設定が完了したら、各テーブルにインデックスを作成
* 街区(`address`)テーブルに、Point型のジオグラフィカラムを追加し、緯度(`lat`)・経度(`lon`)から値を設定
* 大字(`address_o`)テーブルの `ooaza` カラムの値に対して、 `normalizeAddr` 関数で正規化を行い、結果を `tr_ooaza` カラムに設定
  ```sql
  UPDATE address_o SET tr_ooaza = normalizeAddr(ooaza);
  ```
  * 正規化は、PostgreSQLの `translate` 関数を使用して全角数値漢数字を半角英数値に変換したり、北海道の条の対応なども含まれる
    ```sql
    CREATE OR REPLACE FUNCTION normalizeAddr(character varying) 
      RETURNS varchar AS $$
      :
      address := translate(paddress,
          'ヶケ−－ーの１２３４５６７８９０一二三四五六七八九十丁目',
          'kk----1234567890123456789X-');
        :
    ```

---

# pgGeocoderの仕組み (4/7)

* 住所ジオコーディング(`geocoder` 関数)実行時のフロー
* コード箇所: https://github.com/mbasa/pgGeocoder/blob/master/sql/pgGeocoder.sql#L75-L107

<div class="grid grid-cols-[50%,50%] gap-4">
  <div>

  ```sql
  -- 都道府県テーブルから前方一致検索
  output := searchTodofuken( address );

  IF output.address <> 'なし' THEN
    output.code := matching_todofuken;
    -- マッチしたら、都道府県名を除いて、市区町村テーブルから前方一致検索
    gc := searchShikuchoson( address,output.todofuken);
  ELSE
    output.code := matching_nomatch;
    -- マッチしなければ、市区町村テーブルから前方一致検索
    gc := searchShikuchoson( address,'');
  END IF;
   
  IF gc.address <> 'なし' THEN
    output := gc;
    output.code := matching_shikuchoson;
    -- マッチしたら、都道府県名・市区町村名を除いて、大字テーブルから
    -- 正規化した状態で部分一致検索
    gc := searchOoaza( address,output.todofuken,output.shikuchoson );
  ELSE
   :
  ```
  
  </div>
  <div>
  
  ```sql
   :
    RETURN output;
  END IF;

  IF gc.address <> 'なし' THEN
    output := gc;
    output.code := matching_ooaza;
    -- マッチしたら、都道府県名・市区町村名・大字名を除いて、街区テーブルから
    -- 正規化した状態で完全一致検索
    gc := searchChiban( address,output.todofuken,output.shikuchoson,
                                  output.ooaza );
  ELSE
    RETURN output;
  END IF;

  IF gc.address <> 'なし' THEN
    output := gc;
    output.code := matching_chiban;
  END IF;

  RETURN output;
  ```
  
  </div>
</div>

---

# pgGeocoderの仕組み (5/7)

* 逆ジオコーディング(`reverse_geocoder` 関数)実行時の内部処理
* コード箇所: https://github.com/mbasa/pgGeocoder/blob/master/sql/pgReverseGeocoder.sql#L79-L85
  ```sql
   :
  -- 街区(address)テーブルから、指定した緯度・経度に最も近いものを、指定距離(デフォルト:50m)内から検索
  SELECT INTO record todofuken, shikuchoson, ooaza, chiban,
    lon, lat,
    todofuken||shikuchoson||ooaza||chiban AS address,
    st_distance(st_setsrid(st_makepoint( mLon,mLat),4326)::geography,geog) AS dist 
    FROM address  
    WHERE st_dwithin(st_setsrid(st_makepoint(mLon,mLat),4326)::geography,geog,mDist) 
    ORDER BY dist LIMIT 1;
   :
  ```
* 実行例:
  ```sql
  SELECT * FROM reverse_geocoder(141.342094, 43.050264);
  ```
  ```text
   code |     x      |     y     |             address              | todofuken | shikuchoson |     ooaza     | chiban | go 
  ------+------------+-----------+----------------------------------+-----------+-------------+---------------+--------+----
      1 | 141.342094 | 43.050264 | 北海道札幌市中央区南七条西十一丁目1281 | 北海道     | 札幌市中央区  | 南七条西十一丁目 | 1281   | 
  (1 row)
  ```

---

# pgGeocoderの仕組み (6/7)

* 最近の話題として、今年6月に京都の通り名の住所ジオコーディングにも対応
  * コミット差分: https://github.com/mbasa/pgGeocoder/commit/79c8884122f7435de8c5cd83b7c50538c791e5ef
* 実行例:
  ```sql
  SELECT * FROM geocoder('京都府京都市中京区河原町通四条上る米屋町３８０－１ツジクラビル１階');
  ```
  ```text
   code |     x      |    y     |          address          | todofuken | shikuchoson | ooaza | chiban | go 
  ------+------------+----------+---------------------------+-----------+-------------+-------+--------+----
      2 | 135.769651 | 35.00449 | 京都府京都市中京区米屋町380番 | 京都府     | 京都市中京区  | 米屋町 | 380    | 
  (1 row)
  ```

---

# pgGeocoderの仕組み (7/7)

* その他、pgGeocoderの特徴として、バルク(一括の)ジオコーディングも可能
  * Wikiリンク: https://github.com/mbasa/pgGeocoder/wiki/bulk_geocoding
    <img src="/github-mbasa-bulk-geocoding.png" class="h-100"/>

---

# 逆ジオコーディング時の課題 (1/5)

* 和歌山県の山間部で逆ジオコーディングができない問題  
  https://github.com/gtt-project/pgGeocoder/issues/2

<div class="grid grid-cols-[50%,50%] gap-4">
  <div>
  <img src="https://user-images.githubusercontent.com/629923/74630679-73efcf00-519e-11ea-8d23-de51aa3540b2.png" class="h-90">
  </div>
  <div>

  * 街区(`address`)テーブルの住所データ(図内赤丸)が存在するのは都市部のみで、山間部は大字(`address_o`)テーブルの住所データ(図内青丸)に対して最近傍探索する必要がある
  * ただし、大字データを利用しても、奈良県境界付近では、探索範囲(バッファ)を多めに取る必要が出てくる

  </div>
</div>

---

# 逆ジオコーディング時の課題 (2/5)

<div class="grid grid-cols-[50%,50%] gap-4">
  <div>

  * 街区・大字のポイントに対して最近傍探索を行っていることが原因なので、e-Statの国勢調査町丁・字等別境界データを利用したポイント-イン-ポリゴン探索を行えば、問題は解決しそう
  * e-Stat境界データを別テーブルに取り込んで、街区(`address`)・大字(`address_o`)テーブルへの参照を持つカラムを追加し、マッチングすれば解決？

  </div>
  <div>
  <img src="/estat-web-site.png" class="w-120"/>
  </div>
</div>

---

# 逆ジオコーディング時の課題 (3/5)

<img src="/estat_isj_matching.png" class="h-110 w-full object-cover"/>

---

# 逆ジオコーディング時の課題 (4/5)

<style>
  blockquote {
    margin-bottom: 0.825rem;
  }
  blockquote li {
    font-size: 0.825rem;
  }
</style>

* e-Statサイトの [データ定義情報/ダウンロードデータについて](https://www.e-stat.go.jp/help/data-definition-information/download) を良く読むと...
  > 1. 品質等  
  >    本システムで利用できる町丁・字等境界データについては、統計関連業務等のために作成されたもので、一般的な地域境界や行政区域とは必ずしも一致していません。このため、同境界データを利用される方は、自らの責任で利用目的に適合しているかを判断してください。

  > 境界データについての注意事項
  > 1. **国勢調査の町丁・字等境界データは、地方公共団体が調査を実施する際に設定した調査区の境界を基に作成しているため、住居表示等で用いられている実際の町丁・字の境界と一致しない場合があります。また、町丁・字の名称についても、一致しない場合があります。**  
  > 2. 一つの市区町村内に同一の町丁・字番号を持つ境域が複数存在する場合があり、このような場合には、重複フラグを付与し、識別できるようにしています。  
  > 3. 町丁・字等の面積は、町丁・字等の境界データの図郭により算出したものであり、市区町村内のすべての町丁・字等の総計は、国土地理院等の公式な面積と一致しません。  
  > 4. **都道府県の境界線は、接合処理を行っていないため、都道府県をまたがって市区町村を接合した場合には、都道府県の境界線にずれが生じる場合があります。**  
  > 5. 他県の飛び地の境域が市区町村に含まれる場合は、当該飛び地の境域情報も含まれます。また、水面調査区*がある場合には、同様に水面調査区の情報も含まれます。

---

# 逆ジオコーディング時の課題 (5/5)



<div class="grid grid-cols-[50%,50%] gap-4">
  <div>
  
  * e-Stat境界データと位置参照情報データのマッチングは断念...
  * e-Stat境界データのみの逆ジオコーディングの改善は諦め、フォールバック先として、国土数値情報の行政区域(市区町村単位)も組み合わせることに。

  </div>
  <div>
  <img src="/ksj-web-site.png" class="w-120"/>
  </div>
</div>

---

# 位置参照情報のデータ読み込みスクリプト対応 (1/2)

* (注)ここから先は、MyCityReport用にランドマーク(目標物)検索に対応していた [GTT Project](https://gtt-project.org/) 側でのフォークリポジトリ上で対応を進めることに
* URL: **https://github.com/gtt-project/pgGeocoder**

---

# 位置参照情報のデータ読み込みスクリプト対応 (2/2)

* 社内にあったナレッジベース(Redmine Wiki)や、IMIコンポーネントの住所変換コンポーネントのbash形式 [ダウンロードスクリプト](https://github.com/IMI-Tool-Project/imi-enrichment-address/blob/master/tools/download.sh) を参考
* 基本SQLを整理(ジオグラフィカラムをテーブル作成時に追加など)し、bash形式スクリプトで基本データ構築を可能に
* 内部的には、位置参照情報の各都道府県の街区、大字・町丁目レベルCSVを一旦、 `isj` スキーマ内のテーブルに保存後、pgGeocoder側の各 `address(_*)` テーブルに反映
   ```bash
   $ cp .env.example .env

   $ createdb -U postgres addresses

   $ bash scripts/install.sh
   $ bash scripts/download_isj.sh 2020
   $ bash scripts/import_isj.sh 2020

   # インデックス作成、最適化(VACUUM FULL)を実行(20~30分程度時間がかかる)
   $ bash scripts/maintenance.sh
   ```

---

# 逆ジオコーディングの改善 (1/4)

* e-Stat境界データ、国土数値情報の行政区域データの格納先として、それぞれ大字境界(`boundary_o`)テーブル、市区町村境界(`boundary_s`)テーブルを作成

<style>
  table {
    font-size: 0.85rem;
    border-width: thin;
  }
  thead {
    background-color: #ccc
  }
  th, td {
    border-width: thin;
    padding: 0.1rem;
  }
</style>

<div class="grid grid-cols-[50%,50%] gap-4">
  <div>

  **大字境界(boundary_o)テーブル**

  |   カラム名   |     型      |                  備考                 |
  |-------------|-------------|--------------------------------------|
  | todofuken   | varchar(60) | 都道府県名                             |
  | shikuchoson | varchar(60) | 市区町村名                             |
  | ooaza       | varchar(60) | 町丁・字名                             |
  | code        | varchar(12) | 図形と集計データのリンクコード(`KEY_CODE`) |
  | geom        | geometry    | ポリゴン(MultiPolygon)                 |
  
  </div>
  <div>

  **市区町村境界(boundary_s)テーブル**

  |   カラム名   |     型      |           備考          |
  |-------------|-------------|------------------------|
  | todofuken   | varchar(60) | 都道府県名               |
  | shikuchoson | varchar(60) | 市区町村名               |
  | code        | varchar(5)  | 行政区域コード(`N03_007`) |
  | geom        | geometry    | ポリゴン(MultiPolygon)   |

  </div>
</div>

---

# 逆ジオコーディングの改善 (2/4)

* 位置参照情報と同様に、e-Stat境界データと国土数値情報(行政区域)のシェープファイルをダウンロード後、GDALの `ogr2ogr` コマンドでPostgreSQLで読み込める `PGDump` 形式に保存し、 `estat`・`ksj` の各スキーマ内のテーブルに保存後、pgGeocoder側の各 `boundary_*` テーブルに反映
* 逆ジオコーディング(`reverse_geocoder` 関数)実行時の内部処理を、境界データを考慮したものに変更
* コード箇所: https://github.com/gtt-project/pgGeocoder/blob/gtt/master/sql/pgReverseGeocoder.sql#L72-L121
  ```sql
  s_flag := FALSE; -- 市区町村境界フォールバックフラグ
  SELECT INTO point st_setsrid(st_makepoint(mLon,mLat),4326);
  -- 指定した緯度・経度にかかる大字境界ポリゴンを検索
  SELECT INTO o_bdry geom FROM boundary_o WHERE st_intersects(point,geom);
  IF FOUND THEN
    -- 大字境界ポリゴンが見つかれば、その中に含まれる位置参照情報の街区ポイントを指定距離(デフォルト:50m)内から検索
    SELECT INTO record todofuken, shikuchoson, ooaza, chiban,
      lon, lat,
      todofuken||shikuchoson||ooaza||chiban AS address,
      st_distance(point::geography,geog) AS dist 
      FROM address 
      WHERE st_intersects(geog,o_bdry.geom::geography) AND st_dwithin(point::geography,geog,mDist) 
      ORDER BY dist LIMIT 1;
       :
  ```

---

# 逆ジオコーディングの改善 (3/4)

```sql
  IF FOUND THEN
    -- 大字境界ポリゴン内で条件に合う街区ポイントがあれば返却
    RETURN mk_geores(record, 1);
  ELSE
    -- 街区ポイントがなければ、大字ポイントから同様に検索
    SELECT INTO record todofuken, shikuchoson, ooaza, NULL::varchar as chiban,
      lon, lat,
      todofuken||shikuchoson||ooaza AS address,
      st_distance(point::geography,geog) AS dist 
      FROM address_o 
      WHERE st_intersects(geog,o_bdry.geom::geography) 
      ORDER BY dist LIMIT 1;
      
    IF FOUND THEN
      RETURN mk_geores(record, 2);
    ELSE
      -- 大字境界ポリゴン内で大字ポイントも見つからなければ、市区町村境界フォールバックフラグをONに設定
      s_flag := TRUE;
    END IF;
  END IF;
ELSE
  -- 都道府県境界などで大字境界ポリゴンが見つからない場合も、市区町村境界フォールバックフラグをONに設定
  s_flag := TRUE;
END IF;
 :
```

---

# 逆ジオコーディングの改善 (4/4)

```sql
IF s_flag THEN
  -- 指定した緯度・経度にかかる市区町村境界ポリゴンを検索
  SELECT INTO s_bdry geom FROM boundary_s WHERE st_intersects(point,geom);
  IF FOUND THEN
    -- 市区町村境界ポリゴンが見つかれば、その中に含まれる市区町村ポイントを検索
    SELECT INTO record todofuken, shikuchoson, NULL::varchar as ooaza, NULL::varchar as chiban,
        lon, lat,
        todofuken||shikuchoson AS address, 0 AS dist
      FROM address_s AS a
      WHERE st_intersects(a.geog, s_bdry.geom::geography);
    IF FOUND THEN
      -- 市区町村境界ポリゴン内で条件に合う市区町村ポイントがあれば返却
      RETURN mk_geores(record, 3);
    ELSE
      RETURN NULL;
    END IF;
  ELSE
    RETURN NULL;
  END IF;
END IF;
```

---

# その他の改善

* 国土数値情報の市区町村役場、国・都道府県の機関データによる、市区町村・都道府県の結果緯度・経度の補正
  * 位置参照情報の大字ポイントの重心を返していたところを、市区町村役場、都道府県庁の位置を返すよう修正
* 位置参照情報のみでは不足していた、政令指定都市の市レベルの情報を、国土数値情報の市区町村役場データから補完
  * 政令指定都市で、区名まで含めないと市区町村レベルでマッチしなかった問題を、市名まででもマッチ可能に (例: `神奈川県横浜市`)
* MyCityReportで対応していたランドマーク(目標物)検索データを、CSVファイルから読み込めるよう対応

---

# 今後の課題・展望

* 課題:
  * Docker環境への対応
  * テストコードの追加
  * 大字境界ポリゴン、市区町村境界ポリゴンの、トポロジを維持した簡素化
  * ランドマーク(目標物)検索データとしての、国土数値情報の各種ポイントデータの取り込み
  * 郵便番号検索への対応
  * BBOXでのフィルタリングによる高速化検討
* 展望:
  * 複数データソース(位置参照情報、国土数値情報、e-Stat境界データなど)を同一データベース内に格納し、SQLクエリで照合できることで、各住所データ自体に誤りがあった場合にそれを検知し、データ提供元(国交省、総務省など)に還元できる仕組みができると良いかも
  * Geolonia様で取り組まれている各種ジオコーディング関連のOSSプロジェクトとで、言語の違い(JavaScript <=> (PL/pg)SQL)はあっても、何らかのコラボレーションができると良いかも

---
layout: intro
---

# ご清聴ありがとうございました

* GitHub: (スター・フィードバックお待ちしております！)
  * 本家(@mbasa): https://github.com/mbasa/pgGeocoder
  * GTT(@gtt-project): https://github.com/gtt-project/pgGeocoder
* Email:
  * 個人: nagase@georepublic.co.jp
  * 会社: info@georepublic.co.jp
