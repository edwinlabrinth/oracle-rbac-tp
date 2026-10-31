-- 4_2.sql : Exercice 4.2 -- Verrouillage apres echecs
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

ALTER PROFILE p_rh_test LIMIT
  FAILED_LOGIN_ATTEMPTS 3
  PASSWORD_LOCK_TIME 2/1440;

COLUMN profile FORMAT A14
COLUMN resource_name FORMAT A30
COLUMN limit FORMAT A12
PROMPT === Parametres de verrouillage de P_RH_TEST ===
SELECT resource_name, limit
  FROM dba_profiles
 WHERE profile = 'P_RH_TEST'
   AND resource_name IN ('FAILED_LOGIN_ATTEMPTS','PASSWORD_LOCK_TIME');

-- Trois mauvais mots de passe, puis le bon
PROMPT === Tentative 1 (mauvais) ===
CONNECT lina/"faux"@//localhost/FREEPDB1
PROMPT === Tentative 2 (mauvais) ===
CONNECT lina/"faux"@//localhost/FREEPDB1
PROMPT === Tentative 3 (mauvais) : le compte se verrouille ===
CONNECT lina/"faux"@//localhost/FREEPDB1
PROMPT === Tentative 4 avec le bon mot de passe (compte verrouille) ===
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
COLUMN account_status FORMAT A18
COLUMN lock_date FORMAT A20
PROMPT === Etat du compte LINA ===
SELECT username, account_status, lock_date
  FROM dba_users WHERE username = 'LINA';

-- Attente > PASSWORD_LOCK_TIME (2 minutes) puis reconnexion OK
PROMPT === Attente de 130 secondes ( > 2 minutes de verrouillage) ===
HOST sleep 130
PROMPT === Reconnexion de LINA (deverrouillage automatique) ===
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1
SELECT USER AS utilisateur FROM dual;
