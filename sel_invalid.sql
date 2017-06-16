select owner, object_type, count(*) from dba_objects
where status = 'INVALID'
group by owner, object_type
order by owner;