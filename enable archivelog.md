Enable Archivelog Step by step by Le Anh with user Oracle

step 01: shutdown database
```
SQL> shut immediate;
```
step 02: startup nomount;
```
SQL>startup nomount;
```
step 03: config prameter:
```
mkdir -p /u02/archivelog
SQL> alter system set log_archive_start=TRUE scope=spfile; 
System altered. 
SQL> alter system set db_recovery_file_dest='/u02/archivelog' scope=spfile;
System altered.
SQL> alter system set log_archive_format='arch_%t_%s_%r.arc' scope=spfile;
System altered.
```
step 04: Now we mount the database instance:
SQL> alter database mount; 
Database altered.

Step 05: And finally, we set the database to archive log mode:
SQL> alter database archivelog;
Database altered.

Step 06: open database;
SQL> alter database open;

step 07: check archivelog
SQL> archive log list;

switch log
ALTER SYSTEM SWITCH LOGFILE;

Thanks;
