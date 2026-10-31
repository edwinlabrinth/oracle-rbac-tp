-- 4_1_setup.sql : Exercice 4.1 (partie 1) -- creation du profil P_RH_TEST
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SHOW PARAMETER resource_limit

CREATE PROFILE p_rh_test LIMIT
  SESSIONS_PER_USER 2
  IDLE_TIME 1;

ALTER USER lina PROFILE p_rh_test;

COLUMN profile FORMAT A14
COLUMN resource_name FORMAT A30
COLUMN limit FORMAT A12
PROMPT === Parametres du profil P_RH_TEST ===
SELECT profile, resource_name, limit
  FROM dba_profiles
 WHERE profile = 'P_RH_TEST'
 ORDER BY resource_name;
