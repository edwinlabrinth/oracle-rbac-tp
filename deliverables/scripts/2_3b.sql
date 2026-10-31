-- 2_3b.sql : Exercice 2.3 (suite) -- revocation reelle des droits sur la table
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Un REVOKE par colonne est refuse (ORA-01750) : on revoque UPDATE sur toute la table.
REVOKE UPDATE ON rh.employes FROM omar;

PROMPT === DBA_COL_PRIVS pour OMAR apres revocation ===
COLUMN owner FORMAT A8
COLUMN table_name FORMAT A16
COLUMN column_name FORMAT A14
COLUMN privilege FORMAT A10
COLUMN grantee FORMAT A10
SELECT owner, table_name, column_name, privilege, grantee
  FROM dba_col_privs WHERE grantee = 'OMAR';
PROMPT === DBA_TAB_PRIVS pour OMAR apres revocation ===
SELECT owner, table_name, privilege, grantable, grantee
  FROM dba_tab_privs WHERE grantee = 'OMAR';

-- En OMAR : la table redevient inaccessible en modification, la vue reste utilisable
CONNECT omar/"Omar#2026"@//localhost/FREEPDB1
UPDATE rh.employes SET poste = 'Architecte' WHERE emp_id = 3;
UPDATE rh.v_annuaire SET poste = 'Architecte' WHERE emp_id = 3;
ROLLBACK;
