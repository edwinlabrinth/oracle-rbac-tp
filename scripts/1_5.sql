-- 1_5.sql : Exercice 1.5 -- Utilisateurs communs et locaux
SET LINESIZE 120 PAGESIZE 50

-- 1. Connexion a la racine CDB$ROOT
CONNECT / AS SYSDBA
SHOW CON_NAME
CREATE USER bob IDENTIFIED BY "Bob#2026";

-- 2. Creation d'un utilisateur commun dans tous les conteneurs
CREATE USER c##superviseur IDENTIFIED BY "Super#2026" CONTAINER=ALL;
GRANT CREATE SESSION TO c##superviseur CONTAINER=ALL;

-- 3. Retour dans la PDB : un nom commun est invalide pour un utilisateur local
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SHOW CON_NAME
CREATE USER c##test IDENTIFIED BY "Test#2026";

-- 4. Comparaison ALI (local) / C##SUPERVISEUR (commun)
COLUMN username FORMAT A18
COLUMN common FORMAT A6
SELECT username, common FROM dba_users
 WHERE username IN ('ALI','C##SUPERVISEUR')
 ORDER BY username;
