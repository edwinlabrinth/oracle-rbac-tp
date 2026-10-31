-- 3_3_a.sql : Exercice 3.3 -- session LINA de fond (chronologie)
SET LINESIZE 120 PAGESIZE 50
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1

-- t ~ 0 : attente du GRANT sur le role R_RH_LECTEUR
EXEC DBMS_SESSION.SLEEP(10);
PROMPT === Etape 1 : GRANT sur le role, sans reconnexion ===
SELECT COUNT(*) AS etape1_apres_grant FROM rh.employes;

-- t ~ 10 : attente du REVOKE + creation du role R_TEST
EXEC DBMS_SESSION.SLEEP(14);
PROMPT === Etape 2 : meme session apres REVOKE et GRANT du role R_TEST ===
SELECT COUNT(*) AS etape2_meme_session FROM rh.employes;

PROMPT === Etape 2 : apres SET ROLE ALL ===
SET ROLE ALL;
SELECT COUNT(*) AS etape2_apres_set_role FROM rh.employes;

PROMPT === Etape 2 : apres reconnexion ===
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1
SELECT COUNT(*) AS etape2_apres_reconnexion FROM rh.employes;
