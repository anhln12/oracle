Cài đặt, cấu hình, quản trị Oracle Data Guard Physical Standby trong Oracle Database 11.2, 12c, 19c từ A-Z

Data Guard là  giải pháp cơ sở dữ liệu dự phòng của Oracle, được sử dụng trong trường hợp thảm họa (disaster recovery) và có tính khả dụng cao

Môi trường

Thiết lập Primary Server:
* Logging
* Tham số khởi tạo
* Cấu hình Service 
* Backup Primary Database
* Tạo Standby Controlfile và PFILE

Thiết lập Standby Server bằng giải pháp DUPLICATE:
* Copy Files
* Start Listener
* Tạo Standby Redo Logs trên Primary Server
* Tạo Standby sử dụng DUPLICATE

**Môi trường**
* Máy chủ chính (primary server: 10.255.68.21) có một instance đang chạy.
* Máy chủ dự phòng (standby server 10.255.68.22) chỉ cài đặt phần mềm Oracle Database

|Items|Primary – SRV1|Standby – SRV2|

|hostname|a|a|

**Thiết lập Primary Server**

Logging
Kiểm tra xem database chính có ở chế độ archivelog.
```
SELECT log_mode FROM v$database;
LOG_MODE
------------
NOARCHIVELOG
SQL>
```

Nếu database ở chế độ noarchivelog, chuyển sang archivelog.
```
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
SQL> ALTER DATABASE ARCHIVELOG;
Database altered.
SQL> ALTER DATABASE FORCE LOGGING;
Database altered.
SQL> ALTER DATABASE OPEN;
Database altered.
SQL> select FORCE_LOGGING,log_mode from v$database;
FORCE_LOGGING           LOG_MODE
—————————————           ————
YES                     ARCHIVELOG
```

**Khởi tạo các Standby Redo log group trên server primary để làm nhiệm vụ làm bộ đệm khi chuyển dữ liệu từ máy chủ primary sang máy chủ standby**

```
SQL> col member format a50
SQL> select GROUP#,TYPE,MEMBER from v$logfile;
    GROUP# TYPE    MEMBER
---------- ------- --------------------------------------------------
         3 ONLINE  /u02/oradata/ASIMDB/redo03.log
         2 ONLINE  /u02/oradata/ASIMDB/redo02.log
         1 ONLINE  /u02/oradata/ASIMDB/redo01.log
```
```
alter database add standby logfile group 4 '/u02/oradata/ASIMDB/redo04.log' size 50m;
alter database add standby logfile group 5 '/u02/oradata/ASIMDB/redo05.log' size 50m;
alter database add standby logfile group 6 '/u02/oradata/ASIMDB/redo06.log' size 50m;

SQL> SELECT GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS FROM V$STANDBY_LOG;
GROUP# THREAD# SEQUENCE# ARC STATUS
———- ———- ———- — ———-
4 0 0 YES UNASSIGNED
5 0 0 YES UNASSIGNED
6 0 0 YES UNASSIGNED
```
```
SQL>  select GROUP#,TYPE,MEMBER from v$logfile;

    GROUP# TYPE    MEMBER
---------- ------- --------------------------------------------------
         3 ONLINE  /u02/oradata/ASIMDB/redo03.log
         2 ONLINE  /u02/oradata/ASIMDB/redo02.log
         1 ONLINE  /u02/oradata/ASIMDB/redo01.log
         4 STANDBY /u02/oradata/ASIMDB/redo04.log
         5 STANDBY /u02/oradata/ASIMDB/redo05.log
         6 STANDBY /u02/oradata/ASIMDB/redo06.log

6 rows selected.
```

**Cấu hình Service**
Cấu hình "$ORACLE_HOME/network/admin/tnsnames.ora" trên cả hai máy chủ primary và standby cùng nội dung file
```
$ORACLE_HOME/network/admin/tnsnames.ora
asimdb =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.255.68.21)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = asimdb)
    )
  )

asimdbr =
  (DESCRIPTION =
    (ADDRESS_LIST =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.255.68.22)(PORT = 1521))
    )
    (CONNECT_DATA =
      (SID = asimdbr)
    )
  )
```

Cấu hình "$ORACLE_HOME/network/admin/listener.ora" trên cả hai máy chủ primary và standby

Primary
```
$ORACLE_HOME/network/admin/listener.ora
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.255.68.21)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = asimdb)
      (ORACLE_HOME = /u01/app/oracle/product/19.3.0/dbhome_1)
      (SID_NAME = asimdb)
      (ENVS="TNS_ADMIN=/u01/app/oracle/product/19.3.0/dbhome_1/network/admin")
    )
  )

ADR_BASE_LISTENER = /u01/app/oracle
```

Standby
```
$ORACLE_HOME/network/admin/listener.ora
LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 10.255.68.22)(PORT = 1521))
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = asimdbr)
      (ORACLE_HOME = /u01/app/oracle/product/19.3.0/dbhome_1)
      (SID_NAME = asimdbr)
      (ENVS="TNS_ADMIN=/u01/app/oracle/product/19.3.0/dbhome_1/network/admin")
    )
  )

ADR_BASE_LISTENER = /u01/app/oracle
```

Restart service on both servers
```
lsnrctl stop
lsnrctl start
```

Check lại cấu hình service trên 2 server primary và standby
```
tnsping asimdb
tnsping asimdbr
```

**Changing parameters in primary database**

Kiểm tra các thông số DB_NAME, DB_UNIQUE_NAME.
```
SQL> show parameter db_name;
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_name                              string      asimdb
SQL> show parameter db_unique_name
NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_unique_name                       string      asimdb
```

DB_NAME của cơ sở dữ liệu dự phòng sẽ giống với cơ sở dữ liệu chính, nhưng nó phải khác với DB_UNIQUE_NAME.

Các giá trị DB_UNIQUE_NAME của cơ sở dữ liệu chính và dữ liệu dự phòng được sử dụng trong thiết lập DB_CONFIG của tham số LOG_ARCHIVE_CONFIG

Đặt tham số log_archive_dest_2 trỏ vào standby database. Lưu ý service và db_unique_name của standby database


```
ALTER SYSTEM SET LOG_ARCHIVE_CONFIG='DG_CONFIG=(asimdb,asimdbr)';
ALTER SYSTEM SET log_archive_dest_1='location=use_db_recovery_file_dest valid_for=(all_logfiles,all_roles) db_unique_name=asimdb' SCOPE=both;
ALTER SYSTEM SET log_archive_dest_2='service=asimdbr async valid_for=(online_logfiles,primary_role) db_unique_name=asimdbr' SCOPE=both;
ALTER SYSTEM SET fal_server='ASIMDBR' SCOPE=both;
ALTER SYSTEM SET fal_client='ASIMDB' SCOPE=both;
ALTER SYSTEM SET standby_file_management='AUTO' SCOPE=both;
ALTER SYSTEM SET LOG_ARCHIVE_FORMAT='asimdb_%t_%s_%r.arc' SCOPE=SPFILE;
ALTER SYSTEM SET LOG_ARCHIVE_MAX_PROCESSES=30;
ALTER SYSTEM SET REMOTE_LOGIN_PASSWORDFILE=EXCLUSIVE SCOPE=SPFILE;
```

Lấy thông tin đường dẫn: control_files, core_dump_dest, audit_file_dest:
```
SQL> select name, value from v$parameter where upper(value) like upper('%/asimdb/%');

NAME
--------------------------------------------------------------------------------
VALUE
--------------------------------------------------------------------------------
control_files
/u02/oradata/ASIMDB/control01.ctl, /u02/oradata/ASIMDB/control02.ctl

core_dump_dest
/u01/app/oracle/diag/rdbms/asimdb/asimdb/cdump

audit_file_dest
/u01/app/oracle/admin/asimdb/adump
```
Check the password file
```
ls /u01/app/oracle/product/19.3.0/dbhome_1/dbs/orapw*
```

Copy password file từ Prim sang Stand và đổi tên
```
scp $ORACLE_HOME/dbs/orapwasimdb oracle@10.255.68.22:$ORACLE_HOME/dbs/orapwasimdbr
```

Có thể tạo lại file passowrd (Create a password file, with the SYS password matching that of the primary database.)
```
orapwd file=$ORACLE_HOME/dbs/orapwasimdb password=Password1 entries=10
=> orapwd file=/u01/app/oracle/product/19.3.0/dbhome_1/dbs/orapwasimdb password=SysPassword1 format=12
```

Create directory Structure in Standby database
```
mkdir -p $ORACLE_BASE/admin/asimdbr/adump
mkdir -p /u02/oradata/ASIMDBR

```

Changing parameters in standby database
```
cat initasimdbr.ora
db_name=asimdb
```

Start the standby database using pfile
```
startup pfile='/home/oracle/initasimdbr.ora' nomount;
```

Connect to the rman in standby database
```
rman target sys/SysPassword1@oradb auxiliary sys/SysPassword1@oradbr
```
