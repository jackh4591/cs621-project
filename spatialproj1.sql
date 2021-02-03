--count by precinct high to low--
select precinct, boro, count(*) as numbyprecinct from nyshootingdump
group by precinct, boro
order by numbyprecinct desc;


--count by precinct low to high--
select precinct, boro, count(*) as numbyprecinct from nyshootingdump
group by precinct, boro
order by numbyprecinct asc;


--gender of victims by boro--
select vic_sex, boro, count(*) as numbyboro from nyshootingdump
group by vic_sex, boro
order by numbyboro desc; 


--shooting count by borough and by date--
select boro,count(*) from nyshootingdump
group by boro
order by count desc

select date_occur, boro, count(*) as numbydate from nyshootingdump
group by date_occur, boro
order by numbydate desc


--left join of nycpop and nyshootingdump--
drop table if exists nycjoin;
select nyshootingdump.ogc_fid, nyshootingdump.wkb_geometry, nyshootingdump.boro,nyshootingdump.precinct, nycpop.total_pop,nycpop.precinct_2020
into nycjoin from nyshootingdump
Left Join nycpop on nyshootingdump.precinct=nycpop.precinct_2020 

--left join of precincts and population--
drop table if exists nycjoin2;
select nyprecincts.ogc_fid,nyprecincts.geom,
nyprecincts.precinct, nycpop.total_pop, nycpop.precinct_2020
into nycjoin2 from nyprecincts
Left Join nycpop on nyprecincts.precinct=nycpop.precinct_2020;

--Bronx and Brooklyn Views--
DROP VIEW IF EXISTS BronxView;
CREATE  OR REPLACE VIEW  BronxView AS 
SELECT nyj.ogc_fid as Join_ID, nyj.boro as boro, 
nyj.total_precinct_pop as precinct_pop, nyj.geom as shooting_geom,
nyp.ogc_fid as Precinct_ID, nyp.precinct as precicnt
from nycjoin as nyj, nyprecincts as nyp
WHERE 
ST_Contains(nyp.geom,nyj.geom) and nyj.boro = 'BRONX';  

DROP VIEW IF EXISTS BrooklynView;
CREATE  OR REPLACE VIEW  BrooklynView AS 
SELECT nyj.ogc_fid as Join_ID, nyj.boro as boro, nyj.total_precinct_pop as precinct_pop, nyj.geom as shooting_geom,
nyp.ogc_fid as Precinct_ID, nyp.precinct as precicnt
from nycjoin as nyj, nyprecincts as nyp
WHERE 
ST_Contains(nyp.geom,nyj.geom) and nyj.boro = 'BROOKLYN'; 




--date_part queries for holiday observations--
select * from nyshootingdump
where (date_part('month',date_occur)=07 and date_part('day',date_occur)=04 and date_part('hour',occur_time)>=21)
or (date_part('month',date_occur)=07 and date_part('day',date_occur)=05 and date_part('hour',occur_time)<=06) 
order by date_occur, occur_time asc;

select * from nyshootingdump
where (date_part('month',date_occur)=09 and date_part('day',date_occur)=07 and date_part('hour',occur_time)>=21)
or (date_part('month',date_occur)=09 and date_part('day',date_occur)=08 and date_part('hour',occur_time)<=06);

select * from nyshootingdump
where (date_part('month',date_occur)=03 and date_part('day',date_occur)=17 and date_part('hour',occur_time)>=21)
or (date_part('month',date_occur)=03 and date_part('day',date_occur)=18 and date_part('hour',occur_time)<=06)
group by date_occur, nyshootingdump.ogc_fid
order by date_occur, occur_time asc;

--st_distance query to check within 20m of liquor stores--
select ld.lpkid,ld.lgeom,ld.name, sd.ogc_fid, sd.wkb_geometry, sd.boro
from liquor_dump as ld, nyshootingdump as sd
where st_distance(st_transform(ld.lgeom,32618),st_transform(sd.wkb_geometry,32618))<20;

--alter table statements--
alter table nycjoin rename column total_pop to total_precinct_pop;
alter table nycjoin rename column wkb_geometry to geom;
alter table nyprecincts rename column wkb_geometry to geom;
select * from nycjoin drop column if exists precinct_2020;
alter table nycjoin drop column precinct_2020;
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS jurisdicti; 
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS location_d;
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS time_occur; 
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS perp_age_g; 
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS perp_race; 
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS perp_sex; 
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS x_coord_cd; 
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS y_coord_cd; 
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS incident_k; 
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS latitude;
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS longitude; 
ALTER TABLE nyshootingdump DROP COLUMN IF EXISTS statistica;
