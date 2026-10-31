-- 6_4c.sql : Exercice 6.4 (T4) -- Contrôle E1/E2 avec dba_tab_privs
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

COLUMN utilisateur FORMAT A12
COLUMN role FORMAT A20
COLUMN table_name FORMAT A25
COLUMN privilege FORMAT A15
PROMPT === Privilèges objet effectifs via les rôles (contrôle E1/E2) ===
SELECT rp.grantee AS utilisateur, tp.grantee AS role, tp.table_name, tp.privilege
  FROM dba_tab_privs tp
 JOIN dba_role_privs rp ON tp.grantee = rp.granted_role
 WHERE rp.grantee IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ')
 ORDER BY rp.grantee, tp.table_name, tp.privilege;
EXIT
