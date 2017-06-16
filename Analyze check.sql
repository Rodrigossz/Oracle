-- Mostra tabelas que sofreram analyze

select   OWNER,
         sum(decode(nvl(NUM_ROWS,9999), 9999,0,1)) "Tabelas Analisadas",
         sum(decode(nvl(NUM_ROWS,9999), 9999,1,0)) "Tabelas Não Analisadas",
         count(TABLE_NAME) "Total Tabelas"
from     dba_tables
where    OWNER not in ('SYS', 'SYSTEM')
group by OWNER
order by owner;

