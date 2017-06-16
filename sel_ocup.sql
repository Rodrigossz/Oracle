column t1_fname  heading "Nome do Data File"      format a80
column t1_tbspc  heading "Tablespace|p/Data File" format a30
column t1_fileid heading "Id"                     format 999
column t2_bytes  heading " Livre |(Mbytes)"       format 99999.999
column t1_bytes  heading "Tamanho|(Mbytes)"       format 99999.999
column pct_free  heading "Livre|%  "              format 99999.9
column t1_status heading "Status         "        format a15
set linesize 300
set pagesize 50

select t1.file_name                         t1_fname,
       t1.tablespace_name                   t1_tbspc,
       t1.file_id                           t1_fileid,
       max(t1.bytes) / 1048576              t1_bytes,
       sum(t2.bytes) / 1048576              t2_bytes,
       sum(t2.bytes) / max(t1.bytes) * 100  pct_free,
       substr(t1.status,1,15)               t1_status  
from sys.dba_data_files t1,
       sys.dba_free_space t2
where t1.tablespace_name = t2.tablespace_name (+) and
      t1.file_id = t2.file_id (+)
group by t1.file_name, t1.tablespace_name, t1.file_id, status
union all
select t1.file_name                         t1_fname,
       t1.tablespace_name                   t1_tbspc,
       t1.file_id                           t1_fileid,
       max(t1.bytes) / 1048576              t1_bytes,
       sum(t2.bytes) / 1048576              t2_bytes,
       sum(t2.bytes) / max(t1.bytes) * 100  pct_free,
       substr(t1.status,1,15)               t1_status  
from sys.dba_temp_files t1,
       sys.dba_free_space t2
where t1.tablespace_name = t2.tablespace_name (+) and
      t1.file_id = t2.file_id (+)
group by t1.file_name, t1.tablespace_name, t1.file_id, status
order by 2,1
/
