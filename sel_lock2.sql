col inst format 9
col idle format a10
col program format a40
col sessionid format a15
col lockadorid format a15
col lckdetail format a15
col machine format a8
select
distinct
chr(39)||lockdetail.hold_inst_id ||'-'||lockdetail.hold_sid||','||lockdetail.hold_serial#||chr(39) lockadorid,
chr(39)||lockdetail.wait_inst_id ||'-'||lockdetail.wait_sid||','||lockdetail.wait_serial#||chr(39) lckdetail,
     substr(status,1,2)||decode(lockwait,null,' ','-lcked') status,
     substr(osuser,1,10)  "OS user",
     substr(s.username,1,10) "ORA USER",
     spid    "SO Process",
     machine,
     process "Ora pid",
     floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'||mod(mod(last_call_et,3600),60) "IDLE",
trunc(ctime/60) MINLCK,
     s.program||action||module program
    from
    gv$process p,
    gv$session s,
(SELECT
hold.inst_id hold_inst_id,
hold.sid hold_sid,hold.serial# hold_Serial#,
wait.inst_id wait_inst_id ,wait.sid wait_sid,wait.serial# wait_serial#
,(ctime) ctime
 FROM
 gv$session_wait sw,
 gv$session wait,
 GV$LOCK l,
 gv$session hold
 WHERE
 sw.event like  'enq%'
 and wait.sid = sw.sid
 and wait.inst_id = sw.inst_id
 and l.id1 = sw.p2
 and l.id2 = sw.p3
 and l.block <> 0
 and hold.sid = l.sid
 and hold.inst_id = l.inst_id) lockdetail
where
   s.inst_id = p.inst_id and
   p.addr = s.paddr and
   s.sid  = lockdetail.wait_sid   and
   s.inst_id = lockdetail.wait_inst_id
order by 1,8 desc
/
