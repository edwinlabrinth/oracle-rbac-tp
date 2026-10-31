-- 3_4.sql : Exercice 3.4 -- Role protege et roles par defaut
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. Protection du role par mot de passe
ALTER ROLE r_rh_paie IDENTIFIED BY "Paie#2026";

PROMPT === Sara se reconnecte : le role par defaut est-il actif sans mot de passe ? ===
CONNECT sara/"Sara#2026"@//localhost/FREEPDB1
COLUMN role FORMAT A20
SELECT role FROM session_roles ORDER BY role;
SELECT COUNT(*) AS employes FROM rh.employes;

-- 2. Seul R_CONNEXION actif a la connexion de Sara
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
GRANT r_connexion TO sara;
ALTER USER sara DEFAULT ROLE r_connexion;

COLUMN granted_role FORMAT A20
COLUMN default_role FORMAT A12
PROMPT === DBA_ROLE_PRIVS pour SARA ===
SELECT granted_role, default_role
  FROM dba_role_privs WHERE grantee = 'SARA'
 ORDER BY granted_role;

PROMPT === Sara apres restriction des roles par defaut ===
CONNECT sara/"Sara#2026"@//localhost/FREEPDB1
SELECT role FROM session_roles ORDER BY role;
SELECT COUNT(*) AS employes FROM rh.employes;

-- 3. Activation du role protege : mauvais mot de passe puis bon mot de passe
PROMPT === SET ROLE avec un mauvais mot de passe ===
SET ROLE r_rh_paie IDENTIFIED BY "mauvais";
PROMPT === SET ROLE avec le bon mot de passe ===
SET ROLE r_rh_paie IDENTIFIED BY "Paie#2026";
SELECT role FROM session_roles ORDER BY role;
SELECT COUNT(*) AS employes FROM rh.employes;
UPDATE rh.employes SET salaire = 99999 WHERE emp_id = 3;
ROLLBACK;
