-- Defaults for SET AUTOTRACE EXPLAIN report
-- sessoes do banco de dados
column SID format 99999         heading Sid
column SERIAL# format 9999999 heading Serial
column username format a15    heading Username
column command format a15     heading Command
column lockwait format a8     heading Lockwait
column status format a10      heading Status
column osuser format a20      heading OSUser
column program format a25     heading Program
column terminal format a15    heading Terminal

set linesize 200
select 	s.inst_id, s.sid, s.serial#, p.spid "OS Process", s.process "Ora Process",decode(s.username,NULL,'PROC. INTERNAL',s.username) "Username",
decode(s.command, 0,'No Command', 1,'Create Table', 2,'Insert', 3,'Select', 6,'Update', 7,'Delete', 9,'Create Index',
                 15,'Alter Table', 21,'Create View', 23,'Validate Index', 35,'Alter Database', 39,'Create Tablespace',
		 41,'Drop Tablespace', 40,'Alter Tablespace', 49, 'Kill', 53,'Drop User', 62,'Analyze Table',
		 63,'Analyze Index', command||': Other') "Command",
		lockwait, to_char(LOGON_TIME, 'dd-mm-yy hh24:mi:ss') Logon, s.osuser, s.status, s.terminal, s.program
from gv$session s, 
     gv$process p
where p.inst_id=s.inst_id and
      p.addr=s.paddr      and
      s.username is not null
order by s.username
/
