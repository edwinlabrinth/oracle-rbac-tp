-- 6_3b.sql : Exercice 6.3 (T3 suite) -- Recréation des comptes refusés (complexité)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

PROMPT === Recréation GUI1, GUI2, CONS1, APP_BATCH (mots de passe conformes) ===
CREATE USER gui1 IDENTIFIED BY "Ag1#Banque2026" PROFILE p_bq_agent;
CREATE USER gui2 IDENTIFIED BY "Ag2#Banque2026" PROFILE p_bq_agent;
CREATE USER cons1 IDENTIFIED BY "Cn1#Conseil2026" PROFILE p_bq_conseil;
CREATE USER app_batch IDENTIFIED BY "Bt1#Batch2026" PROFILE p_bq_service;

COLUMN username FORMAT A12
COLUMN profile FORMAT A14
COLUMN account_status FORMAT A12
PROMPT === Comptes finaux ===
SELECT username, profile, account_status
  FROM dba_users
 WHERE username IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ')
 ORDER BY username;
EXIT
