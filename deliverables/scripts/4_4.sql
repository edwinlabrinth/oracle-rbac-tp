-- 4_4.sql : Exercice 4.4 -- Complexite des mots de passe
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Etape 1 : verifier l'existence de ORA12C_VERIFY_FUNCTION (proprietaire SYS)
COLUMN object_name FORMAT A30
COLUMN object_type FORMAT A15
PROMPT === Verification de ORA12C_VERIFY_FUNCTION ===
SELECT object_name, object_type
  FROM dba_objects
 WHERE owner = 'SYS'
   AND object_name LIKE 'ORA12C%'
 ORDER BY object_name;

-- Etape 2 : associer la fonction de verification au profil P_RH_TEST
PROMPT === Association de ORA12C_VERIFY_FUNCTION a P_RH_TEST ===
ALTER PROFILE p_rh_test LIMIT PASSWORD_VERIFY_FUNCTION ORA12C_VERIFY_FUNCTION;

COLUMN resource_name FORMAT A30
COLUMN limit FORMAT A20
PROMPT === Fonction de verification de P_RH_TEST ===
SELECT resource_name, limit
  FROM dba_profiles
 WHERE profile = 'P_RH_TEST'
   AND resource_name = 'PASSWORD_VERIFY_FUNCTION';

-- Etape 3 : tentatives de mots de passe faibles (attendu ORA-28003)
-- Le mot de passe actuel de LINA est Lina#2032 (inchangé si les tentatives echouent)
CONNECT lina/"Lina#2032"@//localhost/FREEPDB1
PROMPT === Tentative mot de passe 'lina' (faible, attendu ORA-28003) ===
ALTER USER lina IDENTIFIED BY "lina";
PROMPT === Tentative mot de passe 'abcdefgh' (faible, attendu ORA-28003) ===
ALTER USER lina IDENTIFIED BY "abcdefgh";
PROMPT === Tentative mot de passe 'Lina2026x' (faible, attendu ORA-28003) ===
ALTER USER lina IDENTIFIED BY "Lina2026x";

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
-- Etape 4 : changement sans clause REPLACE (attendu ORA-28221)
PROMPT === Changement sans REPLACE (attendu ORA-28221) ===
ALTER USER lina IDENTIFIED BY "Lina#2033";
-- Etape 5 : changement avec clause REPLACE (attendu OK)
PROMPT === Changement avec REPLACE (attendu OK) ===
ALTER USER lina IDENTIFIED BY "Lina#2033" REPLACE "Lina#2032";

COLUMN account_status FORMAT A18
COLUMN expiry_date FORMAT A20
PROMPT === Etat de LINA apres changement ===
SELECT username, account_status, expiry_date FROM dba_users WHERE username = 'LINA';
EXIT
