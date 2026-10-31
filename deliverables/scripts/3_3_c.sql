-- 3_3_c.sql : Exercice 3.3 -- nettoyage et controle final
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
DROP ROLE r_test;

PROMPT === Lina ne doit plus voir les employes (pas de salaires) ===
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1
SELECT COUNT(*) AS employes FROM rh.employes;
SELECT COUNT(*) AS annuaire FROM rh.v_annuaire;
