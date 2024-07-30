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


