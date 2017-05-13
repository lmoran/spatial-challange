# GEO-SPATIAL CHALLANGE

## Data Sources

### State Suburbs 

* Organisation: Australian Bureau of Statistics
* License: Creative Commons Attribution 2.5 Australia
* Online data: http://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/1270.0.55.003July%202016?OpenDocument
* Online metadata: http://www.abs.gov.au/AUSSTATS/abs@.nsf/Lookup/1270.0.55.003Explanatory%20Notes1July%202016?OpenDocument
* Update frequency: Five years (on the Census year) 
* Temporall extent: 2016
* Spatial extent: Australia
* Spatial Reference System: GDA94


### Victorian Schools 

* Organisation: Victorian Department of Education and Training
* License: Creative Commons Attribution 4.0 International 
* Online data: http://www.education.vic.gov.au/Documents/about/research/datavic/dv165-allschoolslocationlist2015.csv
* Online metadata: https://www.data.vic.gov.au/data/dataset/victorian-schools-location-2015
* Update frequency: Yearly 
* Temporall extent: 2015
* Spatial extent: Victoria
* Spatial Reference System: GDA94


## Processing

### Import of Schools

```
ogr2ogr -f PostgreSQL PG:"dbname='postgres' host='localhost' port='5432' user='postgres' password='postgres'" \
  ~/Downloads/dv165-allschoolslocationlist2015.csv \
  -lco GEOMETRY_NAME=geom -nlt point -nln schools_vic -overwrite \
  -a_srs EPSG:4326
```

```
UPDATE schools_vic 
  SET geom =  ST_Transform(ST_SetSRID(ST_MakePoint(x::decimal(13,10), y::decimal(13,10))::geometry, 4283), 4326);
```


### Import of Suburbs

```
ogr2ogr -f PostgreSQL PG:"dbname='postgres' host='localhost' port='5432' user='postgres' password='postgres'" \
  ~/SSC_2016_AUST.shp \
  -lco GEOMETRY_NAME=geom -nlt multipolygon -nln ssc_2016_aust -overwrite \
  -s_srs EPSG:4283 -t_srs EPSG:4326
```

```
DELETE FROM  ssc_2016_aust 
  WHERE ste_name16 <> 'Victoria';
```


### Export to CSV of Number of Schools by Suburb

```
COPY (
  SELECT ssc.ssc_code16, ssc.ssc_name16, COUNT(*) AS Schools
    FROM ssc_2016_aust ssc INNER JOIN schools_vic s ON ST_Within(s.geom, ssc.geom)
    GROUP BY ssc.ssc_name16, ssc.ssc_code16
    ORDER BY ssc.ssc_name16, ssc.ssc_code16
    ) TO '/home/lmorandini/projects/challange/deliverables/schools_by_locality.csv' WITH CSV HEADER;
```


## Data Exports

### Export to the DMP format

```
pg_dump -f deliverables/postgis_export.dmp \
  -h localhost -p 5432 -d postgres -U postgres \
  -t ssc_2016_aust -t schools_vic \
  -Z 9
```

### Export to GeoJSON
```
ogr2ogr -f GeoJson /tmp/schools_vic.geojson \
  PG:"dbname='postgres' host='localhost' port='5432' user='postgres' password='postgres'" \
  -sql "SELECT * FROM schools_vic"
ogr2ogr -f GeoJson /tmp/ssc_2016_aust.geojson \
  PG:"dbname='postgres' host='localhost' port='5432' user='postgres' password='postgres'" \
  -sql "SELECT * FROM ssc_2016_aust"
```

