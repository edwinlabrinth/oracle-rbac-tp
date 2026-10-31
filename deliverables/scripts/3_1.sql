-- 3_1.sql : Exercice 3.1 -- Construire la matrice RBAC du service RH
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 2. Comptes LINA et SARA, et retrait des droits directs d'OMAR (chapitre 2)
CREATE USER lina IDENTIFIED BY "Lina#2026";
CREATE USER sara IDENTIFIED BY "Sara#2026";

REVOKE CREATE SESSION FROM omar;
REVOKE SELECT ON rh.v_annuaire FROM omar;
REVOKE UPDATE ON rh.v_annuaire FROM omar;

-- 3. Roles et alimentation
CREATE ROLE r_connexion;
GRANT CREATE SESSION TO r_connexion;

CREATE ROLE r_rh_lecteur;
GRANT SELECT ON rh.departements TO r_rh_lecteur;
GRANT SELECT ON rh.v_annuaire TO r_rh_lecteur;
GRANT r_connexion TO r_rh_lecteur;

CREATE ROLE r_rh_gestion;
GRANT r_rh_lecteur TO r_rh_gestion;
GRANT SELECT, INSERT ON rh.employes TO r_rh_gestion;
GRANT UPDATE (poste, dept_id) ON rh.employes TO r_rh_gestion;
GRANT r_connexion TO r_rh_gestion;

CREATE ROLE r_rh_paie;
GRANT SELECT ON rh.employes TO r_rh_paie;
GRANT UPDATE (salaire) ON rh.employes TO r_rh_paie;
GRANT r_connexion TO r_rh_paie;

-- Attribution aux utilisateurs
GRANT r_rh_lecteur TO lina;
GRANT r_rh_gestion TO omar;
GRANT r_rh_paie TO sara;

-- 4. Verification par compte
PROMPT ================= LINA =================
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1
COLUMN role FORMAT A20
SELECT role FROM session_roles ORDER BY role;
SELECT COUNT(*) AS departements FROM rh.departements;
SELECT COUNT(*) AS annuaire FROM rh.v_annuaire;
SELECT COUNT(*) AS employes_salaires FROM rh.employes;

PROMPT ================= OMAR =================
CONNECT omar/"Omar#2026"@//localhost/FREEPDB1
SELECT role FROM session_roles ORDER BY role;
SELECT COUNT(*) AS employes FROM rh.employes;
UPDATE rh.employes SET poste = 'Architecte' WHERE emp_id = 3;
ROLLBACK;
UPDATE rh.employes SET salaire = 99999 WHERE emp_id = 3;

PROMPT ================= SARA =================
CONNECT sara/"Sara#2026"@//localhost/FREEPDB1
SELECT role FROM session_roles ORDER BY role;
SELECT COUNT(*) AS employes FROM rh.employes;
UPDATE rh.employes SET salaire = 99999 WHERE emp_id = 3;
ROLLBACK;
UPDATE rh.employes SET poste = 'Architecte' WHERE emp_id = 3;
SELECT COUNT(*) AS departements FROM rh.departements;

PROMPT ================= Etat des droits directs d'OMAR =================
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SELECT owner, table_name, privilege, grantee
  FROM dba_tab_privs WHERE grantee = 'OMAR';
SELECT owner, table_name, column_name, privilege, grantee
  FROM dba_col_privs WHERE grantee = 'OMAR';
