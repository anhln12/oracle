
------------------------------------------
---[-> SCRIPT NAME: LOG_GRANT.sql
---[-> AUTHOR: ThieuVD
---[-> SĐT: 0961999962
---[-> FB: Cộng đồng chuyên gia Oracle - MongoDB - PostgreSQL - MySQL
---[-> https://www.facebook.com/groups/7874241609291138
------------------------------------------

----- 0. Check dữ liệu
  SELECT *
    FROM SYS.LOG_GRANT
   WHERE action_date > SYSDATE - 3
ORDER BY action_date DESC;

----- 1. Tạo bảng lưu log
CREATE TABLE SYS.LOG_GRANT
(
  ACTION_DATE  DATE,
  PVS_NAME     VARCHAR2(15 BYTE),
  PRIVILEGE    VARCHAR2(30 BYTE),
  OWNER        VARCHAR2(20 BYTE),
  OBJECT_NAME  VARCHAR2(30 BYTE),
  USERNAME     VARCHAR2(30 BYTE),
  LOGIN_USER   VARCHAR2(20 BYTE),
  IP_ADDRESS   VARCHAR2(15 BYTE)
)
NOCOMPRESS 
TABLESPACE USERS
PARTITION BY RANGE (ACTION_DATE)
INTERVAL(NUMTOYMINTERVAL(1, 'MONTH')) 
(  
   PARTITION SYS_P201701 VALUES LESS THAN (TO_DATE(' 2017-02-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')) TABLESPACE USERS,
   PARTITION SYS_P201702 VALUES LESS THAN (TO_DATE(' 2017-03-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')) TABLESPACE USERS
); 

CREATE INDEX SYS.LOG_GRANT_IDX1 ON SYS.LOG_GRANT
(ACTION_DATE)
LOCAL;

----- 2. Tạo trigger
CREATE OR REPLACE TRIGGER SYS.GRANT_TRIGGER
    AFTER GRANT OR REVOKE
    ON DATABASE
DECLARE
    CURSOR c_database_role IS
        SELECT 1
          FROM v$database
         WHERE database_role IN ('PRIMARY');

    priv              DBMS_STANDARD.ora_name_list_t;
    who               DBMS_STANDARD.ora_name_list_t;
    npriv             PLS_INTEGER;
    nwho              PLS_INTEGER;
    v_database_role   NUMBER;
BEGIN
    OPEN c_database_role;

    FETCH c_database_role INTO v_database_role;

    IF c_database_role%FOUND
    THEN
        npriv := ora_privilege_list (priv);

        IF (ora_sysevent = 'GRANT')
        THEN
            nwho := ora_grantee (who);
        ELSE
            nwho := ora_revokee (who);
        END IF;

        FOR i IN 1 .. npriv
        LOOP
            FOR j IN 1 .. nwho
            LOOP
                INSERT INTO SYS.LOG_GRANT
                     VALUES (SYSTIMESTAMP,
                             ora_sysevent,
                             priv (i),
                             ora_dict_obj_owner,
                             ora_dict_obj_name,
                             who (j),
                             ora_login_user,
                             SYS_CONTEXT ('USERENV', 'IP_ADDRESS'));
            END LOOP;
        END LOOP;
    END IF;

    CLOSE c_database_role;
END;
/
