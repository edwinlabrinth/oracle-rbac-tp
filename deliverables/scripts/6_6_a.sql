-- 6_6_a.sql : Exercice 6.6 (T6) -- Campagne de tests, partie A (tests 1-6)
-- GUI1 seul, pas de session de fond concurrente
SET LINESIZE 120 PAGESIZE 50

PROMPT === TEST 1 ===
CONNECT gui1/"Ag1#Banque2026"@//localhost/FREEPDB1
SELECT COUNT(*) AS nb_lignes FROM banque.v_clients_guichet;

PROMPT === TEST 2 ===
SELECT revenu_mensuel FROM banque.clients WHERE client_id = 1;

PROMPT === TEST 3 ===
EXECUTE banque.p_operation(1003, 'DEPOT', 2000);
SELECT compte_id, solde FROM banque.comptes WHERE compte_id = 1003;

PROMPT === TEST 4 ===
UPDATE banque.comptes SET solde = 1000000 WHERE compte_id = 1001;

PROMPT === TEST 5 ===
EXECUTE banque.p_operation(1002, 'RETRAIT', 60000);
SELECT compte_id, solde FROM banque.comptes WHERE compte_id = 1002;

PROMPT === TEST 6 ===
EXECUTE banque.p_operation(1005, 'RETRAIT', 5000);
EXIT
