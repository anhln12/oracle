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
* Máy chủ chính (primary server: 192.168.1.10) có một instance đang chạy.
* Máy chủ dự phòng (standby server 192.168.1.11) chỉ cài đặt phần mềm Oracle Database
