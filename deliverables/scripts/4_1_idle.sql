-- 4_1_idle.sql : Exercice 4.1 -- test d'inactivite (IDLE_TIME = 1 minute)
SET LINESIZE 120 PAGESIZE 50
PROMPT === Session LINA inactive (HOST sleep 70 > IDLE_TIME 1 minute) puis requete ===
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1
HOST sleep 150
SELECT 1 AS test_inactivite FROM dual;
EXIT
