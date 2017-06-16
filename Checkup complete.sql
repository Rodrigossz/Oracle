-- Executar os scripts de monitoramento:
spool retorno.log

-- @$ORACLE_HOME/rdbms/admin/awrrpt 
-- @$ORACLE_HOME/rdbms/admin/addmrpt



Prompt
Prompt Table information

col column_name format a30
col index_name  format a30

select t.owner "Owner" , t.TABLE_NAME "Tabelas", i.index_name "Indices" ,i.column_name "Colunas",i.COLUMN_POSITION "Posição" , t.num_rows "Tamanho"
from dba_ind_columns i, dba_all_tables t
where 
t.owner = i.table_owner and
t.table_name = i.table_name and
owner in ('SYSADM','BIX');


Prompt
Prompt Analyse 1

Prompt Analyse 1

select   OWNER,
         sum(decode(nvl(NUM_ROWS,9999), 9999,0,1)) "Tabelas Analisadas",
         sum(decode(nvl(NUM_ROWS,9999), 9999,1,0)) "Tabelas Não Analisadas",
         count(TABLE_NAME) "Total Tabelas"
from     dba_tables
where    OWNER in ('SYSADM','BIX')
group by OWNER
order by owner;


Prompt
Prompt Analyse 2

Prompt Analyse 2

select 'Index '||i.index_name||' not analyzed but table '||
       i.table_name||' is.'
  from user_tables t, user_indexes i
 where t.table_name    =      i.table_name
   and t.num_rows      is not null
   and i.distinct_keys is     null;


Prompt
Prompt Unused Index

col c1 heading 'Object|Name' format a30
col c2 heading 'Operation' format a15
col c3 heading 'Option' format a25
col c4 heading 'Index|Usage|Count' format 999,999
break on c1 skip 2
break on c2 skip 2

select
   p.object_name c1,
   p.operation   c2,
   p.options     c3,
   count(1)      c4
from
   dba_hist_sql_plan p,
   dba_hist_sqlstat s
where
   p.object_owner <> 'SYS'
and
   p.operation like '%INDEX%'
and
   p.sql_id = s.sql_id
having count(1) < 10
group by
   p.object_name,
   p.operation,
   p.options
order by
   1,2,3;


Prompt
Prompt Instance Data

col host_name format a15

select 	INSTANCE_NUMBER        ,
		INSTANCE_NAME          ,
		HOST_NAME              ,
		VERSION                ,
		TO_CHAR(STARTUP_TIME, 'DD-MM-YY HH24:MI:SS') STARTUP_TIME,
		STATUS                 ,
		PARALLEL               ,
		THREAD--               ,
		ARCHIVER               ,
		LOG_SWITCH_WAIT        ,
		LOGINS                 ,
		SHUTDOWN_PENDING       ,
		DATABASE_STATUS        ,
		INSTANCE_ROLE          
From v$instance;




Prompt
Prompt Tablespace Data

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


Prompt
Prompt Tablespace Data 2

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
order by 1;



Prompt
Prompt Redo Logs 1



col c1 format a10 heading "Month"
col c2 format a25 heading "Archive Date"
col c3 format 999 heading "Switches"

 compute AVG of C on A
 compute AVG of C on REPORT

 break on A skip 1 on REPORT skip 1

 select 
    to_char(trunc(first_time), 'Month') c1,
    to_char(trunc(first_time), 'Day : DD-Mon-YYYY') c2,
    count(*) c3
 from 
    v$log_history
 where 
    trunc(first_time) > last_day(sysdate-100) +1
 group by 
    trunc(first_time);


-------------------------------
--The following query shows a count and size of the redo log files by day


Prompt
Prompt Redo Logs 2

SELECT A.*,
 Round(A.Count#*B.AVG#/1024/1024) Daily_Avg_Mb
 FROM
 (
    SELECT
    To_Char(First_Time,'YYYY-MM-DD') DAY,
    Count(1) Count#,
    Min(RECID) Min#,
    Max(RECID) Max#
 FROM
    v$log_history
 GROUP BY 
    To_Char(First_Time,'YYYY-MM-DD')
 ORDER
 BY 1 DESC
 ) A,
 (
 SELECT
 Avg(BYTES) AVG#,
 Count(1) Count#,
 Max(BYTES) Max_Bytes,
 Min(BYTES) Min_Bytes
 FROM
 v$log
 ) B
 ;


Prompt
Prompt Redo Logs 3

--During the RESETLOGS operation, the information in v$log_history and v$offline_range --records are no longer cleared. In addition, two new columns have been added to indicate --the incarnation the records belong to: resetlogs_change--and resetlogs_time.
select 
    recid, 
    thread#, 
    sequence#, 
    resetlogs_change#,
    resetlogs_time
 from 
    v$log_history
 where 
    rownum < 20;



Prompt
Prompt rollback segments


column "Rollback Segment"       format a16
column "Size (Kb)"              format 9,999,999
column "Gets"                   format 999,999,990
column "Waits"                  format 9,999,990
column "% Waits"                format 90.00
column "--Shrinks"              format 999,990
column "--Extends"              format 999,990

Prompt
Prompt Rollback Segment Statistics...

Select rn.Name "Rollback Segment", rs.RSSize/1024 "Size (KB)", rs.Gets "Gets",
       rs.waits "Waits", (rs.Waits/rs.Gets)*100 "% Waits",
       rs.Shrinks "--Shrinks", rs.Extends "--Extends"
from   sys.v_$RollName rn, sys.v_$RollStat rs
where  rn.usn = rs.usn
/




--------------------------------------------------------------
-- DESDE PONTO EM DIANTE EXECUTAR DURANTE A EXECUÇÃO DO PROCESSO EM ANÁLISE
--------------------------------------------------------------



prompt
prompt **********************************************************
prompt **********************************************************
ttitle off
rem -----------------------------------------------------------------------
rem	DB Block Buffer - Hit Ratio
rem -----------------------------------------------------------------------
set heading on
set termout on
column "Physical Reads" format 9,999,999,999,999
column "Consistent Gets" format 9,999,999,999,999
column "DB Block Gets" format 9,999,999,999,999
column "Hit Ratio" format 999.99
TTitle left "***  Database:  "xdbname", DB Block Buffers Hit Ratio ( As of:  "xdate" )  ***" skip 1 -
       left "Percent = (100*(1-(Physical Reads/(Consistent Gets + DB Block Gets))))" skip 2
select  pr.value "Physical Reads",
	cg.value "Consistent Gets",
	bg.value "DB Block Gets",
	round((1-(pr.value/(bg.value+cg.value)))*100,2) "Hit Ratio"
from    v$sysstat pr, v$sysstat bg, v$sysstat cg
where   pr.name = 'physical reads'
and     bg.name = 'db block gets'
and     cg.name = 'consistent gets'
/
prompt
prompt ###################--  NOTE:   ####################
prompt
prompt If Percent is less than 70%, increase DB_BLOCK_BUFFERS.
prompt 
prompt ###################--  NOTE:   ###################--
rem -----------------------------------------------------------------------
rem	Shared Pool Size - Gets and Misses
rem -----------------------------------------------------------------------
column "Executions" format 9,999,999,990
column "Cache Misses Executing" format 9,999,999,990
column "Data Dictionary Gets" format 9,999,999,999
column "Get Misses" format 9,999,999,999
column "% Ratio" format 999.99
ttitle left skip 1 -
left "**********     Shared Pool Size (Execution Misses)     **********" skip 1
select sum(pins) "Executions",
       sum(reloads) "Cache Misses Executing",
       (sum(reloads)/sum(pins)*100) "% Ratio"
from v$librarycache
/
prompt 
prompt ###################--  NOTE:   ###################--
prompt
prompt If % Ratio is above 1%, increase SHARED_POOL_SIZE.
prompt 
prompt ###################--  NOTE:   ###################--
ttitle left "**********     Shared Pool Size (Dictionary Gets)     **********" skip 1
select sum(gets) "Data Dictionary Gets",
       sum(getmisses) "Get Misses",
       100*(sum(getmisses)/sum(gets)) "% Ratio"
from v$rowcache
/
prompt
prompt ###################--  NOTE:   ###################--
prompt
prompt If % Ratio is above 12%, increase SHARED_POOL_SIZE.
prompt
prompt ###################--  NOTE:   ###################--
prompt 
ttitle off
rem -----------------------------------------------------------------------
rem	Log Buffer
rem -----------------------------------------------------------------------
ttitle left "***   Log Buffers   ***" skip 1
select  substr(name,1,25) Name,
        substr(value,1,15) "VALUE (Near 0?)"
from v$sysstat
where name = 'redo log space requests'
/
prompt
prompt ###################--  NOTE:   ###################--
prompt
prompt If the Value is not near 0, increase LOG_BUFFER.
prompt
prompt ###################--  NOTE:   ###################--
prompt
ttitle left "**********     Latch Information     **********" skip 1
select  Name,
        gets, misses,
	decode(gets,0,0,(100*(misses/gets))) WILLING_TO_WAIT,
	sleeps, immediate_gets, immediate_misses,
	decode(immediate_gets,0,0,
	      (100*(immediate_misses/(immediate_gets+immediate_misses)))) "IMMEDIATE"
from v$latch
where name like 'redo%'
order by name
/
prompt
prompt ###################--  NOTE:   ###################--
prompt
prompt If WILLING_TO_WAIT and IMMEDIATE is less than 1%,
prompt increase LOG_SIMULTANEOUS_COPIES to twice --of CPU's,
prompt and decrease LOG_SMALL_ENTRY_MAX_SIZE in INIT.ORA file.
prompt
prompt ###################--  NOTE:   ###################--
prompt
rem -----------------------------------------------------------------------
rem -----------------------------------------------------------------------
rem	Tablespace Usage
rem -----------------------------------------------------------------------
set pagesize 66
clear breaks
clear computes
column "Total Bytes" format 9,999,999,999,999
column "SQL Blocks" format 9,999,999,999
column "Bytes Free" format 9,999,999,999,999
column "Bytes Used" format 9,999,999,999,999
column "% Free" format 9999.999
column "% Used" format 9999.999
break on report
compute sum of "Total Bytes" on report
compute sum of "SQL Blocks" on report
compute sum of "Bytes Free" on report
compute sum of "Bytes Used" on report
compute avg of "% Free" on report
compute avg of "% Used" on report
TTitle left "***   Database:  "xdbname", Current Tablespace Usage ( As of:  "xdate" )  ***" skip 1
select  substr(fs.FILE_ID,1,3) "ID#",
        fs.tablespace_name,
        df.bytes "Total Bytes",
        df.blocks "SQL Blocks", 
       sum(fs.bytes) "Bytes Free",
        (100*((sum(fs.bytes))/df.bytes)) "% Free",
        df.bytes-sum(fs.bytes) "Bytes Used",
        (100*((df.bytes-sum(fs.bytes))/df.bytes)) "% Used"
from sys.dba_data_files df, sys.dba_free_space fs
where df.file_id(+) = fs.file_id
group by fs.FILE_ID, fs.tablespace_name, df.bytes, df.blocks
order by fs.tablespace_name
/

ttitle off
prompt
prompt ###################--  NOTE:   ###################--
prompt
prompt If a tablespace has all datafiles with % Used greater 
prompt than 80%, it may need more datafiles added.
prompt
prompt ###################--  NOTE:   ###################--
prompt
rem -----------------------------------------------------------------------
rem	Disk Activity
rem -----------------------------------------------------------------------
column "File Name" format a35
column "File Total" format 999,999,999,990
set pagesize 33
ttitle  "***   Database:  "xdbname", DataFile's Disk Activity (As of: "xdate")  ***"  
select substr(df.file#,1,2) "ID",
       rpad(name,35,'.') "File Name",
       rpad(substr(phyrds,1,10),10,'.') "Phy Reads",
       rpad(substr(phywrts,1,10),10,'.') "Phy Writes",
       rpad(substr(phyblkrd,1,10),10,'.') "Blk Reads",
       rpad(substr(phyblkwrt,1,10),10,'.') "Blk Writes",
       rpad(substr(readtim,1,9),9,'.') "Read Time",
       rpad(substr(writetim,1,10),10,'.') "Write Time",
       (sum(phyrds+phywrts+phyblkrd+phyblkwrt+readtim)) "File Total"
from v$filestat fs, v$datafile df
where fs.file# = df.file#
group by df.file#, df.name, phyrds, phywrts, phyblkrd,
         phyblkwrt, readtim, writetim
order by sum(phyrds+phywrts+phyblkrd+phyblkwrt+readtim) desc, df.name
/

ttitle off
prompt
prompt ###################--  NOTE:   ###################--
prompt
prompt To reduce disk contention, insure that datafiles 
prompt with the greatest activity are not on the same disk.
prompt
prompt ###################--  NOTE:   ###################--
prompt
rem -----------------------------------------------------------------------
rem	Fragmentation Need
rem -----------------------------------------------------------------------
set heading on
set termout on
set pagesize 66
ttitle left "***  Database:  "xdbname", DEFRAGMENTATION NEED, AS OF:  "xdate"  ***" 
select  substr(de.owner,1,8) "Owner",
        substr(de.segment_type,1,8) "Seg Type",
        substr(de.segment_name,1,35) "Table Name (Segment)",
        substr(de.tablespace_name,1,20) "Tablespace Name",
        count(*) "Frag NEED",
        substr(df.name,1,40) "DataFile Name"
from sys.dba_extents de, v$datafile df
where de.owner <> 'SYS'
and de.file_id = df.file#
and de.segment_type in ('TABLE','INDEX')
group by de.owner, de.segment_name, de.segment_type, de.tablespace_name, df.name
having count(*) > 1
order by count(*) desc
/
ttitle off
prompt
prompt ###################--  NOTE:   ###################--
prompt
prompt The more fragmented a segment is, the more i/o needed to read
prompt that info.  Defragments this tables regularly to insure extents
prompt ('Frag NEED') do not get much above 2.
prompt
prompt ###################--  NOTE:   ###################--
prompt

--Tempo de Uptime do Oracle

select SYSDATE-logon_time "Days", (SYSDATE-logon_time)*24 "Hours"
from   sys.v_$session
where  sid=1 /* this is PMON */;

--Datafiles ordenados por maiores I/O físicos

COLUMN NAME FORMAT A50

SELECT NAME, PHYRDS, PHYWRTS
FROM V$DATAFILE df, V$FILESTAT fs
WHERE df.FILE# = fs.FILE#
order by 3 desc,2 desc;

SELECT Substr(d.name,1,50) "File Name", 
f.phyblkrd "Blocks Read", 
f.phyblkwrt "Blocks Writen", 
f.phyblkrd + f.phyblkwrt "Total I/O" 
FROM v$filestat f, 
v$datafile d 
WHERE d.file# = f.file#
ORDER BY f.phyblkrd + f.phyblkwrt DESC; 

--Queries com pesado consumo de I/O

SET PAGESIZE 100

select * from (select address, to_char(hash_value, '999999999999') "hash value",
disk_reads, executions, disk_reads/executions "reads/executions",
sql_text
from v$sqlarea
where disk_reads > 450 and executions > 0
order by disk_reads desc, executions desc)
where rownum < 16;

SELECT * FROM (SELECT ADDRESS, HASH_VALUE, BUFFER_GETS, EXECUTIONS,  BUFFER_GETS/EXECUTIONS "GETS/EXEC", SQL_TEXT
FROM V$SQLAREA 
WHERE BUFFER_GETS > 50000 
AND EXECUTIONS > 0
ORDER BY 3 DESC)
where rownum < 16;

--Sessão com maior consumo de CPU

SELECT v.SID, SUBSTR(s.NAME,1,30) "Statistic", v.VALUE
FROM V$STATNAME s, V$SESSTAT v
WHERE s.NAME = 'CPU used by this session'
AND v.STATISTIC--= s.STATISTIC#
AND v.VALUE > 0
ORDER BY 3;

--Texto das Queries ativas 

select s.username, s.osuser, t.sql_text
from v$session s, v$sqltext t
where s.sql_address = t.address and
           s.sql_hash_value = t.hash_value and
           s.status = 'ACTIVE' and
           s.username is not null 
order by s.username, s.prev_sql_addr, s.prev_hash_value, t.piece;

--Objetos Inválidos
select   OWNER,
         OBJECT_TYPE,
         OBJECT_NAME,
         STATUS
from     dba_objects
where    STATUS = 'INVALID'
order    by OWNER, OBJECT_TYPE, OBJECT_NAME;

--Constraints Desabilitadas
select   OWNER,
         TABLE_NAME,
         CONSTRAINT_NAME,
         decode(CONSTRAINT_TYPE, 
            'C','Check',
            'P','Primary Key',
            'U','Unique',
            'R','Foreign Key',
            'V','With Check Option'),
         STATUS 
from     dba_constraints
where    STATUS = 'DISABLED'
order    by OWNER, TABLE_NAME, CONSTRAINT_NAME;

--Contagem de Sessões
select   USERNAME,
         OSUSER,
         COUNT(*)
from     sys.v_$session
where    USERNAME is not NULL
group by USERNAME, OSUSER
order by COUNT(*) desc, USERNAME, OSUSER;

--Numero de Cursores abertos no momento
select max(value) from v$sesstat where statistic--= 3;

SELECT * FROM product_component_version ;



--------------------------------------------------------------------------------

-- List free and used space in database
SELECT sum(bytes)/1024 "free space in KB"
FROM dba_free_space;
SELECT sum(bytes)/1024 "used space in KB"
FROM dba_segments;

-- Tablespace types, and availability of data files
SELECT TABLESPACE_NAME, CONTENTS, STATUS
FROM DBA_TABLESPACES;

/*
Tuning: library cache
Glossary: 
pins = --of time an item in the library cache was executed
reloads = --of library cache misses on execution
Goal: 
get hitratio to be less than 1 
Tuning parm: 
adjust SHARED_POOL_SIZE in the initxx.ora file, increasing by small increments 
*/

SELECT    SUM(PINS) EXECS,
          SUM(RELOADS)MISSES,
          SUM(RELOADS)/SUM(PINS) HITRATIO
FROM      V$LIBRARYCACHE ;



--------------------------------------------------------------------------------

/*
--Tuning: data dictionary cache
--Glossary: 
--gets = --of requests for the item 
--getmisses = --of requests for items in cache which missed
--Goal: get rcratio to be less than 1 
--Tuning parm: 
--adjust SHARED_POOL_SIZE in the initxx.ora file, increasing by small increments 
*/
SELECT    SUM(GETS) HITS,
          SUM(GETMISSES) LIBMISS,
          SUM(GETMISSES)/SUM(GETS) RCRATIO
FROM      V$ROWCACHE ;



--------------------------------------------------------------------------------
/*
Tuning: buffer cache
Calculation:
buffer cache hit ratio = 1 - (phy reads/(db_block_gets + consistent_gets))
Goal:
get hit ratio in the range 85 - 90%
Tuning parm:
adjust DB_BLOCK_BUFFERS in the initxx.ora file, increasing by small increments 
*/

SELECT NAME, VALUE
FROM   V$SYSSTAT WHERE NAME IN
   ('DB BLOCK GETS','CONSISTENT GETS','PHYSICAL READS');



--------------------------------------------------------------------------------

/*Tuning: sorts
Goal: 
Increase number of memory sorts vs disk sorts 
Tuning parm:
adjust SORT_AREA_SIZE in the initxx.ora file, increasing by small increments 
*/

SELECT NAME, VALUE
FROM   V$SYSTAT
WHERE NAME LIKE '%SORT%';



--------------------------------------------------------------------------------
/*
Tuning: dynamic extension
An informational query. 
*/

SELECT NAME, VALUE
FROM V$SYSSTAT
WHERE NAME='RECURSIVE CALLS' ;

/* log mode of databases */

SELECT name, log_mode FROM v$database;


/* log mode of instance */

SELECT archiver FROM v$instance;

select group#, member, status from v$logfile ;

select group#,thread#,archived,status from v$log ;


spool off

