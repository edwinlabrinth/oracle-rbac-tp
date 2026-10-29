-- 2_3.sql : Exercice 2.3 -- Droits par colonne, SQL92_SECURITY et vue
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. OMAR : modification du poste et du departement uniquement
CREATE USER omar IDENTIFIED BY "Omar#2026";
GRANT CREATE SESSION TO omar;
GRANT UPDATE (poste, dept_id) ON rh.employes TO omar;

-- 2. Trois UPDATE successifs (puis ROLLBACK a chaque fois)
CONNECT omar/"Omar#2026"@//localhost/FREEPDB1
UPDATE rh.employes SET salaire = 99999;
ROLLBACK;
UPDATE rh.employes SET poste = 'Architecte' WHERE emp_id = 3;
ROLLBACK;
UPDATE rh.employes SET poste = 'Architecte';
ROLLBACK;

-- Parametre SQL92_SECURITY
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SHOW PARAMETER sql92_security

-- 3. Solution par la vue RH.V_ANNUAIRE (sans exposer les salaires)
GRANT SELECT, UPDATE (poste, dept_id) ON rh.v_annuaire TO omar;
REVOKE UPDATE (poste, dept_id) ON rh.employes FROM omar;

CONNECT omar/"Omar#2026"@//localhost/FREEPDB1
UPDATE rh.v_annuaire SET poste = 'Architecte' WHERE emp_id = 3;
SELECT emp_id, nom, poste FROM rh.v_annuaire WHERE emp_id = 3;
ROLLBACK;
UPDATE rh.v_annuaire SET salaire = 99999 WHERE emp_id = 3;

-- 4. Controle des privileges detenus par OMAR
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
COLUMN owner FORMAT A8
COLUMN table_name FORMAT A16
COLUMN column_name FORMAT A14
COLUMN grantee FORMAT A10
COLUMN privilege FORMAT A10
PROMPT === DBA_COL_PRIVS pour OMAR ===
SELECT owner, table_name, column_name, privilege, grantee
  FROM dba_col_privs WHERE grantee = 'OMAR';
PROMPT === DBA_TAB_PRIVS pour OMAR ===
SELECT owner, table_name, privilege, grantable, grantee
  FROM dba_tab_privs WHERE grantee = 'OMAR';
