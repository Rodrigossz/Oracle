column sumb format 9999999 
column Tot_Size format 9999999 
column Tot_Free format 9999999 
column Pct_Free format 999 
column tablespace_name format a30

select 	dfs.tablespace_name, 
		sum(dfs.tots) / 1048576 Tot_Size, 
		sum(dfs.sumb) / 1048576 Tot_Free, 
		sum(dfs.sumb) * 100 / sum(dfs.tots) Pct_Free, ddf.status 
from (select tablespace_name, 0 tots, sum(bytes) sumb from dba_free_space dfs 
group by tablespace_name 
union 
select tablespace_name, 
	sum(bytes) tots, 
	0 
from dba_data_files group by tablespace_name) dfs, 
(select distinct tablespace_name, status from dba_data_files) ddf 
where dfs.tablespace_name=ddf.tablespace_name(+) 
group by dfs.tablespace_name, status 
order by 1
/
