set lines 189
col column_name format a30
col index_name  format a30

select index_name, column_name 
from dba_ind_columns
where table_owner = '&owner'
  and table_name = '&table';
