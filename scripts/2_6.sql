-- 2_6.sql : Exercice 2.6 -- Le danger des privileges ANY
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. SELECT ANY TABLE pour A2
GRANT SELECT ANY TABLE TO a2;

-- 2. En A2 : portee reelle du privilege
CONNECT a2/"A2#2026"@//localhost/FREEPDB1
SELECT COUNT(*) AS rh_employes FROM rh.employes;
SELECT COUNT(*) AS dev1_projets FROM dev1.projets;
SELECT COUNT(*) AS sys_user_dollar FROM sys.user$;

-- 3. Comptes non Oracle detenant un privilege ANY direct
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
COLUMN username FORMAT A16
COLUMN privilege FORMAT A28
PROMPT === Comptes non Oracle avec un privilege systeme contenant ANY ===
SELECT u.username, p.privilege
  FROM dba_sys_privs p
  JOIN dba_users u ON u.username = p.grantee
 WHERE u.oracle_maintained = 'N'
   AND p.privilege LIKE '%ANY%'
 ORDER BY u.username, p.privilege;

-- Revocation
REVOKE SELECT ANY TABLE FROM a2;
