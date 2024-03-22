Kết nối bằng RMAN

rman target /
 

Crosscheck lại các archive log

crosscheck archivelog all;
 
Kiểm tra các archive log hiện có

list archivelog all;
list archivelog sequence 1492 thread 2;
 

Xóa archive log dựa trên thời gian
```
delete archivelog until time 'sysdate-3';
delete archivelog from time 'sysdate-1';
delete archivelog from time 'sysdate-1' until time 'sysdate-2';
```

Xóa archive log dựa trên số sequence của nó
```
delete archivelog from sequence 1000;
delete archivelog until sequence 1500;
delete archivelog from sequence 1000 until sequence 1500;
``` 

Xóa các archive log đã được backup
```
delete expired archivelog all;
`` 

Xóa tất cả archive log hiện có
```
delete archivelog all;
``` 

Xóa bắt buộc archive log
Sử dụng trong trường hợp không xóa archive log được, do Oracle nhận thấy archive log vẫn còn cần thiết cho standby database.

delete force archive log all;
delete force archive log until time 'sysdate-3';
 
Xóa archive log trên standby database
delete archivelog all completed before 'sysdate-2';
