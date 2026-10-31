-- 0_test.sql : test de l'outillage (connexion SYS, PDB, tablespaces)
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SHOW CON_NAME
SELECT USER FROM dual;
SELECT tablespace_name FROM dba_tablespaces;
