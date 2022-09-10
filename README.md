# oracle

 select name, open_mode from v$pdbs;
 alter session set container=orclpdb;
 
 ==mysql==
mysql> select id, phone, uid from vnphone INTO OUTFILE '/tmp/vn.txt';
ERROR 1290 (HY000): The MySQL server is running with the --secure-file-priv option so it cannot execute this statement

sed s/\\t/,/g vn.txt > vn.txt
 
 ==oracle==
 create table
 create table vn_20220910 (id number(15), msisdn varchar2(15), "uid" varchar2(30));
 
 cat /home/oracle/example1.ctl
 load data
 infile '/home/oracle/vn.txt'
 into table user_tool.vn_20220910
 fields terminated by ","
 ( id, msisdn, "uid" )
 
 sqlldr user_tool/ control='/home/oracle/example1.ctl' log='/home/oracle/example1.log'
