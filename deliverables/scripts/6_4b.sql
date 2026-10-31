-- 6_4b.sql : Exercice 6.4 (T4) -- Contrôle des rôles et habilitations (requête corrigée)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

COLUMN utilisateur FORMAT A12
COLUMN role FORMAT A20
COLUMN table_name FORMAT A25
COLUMN privilege FORMAT A15
PROMPT === Privilèges objet effectifs via les rôles (contrôle E1/E2) ===
SELECT rp.grantee AS utilisateur, tp.grantee AS role, tp.table_name, tp.privilege
  FROM role_tab_privs tp
 JOIN dba_role_privs rp ON tp.grantee = rp.granted_role
 WHERE rp.grantee IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ')
 ORDER BY rp.grantee, tp.table_name, tp.privilege;

PROMPT === Aucun privilège système direct aux utilisateurs métier (E2) ===
COLUMN grantee FORMAT A12
COLUMN privilege FORMAT A30
SELECT grantee, privilege
  FROM dba_sys_privs
 WHERE grantee IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ','GUI3');

PROMPT === Aucun rôle DBA/CONNECT/RESOURCE direct aux utilisateurs métier (E2) ===
SELECT grantee, granted_role
  FROM dba_role_privs
 WHERE grantee IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ','GUI3')
   AND granted_role IN ('DBA','CONNECT','RESOURCE');

PROMPT === Arbre des rôles de DIR1 ===
SELECT LPAD(' ',2*(LEVEL-1)) || granted_role AS role
  FROM dba_role_privs
 START WITH grantee = 'DIR1'
 CONNECT BY PRIOR granted_role = grantee;
EXIT
