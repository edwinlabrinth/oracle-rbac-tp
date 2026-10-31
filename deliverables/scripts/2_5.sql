-- 2_5.sql : Exercice 2.5 -- ADMIN OPTION : pas de cascade
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. CREATE VIEW avec ADMIN OPTION pour A1, puis A1 le transmet a A2
GRANT CREATE VIEW TO a1 WITH ADMIN OPTION;
CONNECT a1/"A1#2026"@//localhost/FREEPDB1
GRANT CREATE VIEW TO a2;

-- 2. Revocation a A1
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
REVOKE CREATE VIEW FROM a1;

-- 3. A2 possede-t-il encore le privilege ?
CONNECT a2/"A2#2026"@//localhost/FREEPDB1
COLUMN privilege FORMAT A20
SELECT privilege FROM user_sys_privs WHERE privilege = 'CREATE VIEW';

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
COLUMN grantee FORMAT A10
PROMPT === DBA_SYS_PRIVS pour A1 et A2 ===
SELECT grantee, privilege, admin_option
  FROM dba_sys_privs
 WHERE grantee IN ('A1','A2') AND privilege = 'CREATE VIEW'
 ORDER BY grantee;
