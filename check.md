

# Check phân đoạn bộ nhớ dùng chung thực tế
```
ipcs -m

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x00000000 2122121238 oracle     600        15986688   352
0x00000000 2122121239 oracle     600        42815455232 176
0x00000000 2122121240 oracle     600        118231040  176
0x3929de6c 2122121241 oracle     600        32768      176
```

0x00000000 2122121239 oracle     600        42815455232 176 => Bytes: 42,815,455,232 bytes ~ 39.87 GB.

# Tìm top 10 Process ngốn RAM ở OS
```
ps -eo pid,user,rss,pmem,args --sort=-rss | head -10

    PID USER       RSS %MEM COMMAND
2337642 oracle   36934172 59.9 ora_dbw0_oradr01
2337662 oracle   15614900 25.3 ora_w001_oradr01
2339980 oracle   15610976 25.3 ora_w00f_oradr01
2339973 oracle   15555816 25.2 ora_w00d_oradr01
2339969 oracle   15543384 25.2 ora_w00b_oradr01
2338846 oracle   15529212 25.1 ora_w006_oradr01
2339022 oracle   15516000 25.1 ora_w007_oradr01
2340085 oracle   15503256 25.1 ora_w00n_oradr01
2339971 oracle   15501728 25.1 ora_w00c_oradr01
```

Tiến trình ora_dbw0_oradr01 (PID 2337642): Đang báo chiếm 36.9 GB RAM. Đây là tiến trình Database Writer, nó chịu trách nhiệm ghi dữ liệu từ Buffer Cache xuống đĩa. Con số này chính là phần lớn vùng SGA mà bạn đã cấu hình (40GB)

# Tìm các lệnh SQL đang chiếm RAM trong Database
```
SELECT * FROM (
    SELECT 
        s.sid, 
        s.serial#, 
        s.username, 
        s.program, 
        p.pga_alloc_mem/1024/1024 "Allocated (MB)", 
        p.pga_used_mem/1024/1024 "Used (MB)",
        q.sql_id,
        SUBSTR(q.sql_text, 1, 60) "SQL Text"
    FROM v$session s
    JOIN v$process p ON s.paddr = p.addr
    LEFT JOIN v$sql q ON s.sql_id = q.sql_id
    WHERE s.type = 'USER'
    ORDER BY p.pga_alloc_mem DESC
) WHERE rownum <= 10;
```
