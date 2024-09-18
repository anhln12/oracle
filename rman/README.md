**Rman default**
```
RMAN> show all;  

using target database control file instead of recovery catalog
RMAN configuration parameters for database with db_unique_name TELCODEV01 are:
CONFIGURE RETENTION POLICY TO REDUNDANCY 1; # default
CONFIGURE BACKUP OPTIMIZATION OFF; # default => CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE DEFAULT DEVICE TYPE TO DISK; # default
CONFIGURE CONTROLFILE AUTOBACKUP ON; # default
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '%F'; # default
CONFIGURE DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET; # default => CONFIGURE DEVICE TYPE DISK PARALLELISM 4 BACKUP TYPE TO BACKUPSET;
CONFIGURE DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK TO 1; # default
CONFIGURE MAXSETSIZE TO UNLIMITED; # default
CONFIGURE ENCRYPTION FOR DATABASE OFF; # default
CONFIGURE ENCRYPTION ALGORITHM 'AES128'; # default
CONFIGURE COMPRESSION ALGORITHM 'BASIC' AS OF RELEASE 'DEFAULT' OPTIMIZE FOR LOAD TRUE ; # default
CONFIGURE RMAN OUTPUT TO KEEP FOR 7 DAYS; # default
CONFIGURE ARCHIVELOG DELETION POLICY TO NONE; # default
CONFIGURE SNAPSHOT CONTROLFILE NAME TO '/u01/app/oracle/product/19.3.0/dbhome_1/dbs/snapcf_telcodev01.f'; # default

RMAN>
```

**RETENTION POLICY**

Cấu hình đầu tiên ta thấy là retention policy, cấu hình việc lưu giữ các bản backup.

Retention policy có thể cấu hình theo 1 trong 2 tiêu chí:
* Recovery window: xác định số ngày mà ta có thể restore đến bất cứ thời điểm nào trong thời gian đó. VD khi cấu hình 7 ngày, RMAN sẽ tự tính toán lưu giữ lại các bản backup full/incremental, archivelog sao cho có khả năng restore lại bất kỳ thời điểm nào trong 7 ngày trở lại đây.
* Redundancy: xác định số bản backup full/level 0 của datafile và control file cần lưu giữ. Mặc định là 1, tức là luôn lưu giữ ít nhất 1 bản backup full/level 0.

 
**BACKUP OPTIMIZATION**

Mặc định là OFF. Nếu set về ON, khi backup RMAN sẽ kiểm tra xem datafile/archivelog/backupset đã có bản backup tương tự chưa, nếu có thì bỏ qua không cần backup.
```
RMAN> CONFIGURE BACKUP OPTIMIZATION ON;
```

**DEVICE TYPE
**
Vị trí backup mặc định nếu ko chỉ định vị trí khi backup, nếu là DISK không đặt vị trí, RMAN sẽ backup mặc định vào vùng FRA.

**CONTROLFILE AUTOBACKUP**

Cấu hình backup controlfile tự động bất kỳ khi nào thực hiện backup hay có thay đổi cấu trúc diễn database, chẳng hạn như tạo thêm tablespace, add thêm datafile.

**CONTROLFILE AUTOBACKUP FORMAT**

Chỉ định format tên file autobackup của controlfile

DEVICE TYPE DISK PARALLELISM 1 BACKUP TYPE TO BACKUPSET

Cấu hình số parallel và backup type mặc định là backupset khi backup ra disk

**DATAFILE BACKUP COPIES FOR DEVICE TYPE DISK**

Xác định số bản backup datafile được thực hiện (3 => mirror 3 bản backup ở các vị trí khác nhau)

**ARCHIVELOG BACKUP COPIES FOR DEVICE TYPE DISK**

Xác định số bản backup archivelog được thực hiện

**MAXSETSIZE**

Đặt kích thước tối đa cho backupset. Mặc định là UNLIMITED

**ARCHIVELOG DELETION POLICY**

Tham số này liên quan đến việc xóa tự động archivelog
**
SNAPSHOT CONTROLFILE NAME**

Snapshot controlfile được tạo ra khi đồng bộ với recovery catalog hoặc khi thực hiện backup controlfile để đảm bảo tính ổn định (read consistent)
Mặc định snapshot controlfile được lưu trong ORACLE_HOME/dbs

Để reset bất kỳ cấu hình về mặc định, ta dùng từ khóa "CLEAR" sau cấu hình, ví dụ
```
RMAN> CONFIGURE COMPRESSION ALGORITHM CLEAR;
```




