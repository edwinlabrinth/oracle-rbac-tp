-- chu_9_incidents.sql : Chapitre 9 -- Execution des 8 incidents (script enseignant adapté)
-- A lancer APRÈS les chapitres 3 à 8.
-- Adaptation : @//localhost/FREEPDB1 au lieu de @orclpdb
SET LINESIZE 120 PAGESIZE 50

WHENEVER SQLERROR CONTINUE

-- Incident 1 : attaque par force brute sur un compte du secretariat
PROMPT === INCIDENT 1 : Force brute sur SEC_KETTANI ===
CONNECT sec_kettani/mauvais1@//localhost/FREEPDB1
CONNECT sec_kettani/mauvais2@//localhost/FREEPDB1
CONNECT sec_kettani/mauvais3@//localhost/FREEPDB1
CONNECT sec_kettani/"Accueil#2026k"@//localhost/FREEPDB1

-- Incident 2 : un infirmier cherche les dossiers complets
PROMPT === INCIDENT 2 : INF_GHAZI lit dossier 22 ===
CONNECT inf_ghazi/"Soins#2026g"@//localhost/FREEPDB1
SELECT diagnostic FROM chu.dossiers_medicaux WHERE dossier_id = 22;

-- Incident 3 : curiosite d'un medecin envers les patients VIP
PROMPT === INCIDENT 3 : DR_FASSI lit patients VIP ===
CONNECT dr_fassi/"Cardio#2026f"@//localhost/FREEPDB1
SELECT p.nom, p.prenom, d.diagnostic, d.traitement
FROM   chu.dossiers_medicaux d
JOIN   chu.sejours  s ON s.sejour_id  = d.sejour_id
JOIN   chu.patients p ON p.patient_id = s.patient_id
WHERE  p.vip = 'O';

-- Incident 4 : modification d'un dossier d'un autre service
PROMPT === INCIDENT 4 : DR_ALAMI modifie dossier 5 ===
CONNECT dr_alami/"Urgences#2026a"@//localhost/FREEPDB1
UPDATE chu.dossiers_medicaux
SET    diagnostic = 'Hypotension', traitement = 'Arret des IEC'
WHERE  dossier_id = 5;
COMMIT;

-- Incident 5 : modification de la prescription d'un confrere
PROMPT === INCIDENT 5 : DR_BENALI modifie prescription 8 ===
CONNECT dr_benali/"Cardio#2026b"@//localhost/FREEPDB1
UPDATE chu.prescriptions SET dose = '4 cp/j' WHERE presc_id = 8;
ROLLBACK;

-- Incident 6 : abus de delegation (ADMIN OPTION)
PROMPT === INCIDENT 6 : Delegation - DR_BENALI accorde R_INFIRMIER a SEC_LAHLOU ===
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
GRANT r_infirmier TO sec_lahlou;
CONNECT sec_lahlou/"Accueil#2026l"@//localhost/FREEPDB1
SELECT nom, prenom, diagnostic FROM chu.v_soins WHERE ROWNUM <= 10;

-- Incident 7 : le compte applicatif utilise a la main
PROMPT === INCIDENT 7 : APP_CHU connexion directe ===
CONNECT app_chu/"ChuApp##Prod2026"@//localhost/FREEPDB1

-- Incident 8 : tentative de vider une table par le developpeur
PROMPT === INCIDENT 8 : DEV_CHU tente TRUNCATE ===
CONNECT dev_chu[chu]/"Deploi#2026d"@//localhost/FREEPDB1
TRUNCATE TABLE chu.prescriptions;
DISCONNECT

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
PROMPt === Incidents executes. Flush trace. ===
BEGIN DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL; EXCEPTION WHEN OTHERS THEN NULL; END;
EXIT
