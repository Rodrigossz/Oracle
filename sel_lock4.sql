col inst format 9
col idle format a10
col program format a40
col sessionid format a15
col machine format a8
select
s.inst_id inst,
     status||decode(lockwait,null,' ','-lcked') status,total qtd_locks,
     chr(39)||s.sid||','||s.serial#||chr(39) sessionid,
     substr(osuser,1,10)  "OS user",
     substr(s.username,1,10) "ORA USER",
     spid    "SO Process",
      machine,
     process "Ora pid",
     floor(last_call_et/3600)||':'||floor(mod(last_call_et,3600)/60)||':'||mod(mod(last_call_et,3600),60) "IDLE",
trunc(ctime/60) MINLCK,
     s.program||action||module program, lockador.SQL_HASH_VALUE
    from
    gv$process p,
    gv$session s,
(SELECT
hold.inst_id,
hold.sid hold_sid,hold.serial# Serial#,count(hold.sid) total,max(ctime) ctime, wait.SQL_HASH_VALUE
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
 and hold.inst_id = l.inst_id
 group by
hold.inst_id,
hold.sid, hold.serial#, wait.SQL_HASH_VALUE) lockador
where
   s.inst_id = p.inst_id and
   p.addr = s.paddr and
   s.sid  = lockador.hold_sid
   and s.inst_id = lockador.inst_id
/
