WITH
log AS (
SELECT        thread#,
       sequence#,
       first_time,
       blocks,
       block_size
  FROM v$archived_log
 WHERE first_time IS NOT NULL
),
log_denorm AS (
SELECT 
       TO_CHAR(TRUNC(first_time), 'YYYY-MM-DD') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), 'Dy') day,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '00', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '01', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '02', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '03', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '04', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '05', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '06', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '07', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '08', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '09', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '10', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '11', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '12', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '13', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '14', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '15', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '16', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '17', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '18', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '19', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '20', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '21', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '22', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, 'HH24'), '23', 1, 0)) h23,
       ROUND(SUM(blocks * block_size) / POWER(10,9), 1) TOT_GB,
       COUNT(*) cnt,
       ROUND(SUM(blocks * block_size) / POWER(10,9) / COUNT(*), 1) AVG_GB
  FROM log
 GROUP BY
       TRUNC(first_time)
 ORDER BY
       TRUNC(first_time) DESC
),
ordered_log AS (
SELECT 
       ROWNUM row_num_noprint, log_denorm.*
  FROM log_denorm
),
min_set AS (
SELECT 
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
)
SELECT 
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.row_num_noprint < ms.min_row_num + 30
 ORDER BY
       log.yyyy_mm_dd DESC;
