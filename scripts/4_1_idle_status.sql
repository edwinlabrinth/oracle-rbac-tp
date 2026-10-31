-- 4_1_idle_status.sql : statut V$SESSION de LINA apres le snipe d'inactivite
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SET LINESIZE 120 PAGESIZE 50
COLUMN sid FORMAT A8
COLUMN serial# FORMAT A8
COLUMN status FORMAT A10
SELECT sid, serial#, status, last_call_et FROM v$session WHERE username = 'LINA';
EXIT
