-- chu_5_1.sql : Chapitre 5.1 -- Etat de l'audit standard
SET LINESIZE 120 PAGESIZE 50
CONNECT / AS SYSDBA
SHOW CON_NAME
-- Monter dans la PDB si besoin
ALTER SESSION SET CONTAINER = FREEPDB1;

COLUMN name FORMAT A30
COLUMN value FORMAT A20
PROMPT === AUDIT_TRAIL, AUDIT_SYS_OPERATIONS, AUDIT_FILE_DEST ===
SELECT name, value FROM v$parameter WHERE name IN ('audit_trail','audit_sys_operations','audit_file_dest');
EXIT
