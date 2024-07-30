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


**Change Archivelog Destination In Oracle**
Step 1: Check archivelog location before change
```
Check Current Archivelog Location:

SQL> archive log list
Database log mode Archive Mode
Automatic archival Enabled
Archive destination /u01/app/oracle/product/19.3.0/db_1/dbs/arch
Oldest online log sequence 29
Next log sequence to archive 31
Current log sequence 31
SQL> archive log list
Database log mode Archive Mode
Automatic archival Enabled
Archive destination /u01/app/oracle/product/19.3.0/db_1/dbs/arch
Oldest online log sequence 29
Next log sequence to archive 31
Current log sequence 31
```
Step 2: Change archivelog location
```
SQL> show parameter db_recovery_file_dest
NAME TYPE VALUE
———————————— ———– ——————————
db_recovery_file_dest string
db_recovery_file_dest_size big integer 0

Note:- 1st set the FRA value before  changing

SQL> alter system set db_recovery_file_dest_size=100g scope=both;
System altered.
Before Changing the location check FRA directory

SQL> alter system set db_recovery_file_dest='/u02/archivelog' scope=both;
System altered.
```

Step 3: Check the status of archivelog location 
```
SQL> archive log list
Database log mode Archive Mode
Automatic archival Enabled
Archive destination USE_DB_RECOVERY_FILE_DEST
Oldest online log sequence 29
Next log sequence to archive 31
Current log sequence 31

Switch the redologfile and archivelog gentrated in the FRA location
SQL> alter system switch logfile;
System altered.
```


