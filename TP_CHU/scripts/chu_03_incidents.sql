-- =====================================================================
-- TP Audit — CHU Al Majd : script d'incidents (réservé à l'enseignant)
-- À lancer depuis SQL*Plus sur le serveur, APRÈS les chapitres 3 à 8.
-- Adapter l'alias réseau (orclpdb) si nécessaire.
-- =====================================================================
WHENEVER SQLERROR CONTINUE
-- Incident 1 : attaque par force brute sur un compte du secrétariat
CONNECT sec_kettani/mauvais1@orclpdb
CONNECT sec_kettani/mauvais2@orclpdb
CONNECT sec_kettani/mauvais3@orclpdb
CONNECT sec_kettani/"Accueil#2026k"@orclpdb

-- Incident 2 : un infirmier cherche les dossiers complets
CONNECT inf_ghazi/"Soins#2026g"@orclpdb
SELECT diagnostic FROM chu.dossiers_medicaux WHERE dossier_id = 22;

-- Incident 3 : curiosité d'un médecin envers les patients VIP
CONNECT dr_fassi/"Cardio#2026f"@orclpdb
SELECT p.nom, p.prenom, d.diagnostic, d.traitement
FROM   chu.dossiers_medicaux d
JOIN   chu.sejours  s ON s.sejour_id  = d.sejour_id
JOIN   chu.patients p ON p.patient_id = s.patient_id
WHERE  p.vip = 'O';

-- Incident 4 : modification d'un dossier d'un autre service
CONNECT dr_alami/"Urgences#2026a"@orclpdb
UPDATE chu.dossiers_medicaux
SET    diagnostic = 'Hypotension', traitement = 'Arrêt des IEC'
WHERE  dossier_id = 5;
COMMIT;

-- Incident 5 : modification de la prescription d'un confrère
CONNECT dr_benali/"Cardio#2026b"@orclpdb
UPDATE chu.prescriptions SET dose = '4 cp/j' WHERE presc_id = 8;
ROLLBACK;

-- Incident 6 : abus de délégation (ADMIN OPTION)
GRANT r_infirmier TO sec_lahlou;
CONNECT sec_lahlou/"Accueil#2026l"@orclpdb
SELECT nom, prenom, diagnostic FROM chu.v_soins WHERE ROWNUM <= 10;

-- Incident 7 : le compte applicatif utilisé à la main
CONNECT app_chu/"ChuApp##Prod2026"@orclpdb

-- Incident 8 : tentative de vider une table par le développeur
CONNECT dev_chu[chu]/"Deploi#2026d"@orclpdb
TRUNCATE TABLE prescriptions;
DISCONNECT
