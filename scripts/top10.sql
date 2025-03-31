------------------------------------------
---[-> SCRIPT NAME: TOP_10.sql
---[-> AUTHOR: ThieuVD
---[-> SĐT: 0961999962
---[-> FB: Cộng đồng chuyên gia Oracle - MongoDB - PostgreSQL - MySQL
---[-> https://www.facebook.com/groups/7874241609291138
------------------------------------------

WITH
    hist
    AS
        (  SELECT h.sql_id,
                  h.sql_plan_hash_value,
                  h.dbid,
                  COUNT (*)     samples
             FROM DBA_HIST_active_sess_history h
            WHERE     h.snap_id BETWEEN (SELECT MIN (SNAP_ID)
                                           FROM dba_hist_snapshot
                                          WHERE (begin_interval_time) >=
                                                SYSDATE - 7)
                                    AND (SELECT MAX (SNAP_ID)
                                           FROM dba_hist_snapshot
                                          WHERE (begin_interval_time) <=
                                                SYSDATE)
                  AND h.sql_id IS NOT NULL
                  AND h.sql_plan_hash_value > 0
         GROUP BY h.sql_id, h.sql_plan_hash_value, h.dbid),
    hist2
    AS
        (SELECT DISTINCT
                h.sql_id,
                h.sql_plan_hash_value,
                h.dbid,
                h.samples,
                CASE WHEN s.sql_id IS NOT NULL THEN samples ELSE 0 END
                    sql_samples,
                SUM (h.samples)
                    OVER (PARTITION BY h.dbid, h.sql_plan_hash_value)
                    plan_samples,
                DBMS_LOB.SUBSTR (s.sql_text, 1000)
                    sql_text
           FROM hist  h
                LEFT OUTER JOIN DBA_HIST_sqltext s
                    ON s.sql_id = h.sql_id AND s.dbid = h.dbid),
    hist3
    AS
        (SELECT hist2.*,
                ROW_NUMBER ()
                    OVER (PARTITION BY dbid, sql_plan_hash_value
                          ORDER BY sql_samples DESC)    sql_id_rank
           FROM hist2),
    hist4
    AS
        (SELECT hist3.*, ROW_NUMBER () OVER (ORDER BY sql_samples DESC) rn
           FROM hist3
          WHERE sql_id_rank = 1),
    total AS (SELECT SUM (samples) samples FROM hist),
    x
    AS
        (SELECT h.sql_id                                        top_sql_id,
                h.sql_plan_hash_value,
                                h.plan_samples,
                ROUND (100 * h.plan_samples / t.samples, 1)     "PERCENT(%)",
                h.sql_text
           FROM hist4 h, total t
          WHERE h.samples >= t.samples / 1000 AND h.rn <= 10
         UNION ALL
         SELECT 'Others',
                TO_NUMBER (NULL),
                NVL (SUM (h.plan_samples), 0)    samples,
                NVL (ROUND (100 * SUM (h.plan_samples) / AVG (t.samples), 1),
                     0)                          percent,
                NULL                             sql_text
           FROM hist4 h, total t
          WHERE h.plan_samples < t.samples / 1000 OR rn > 10)
  SELECT x.top_sql_id, x.sql_plan_hash_value, x."PERCENT(%)", x.sql_text
    FROM x
ORDER BY plan_samples DESC NULLS LAST;
