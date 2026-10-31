-- 6_6.sql : Exercice 6.6 (T6) -- Campagne de tests (16 tests)
-- Un CONNECT par test, une ligne PROMPT === TEST n === avant chacun
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

PROMPT === TEST 7 ===
CONNECT gui1/"Ag1#Banque2026"@//localhost/FREEPDB1

PROMPT === TEST 8 ===
CONNECT cons1/"Cn1#Conseil2026"@//localhost/FREEPDB1
UPDATE banque.clients SET telephone = '0661000099' WHERE client_id = 2;
COMMIT;

PROMPT === TEST 9 ===
UPDATE banque.clients SET cin = 'K999999' WHERE client_id = 2;

PROMPT === TEST 10 ===
CONNECT dir1/"Dir1#Banque2026!"@//localhost/FREEPDB1
GRANT r_bq_guichet TO gui3;

PROMPT === TEST 11 ===
GRANT r_bq_conseiller TO gui3;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

PROMPT === TEST 12 ===
CONNECT aud1/"Aud1#Banque2026!"@//localhost/FREEPDB1
SET ROLE r_bq_audit;
SELECT COUNT(*) FROM banque.operations;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

PROMPT === TEST 13 ===
CONNECT aud1/"Aud1#Banque2026!"@//localhost/FREEPDB1
DELETE FROM banque.operations WHERE op_id = 1;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

PROMPT === TEST 14 ===
CONNECT gui2/"faux"@//localhost/FREEPDB1
CONNECT gui2/"faux"@//localhost/FREEPDB1
CONNECT gui2/"faux"@//localhost/FREEPDB1
CONNECT gui2/"Ag2#Banque2026"@//localhost/FREEPDB1

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
ALTER USER gui2 ACCOUNT UNLOCK;

PROMPT === TEST 15 ===
CONNECT dev_bq[banque]/"Dev1#Banque2026"@//localhost/FREEPDB1
CREATE INDEX idx_ops_compte ON banque.operations(compte_id);
DROP INDEX idx_ops_compte;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

PROMPT === TEST 16 ===
CONNECT app_batch/"BAtch##2026!"@//localhost/FREEPDB1
EXECUTE banque.p_operation(1002, 'DEPOT', 1200);
SELECT compte_id, solde FROM banque.comptes WHERE compte_id = 1002;
EXIT
