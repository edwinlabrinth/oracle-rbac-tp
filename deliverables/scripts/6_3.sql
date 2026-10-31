-- 6_3.sql : Exercice 6.3 (T3) -- Comptes Banque Atlas
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Comptes avec profil P_BQ_AGENT (guichetiers : 1 session)
PROMPT === Création de GUI1 et GUI2 (profil P_BQ_AGENT) ===
CREATE USER gui1 IDENTIFIED BY "Gui1#2026" PROFILE p_bq_agent;
CREATE USER gui2 IDENTIFIED BY "Gui2#2026" PROFILE p_bq_agent;

-- Conseiller : profil P_BQ_CONSEIL (2 sessions)
PROMPT === Création de CONS1 (profil P_BQ_CONSEIL) ===
CREATE USER cons1 IDENTIFIED BY "Cons1#2026" PROFILE p_bq_conseil;

-- Directeur et auditeur : profil P_BQ_SENSIBLE (mot de passe renforcé)
PROMPT === Création de DIR1 et AUD1 (profil P_BQ_SENSIBLE) ===
CREATE USER dir1 IDENTIFIED BY "Dir1#Banque2026!" PROFILE p_bq_sensible;
CREATE USER aud1 IDENTIFIED BY "Aud1#Banque2026!" PROFILE p_bq_sensible;

-- Batch : profil P_BQ_SERVICE
PROMPT === Création de APP_BATCH (profil P_BQ_SERVICE) ===
CREATE USER app_batch IDENTIFIED BY "Batch1#2026" PROFILE p_bq_service;

-- Developpeur proxy : pas de profil contraignant (DEFAULT), aucun quota
PROMPT === Création de DEV_BQ ===
CREATE USER dev_bq IDENTIFIED BY "Dev1#Banque2026";

-- Proxy DEV_BQ vers le schéma BANQUE (comme RH au chapitre 1)
PROMPT === Autorisation du proxy DEV_BQ -> BANQUE ===
ALTER USER banque GRANT CONNECT THROUGH dev_bq;

COLUMN username FORMAT A12
COLUMN profile FORMAT A14
COLUMN account_status FORMAT A12
PROMPT === Comptes créés (sans quota) ===
SELECT username, profile, account_status
  FROM dba_users
 WHERE username IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ')
 ORDER BY username;

PROMPt === Quotas (aucun ne doit apparaître) ===
COLUMN tablespace_name FORMAT A15
COLUMN bytes FORMAT 999999
SELECT username, tablespace_name, bytes, max_bytes
  FROM dba_ts_quotas
 WHERE username IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ');

PROMPT === Autorisation proxy ===
COLUMN proxy FORMAT A12
COLUMN client FORMAT A12
SELECT proxy, client FROM proxy_users WHERE client = 'BANQUE';
EXIT
