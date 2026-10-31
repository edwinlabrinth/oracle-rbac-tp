-- 4_5.sql : Exercice 4.5 -- Profil de production P_RH_STANDARD et synthese
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Creation du profil de production P_RH_STANDARD (de l'atelier 4.1 : limites raisonnables)
PROMPT === Creation du profil P_RH_STANDARD ===
CREATE PROFILE p_rh_standard LIMIT
  SESSIONS_PER_USER 2
  IDLE_TIME 30
  FAILED_LOGIN_ATTEMPTS 3
  PASSWORD_LOCK_TIME 1/1440
  PASSWORD_LIFE_TIME 90
  PASSWORD_GRACE_TIME 7
  PASSWORD_REUSE_TIME 365
  PASSWORD_REUSE_MAX 5
  PASSWORD_VERIFY_FUNCTION ORA12C_VERIFY_FUNCTION;

COLUMN profile FORMAT A16
COLUMN resource_name FORMAT A30
COLUMN limit FORMAT A14
PROMPT === Parametres de P_RH_STANDARD ===
SELECT profile, resource_name, limit
  FROM dba_profiles
 WHERE profile = 'P_RH_STANDARD'
 ORDER BY resource_name;

-- Suppression de P_RH_TEST avec CASCADE : LINA retombe sur le profil DEFAULT
PROMPT === Suppression de P_RH_TEST avec CASCADE ===
DROP PROFILE p_rh_test CASCADE;

COLUMN username FORMAT A12
COLUMN profile FORMAT A14
COLUMN account_status FORMAT A18
COLUMN expiry_date FORMAT A16
PROMPt === Profils des utilisateurs apres suppression de P_RH_TEST (LINA sur DEFAULT) ===
SELECT username, profile, account_status, expiry_date
  FROM dba_users
 WHERE username IN ('LINA','OMAR','SARA')
 ORDER BY username;

-- Affectation de P_RH_STANDARD à LINA, OMAR, SARA
PROMPT === Affectation de P_RH_STANDARD à LINA, OMAR, SARA ===
ALTER USER lina PROFILE p_rh_standard;
ALTER USER omar PROFILE p_rh_standard;
ALTER USER sara PROFILE p_rh_standard;

PROMPT === Profils finaux (utilisateurs non Oracle) ===
SELECT username, profile, account_status, expiry_date
  FROM dba_users
 WHERE oracle_maintained = 'N'
 ORDER BY username;
EXIT
