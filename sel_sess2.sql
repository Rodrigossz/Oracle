-- Defaults for SET AUTOTRACE EXPLAIN report
set linesize 300
set pagesize 300

column SID 		format 99999 heading Sid
column SERIAL#  format 99999 heading Serial
column spid 	format a5 heading OSProc
column process  format a5 heading OraProc
column username format a20 heading Username
column command  format a20 heading Command
column lockwait format a8 heading Lockwait
column status 	format a10 heading Status
column osuser 	format a20 heading OSUser
column program 	format a50 heading Program
column machine 	format a40 heading Machine
column terminal format a10 heading terminal
column logon 	format a20 heading Logon

select 	s.inst_id "InstId", s.sid "Sid", s.serial# "Serial", p.spid "OSProc", s.process "OraProc", decode(s.username,NULL,'PROC. INTERNAL',s.username) "Username",
decode(s.command, 0,'No Command', 1,'Create Table', 2,'Insert', 3,'Select', 6,'Update', 7,'Delete', 9,'Create Index',
                 15,'Alter Table', 21,'Create View', 23,'Validate Index', 35,'Alter Database', 39,'Create Tablespace',
		 41,'Drop Tablespace', 40,'Alter Tablespace', 49, 'Kill', 53,'Drop User', 62,'Analyze Table',
		 63,'Analyze Index', command||': Other') "Command",
		s.lockwait, to_char(LOGON_TIME, 'dd-mm-yy hh24:mi:ss') Logon, s.osuser, s.status, s.terminal, s.machine, s.sql_hash_value
from gv$process p,
	 gv$session s
where p.inst_id=s.inst_id and
      p.addr=s.paddr and
      s.status in ('ACTIVE' ,'KILLED') and
   	  s.username is not null
order by s.username
/
