-- chu_5_2.sql : Chapitre 5.2 -- Configuration de l'audit standard
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. Connexions echouees
PROMPT === 1. Audit des connexions echouees ===
AUDIT SESSION WHENEVER NOT SUCCESSFUL;

-- 2. Ordres echouant car objet inexistant ou invisible
PROMPT === 2. Audit NOT EXISTS ===
AUDIT NOT EXISTS;

-- 3. Toutes lectures/modifications/suppressions des dossiers medicaux, BY ACCESS
PROMPT === 3. Audit dossiers_medicaux (SELECT, INSERT, UPDATE, DELETE) BY ACCESS ===
AUDIT SELECT, INSERT, UPDATE, DELETE ON chu.dossiers_medicaux BY ACCESS;

-- 4. Suppressions de patients, UPDATE de factures qui echouent
PROMPT === 4. Audit DELETE patients et UPDATE factures WHENEVER NOT SUCCESSFUL ===
AUDIT DELETE ON chu.patients;
AUDIT UPDATE ON chu.factures WHENEVER NOT SUCCESSFUL;

-- 5. Gestion des utilisateurs, des rôles, et GRANT/REVOKE de privilèges système et de rôles
PROMPT === 5. Audit USER, ROLE, SYSTEM GRANT ===
AUDIT USER;
AUDIT ROLE;
AUDIT SYSTEM GRANT;

-- 6. Tout accès à la table SYS.AUD$ elle-même
PROMPT === 6. Audit SELECT sur SYS.AUD$ ===
AUDIT SELECT ON sys.aud$;

COLUMN user_name FORMAT A15
COLUMN privilege FORMAT A30
COLUMN object_name FORMAT A30
COLUMN option_name FORMAT A20
PROMPt === Verification dans DBA_STMT_AUDIT_OPTS ===
SELECT user_name, privilege, option_name
  FROM dba_stmt_audit_opts
 WHERE user_name IS NULL OR user_name IN ('SYS')
 ORDER BY privilege, option_name;

PROMPt === Verification dans DBA_OBJ_AUDIT_OPTS ===
SELECT object_owner, object_name, column_name, sel, ins, upd, del
  FROM dba_obj_audit_opts
 WHERE object_owner IN ('CHU','SYS')
 ORDER BY object_owner, object_name;
EXIT
