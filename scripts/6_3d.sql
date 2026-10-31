-- 6_3d.sql : Exercice 6.3 (T3 suite) -- Recréation APP_BATCH (mot de passe conforme)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

PROMPT === Recréation APP_BATCH (mot de passe conforme P_BQ_SERVICE) ===
CREATE USER app_batch IDENTIFIED BY "BAtch##2026!" PROFILE p_bq_service;

COLUMN username FORMAT A12
COLUMN profile FORMAT A14
COLUMN account_status FORMAT A12
PROMPT === Comptes finaux ===
SELECT username, profile, account_status
  FROM dba_users
 WHERE username IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ')
 ORDER BY username;
EXIT
