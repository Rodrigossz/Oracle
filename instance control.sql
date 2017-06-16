col host_name format a15

select 	INSTANCE_NUMBER        ,
		INSTANCE_NAME          ,
		HOST_NAME              ,
		VERSION                ,
		TO_CHAR(STARTUP_TIME, 'DD-MM-YY HH24:MI:SS') STARTUP_TIME,
		STATUS                 ,
		PARALLEL               ,
		THREAD#                ,
		ARCHIVER               ,
		LOG_SWITCH_WAIT        ,
		LOGINS                 ,
		SHUTDOWN_PENDING       ,
		DATABASE_STATUS        ,
		INSTANCE_ROLE          
From v$instance
/
