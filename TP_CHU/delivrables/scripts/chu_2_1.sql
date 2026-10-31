-- chu_2_1.sql : Chapitre 2 -- Charger et contr^oler le jeu de donn´ees CHU
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SHOW CON_NAME

-- Exécution du script de chargement du sch´ema CHU + donn´ees (déjà copié dans le conteneur)
PROMPT === Chargement du sch´ema CHU et des donn´ees ===
@/tmp/chu_01_schema_dataset.sql

-- V´erification du type d'authentification de CHU (doit ^etre NONE)
COLUMN username FORMAT A12
COLUMN authentication_type FORMAT A18
COLUMN account_status FORMAT A14
PROMPT === Compte CHU (authentification type = NONE) ===
SELECT username, authentication_type, account_status
  FROM dba_users
 WHERE username = 'CHU';

-- Comptage des lignes de chaque table
COLUMN table_name FORMAT A30
COLUMN nb_lignes FORMAT 999999
PROMPT === Nombre de lignes par table ===
SELECT 'SERVICES' AS table_name, COUNT(*) AS nb_lignes FROM chu.services
UNION ALL SELECT 'PERSONNEL', COUNT(*) FROM chu.personnel
UNION ALL SELECT 'PATIENTS', COUNT(*) FROM chu.patients
UNION ALL SELECT 'SEJOURS', COUNT(*) FROM chu.sejours
UNION ALL SELECT 'DOSSIERS_MEDICAUX', COUNT(*) FROM chu.dossiers_medicaux
UNION ALL SELECT 'PRESCRIPTIONS', COUNT(*) FROM chu.prescriptions
UNION ALL SELECT 'FACTURES', COUNT(*) FROM chu.factures
ORDER BY table_name;

-- Dossiers confidentiels
COLUMN nb_conf FORMAT 9999
PROMPT === Nombre de dossiers m´edicaux confidentiels ===
SELECT COUNT(*) AS nb_conf FROM chu.dossiers_medicaux WHERE confidentiel = 'O';

-- Patients VIP
COLUMN nom FORMAT A20
COLUMN prenom FORMAT A15
COLUMN ville FORMAT A15
COLUMN service FORMAT A20
COLUMN medecin FORMAT A25
PROMPT === Patients VIP, s´ejour et m´edecin traitant ===
SELECT p.nom, p.prenom, p.ville, s.nom AS service,
       per.nom || ' ' || per.prenom AS medecin
  FROM chu.patients p
  JOIN chu.sejours se ON se.patient_id = p.patient_id
  JOIN chu.services s ON s.service_id = se.service_id
  JOIN chu.personnel per ON per.pers_id = se.medecin_id
 WHERE p.vip = 'O';

-- S´ejours en cours (sans date de sortie)
COLUMN nb_en_cours FORMAT 9999
PROMPT === Nombre de s´ejours en cours (sans date de sortie) ===
SELECT COUNT(*) AS nb_en_cours FROM chu.sejours WHERE date_sortie IS NULL;

-- Lignes renvoy´ees par V_SOINS et V_ACCUEIL
COLUMN nb_lignes FORMAT 99999
PROMPT === Lignes de V_SOINS et V_ACCUEIL ===
SELECT 'V_SOINS' AS vue, COUNT(*) AS nb_lignes FROM chu.v_soins
UNION ALL SELECT 'V_ACCUEIL', COUNT(*) FROM chu.v_accueil
ORDER BY vue;
EXIT
