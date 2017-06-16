Meu amigo, vamos lá.

1 - Quando você está no sqlplus, para ver o plano de acesso de todo o comando executado, digite :

set autotrace traceonly exp   ---  Mostra o plano de acesso, sem executar o comando.
set autotrace traceonly   	      ---  Mostra o plano de acesso, mas vai executar o comando sem spool das linhas.
set autotrace on		      ---  Mostra o plano de acesso e executa completamente o comando, com o retorno das linhas
set autotrace off		      ---  Desliga o trace

2 - Para ver o plano de execução de um só comando, pode usar também o explain plan

explain plan for SQL_Statement;
