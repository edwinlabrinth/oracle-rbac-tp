-- 3_3_b.sql : Exercice 3.3 -- actions ADMIN pendant la session LINA
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

EXEC DBMS_SESSION.SLEEP(2);
PROMPT === Etape 1 : GRANT SELECT ON rh.employes TO r_rh_lecteur ===
GRANT SELECT ON rh.employes TO r_rh_lecteur;

EXEC DBMS_SESSION.SLEEP(14);
PROMPT === Etape 2 : REVOKE du GRANT + role R_TEST accorde a LINA ===
REVOKE SELECT ON rh.employes FROM r_rh_lecteur;
CREATE ROLE r_test;
GRANT SELECT ON rh.employes TO r_test;
GRANT r_test TO lina;
