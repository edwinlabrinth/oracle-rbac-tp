-- chu_3_3_f.sql : Chapitre 3.3 -- Changement de mot de passe CPT_OUAZZANI
CONNECT cpt_ouazzani/"Compta#2026o"@//localhost/FREEPDB1
PROMPT === Changement sans REPLACE (attendu ORA-28221) ===
ALTER USER cpt_ouazzani IDENTIFIED BY "Finance2027x";
PROMPT === Changement avec REPLACE (attendu OK) ===
ALTER USER cpt_ouazzani IDENTIFIED BY "Finance2027x" REPLACE "Compta#2026o";

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
PROMPt === SYS tente de redonner l'ancien mot de passe Compta#2026o (attendu echec reuse) ===
ALTER USER cpt_ouazzani IDENTIFIED BY "Compta#2026o";

COLUMN username FORMAT A14
COLUMN account_status FORMAT A20
COLUMN expiry_date FORMAT A20
PROMPt === Etat CPT_OUAZZANI ===
SELECT username, account_status, expiry_date FROM dba_users WHERE username = 'CPT_OUAZZANI';
EXIT
