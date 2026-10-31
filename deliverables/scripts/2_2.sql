-- 2_2.sql : Exercice 2.2 -- Lire sans modifier
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. LECTEUR1 avec CREATE SESSION et lecture de RH.EMPLOYES
CREATE USER lecteur1 IDENTIFIED BY "Lect1#2026";
GRANT CREATE SESSION TO lecteur1;
GRANT SELECT ON rh.employes TO lecteur1;

-- 2. En LECTEUR1 : lire, tenter de modifier, lire une table non autorisee
CONNECT lecteur1/"Lect1#2026"@//localhost/FREEPDB1
SELECT COUNT(*) AS nb_employes FROM rh.employes;
UPDATE rh.employes SET salaire = 1;
SELECT * FROM rh.departements;

-- 3. Remplacement de SELECT par READ
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
REVOKE SELECT ON rh.employes FROM lecteur1;
GRANT READ ON rh.employes TO lecteur1;

CONNECT lecteur1/"Lect1#2026"@//localhost/FREEPDB1
SELECT COUNT(*) AS nb_employes FROM rh.employes;
SELECT * FROM rh.employes FOR UPDATE;
