-- 3_2.sql : Exercice 3.2 -- Lire la hierarchie dans le dictionnaire
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. Roles accordes directement a OMAR
COLUMN granted_role FORMAT A20
COLUMN default_role FORMAT A12
PROMPT === DBA_ROLE_PRIVS pour OMAR ===
SELECT granted_role, admin_option, default_role
  FROM dba_role_privs WHERE grantee = 'OMAR'
 ORDER BY granted_role;

-- 2. Arbre complet des roles d'OMAR
COLUMN arbre FORMAT A40
PROMPT === Arbre des roles d'OMAR (CONNECT BY) ===
SELECT LPAD(' ', 2 * (LEVEL - 1)) || granted_role AS arbre
  FROM dba_role_privs
 START WITH grantee = 'OMAR'
 CONNECT BY PRIOR granted_role = grantee;

-- 3. Privileges objet directs ou via les roles de l'arbre
COLUMN source FORMAT A8
COLUMN grantee FORMAT A16
COLUMN owner FORMAT A8
COLUMN table_name FORMAT A16
COLUMN privilege FORMAT A12
COLUMN column_name FORMAT A12
PROMPT === Privileges objet d'OMAR (directs + via roles) ===
WITH roles AS (
  SELECT granted_role AS r
    FROM dba_role_privs
   START WITH grantee = 'OMAR'
   CONNECT BY PRIOR granted_role = grantee
)
SELECT 'TABLE' AS source, grantee, owner, table_name, privilege,
       CAST(NULL AS VARCHAR2(30)) AS column_name
  FROM dba_tab_privs
 WHERE grantee = 'OMAR' OR grantee IN (SELECT r FROM roles)
UNION ALL
SELECT 'COLONNE', grantee, owner, table_name, privilege, column_name
  FROM dba_col_privs
 WHERE grantee = 'OMAR' OR grantee IN (SELECT r FROM roles)
 ORDER BY 1, 2, 3, 4, 5, 6;

PROMPT === ROLE_TAB_PRIVS pour les roles de l'arbre ===
COLUMN role FORMAT A16
SELECT role, owner, table_name, column_name, privilege
  FROM role_tab_privs
 WHERE role IN (
   SELECT granted_role FROM dba_role_privs
    START WITH grantee = 'OMAR'
    CONNECT BY PRIOR granted_role = grantee)
 ORDER BY role, table_name, column_name, privilege;
