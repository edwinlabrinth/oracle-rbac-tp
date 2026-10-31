-- chu_4_3.sql : Chapitre 4.3 -- Campagne de tests des droits (matrice RBAC)
SET LINESIZE 120 PAGESIZE 50

PROMPT === TEST 1 : SEC_KETTANI SELECT v_accueil (attendu 60 lignes) ===
CONNECT sec_kettani/"Accueil#2026k"@//localhost/FREEPDB1
SELECT COUNT(*) AS nb_lignes FROM chu.v_accueil;

PROMPT === TEST 2 : SEC_KETTANI SELECT dossiers_medicaux (attendu ORA-00942) ===
SELECT * FROM chu.dossiers_medicaux;

PROMPT === TEST 3 : SEC_KETTANI UPDATE patients.cin (attendu ORA-01031) ===
UPDATE chu.patients SET cin = 'X' WHERE patient_id = 1;

PROMPT === TEST 4 : INF_GHAZI SELECT COUNT(*) v_soins (attendu 41) ===
CONNECT inf_ghazi/"Soins#2026g"@//localhost/FREEPDB1
SELECT COUNT(*) AS nb_soins FROM chu.v_soins;

PROMPT === TEST 5 : INF_GHAZI UPDATE prescriptions.statut (attendu ORA-01031) ===
UPDATE chu.prescriptions SET statut = 'DELIVREE' WHERE presc_id = 8;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

PROMPT === TEST 6 : CPT_OUAZZANI SELECT v_soins (attendu ORA-00942) ===
CONNECT cpt_ouazzani/"Finance2027x!"@//localhost/FREEPDB1
SELECT * FROM chu.v_soins;

PROMPT === TEST 7 : DIR_RAMI SELECT v_stats_services (attendu 6 lignes) ===
CONNECT dir_rami/"Direction##CHU26"@//localhost/FREEPDB1
SELECT COUNT(*) AS nb_services FROM chu.v_stats_services;

PROMPT === TEST 8 : DIR_RAMI SELECT patients (attendu ORA-00942) ===
SELECT * FROM chu.patients;

PROMPT === TEST 9 : DR_FASSI SELECT diagnostic dossier 22 (attendu succes) ===
CONNECT dr_fassi/"Cardio#2026f"@//localhost/FREEPDB1
SELECT diagnostic FROM chu.dossiers_medicaux WHERE dossier_id = 22;

PROMPT === TEST 10 : PHA_MANSOURI UPDATE prescriptions.statut (attendu 1 ligne + ROLLBACK) ===
CONNECT pha_mansouri/"Pharma#2026m"@//localhost/FREEPDB1
UPDATE chu.prescriptions SET statut = 'DELIVREE' WHERE presc_id = 8;
ROLLBACK;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

PROMPT === TEST 11 : Delegation - DR_BENALI accorde R_INFIRMIER a un nouveau compte ===
-- Verifier que DR_BENALI a l'ADMIN OPTION sur R_INFIRMIER
SELECT grantee, granted_role, admin_option
  FROM dba_role_privs
 WHERE grantee = 'DR_BENALI' AND granted_role = 'R_INFIRMIER';

PROMPT === Verification : aucun privilege systeme direct aux comptes metier ===
COLUMN grantee FORMAT A14
COLUMN privilege FORMAT A30
SELECT grantee, privilege
  FROM dba_sys_privs
 WHERE grantee IN ('DR_ALAMI','DR_BENALI','DR_FASSI','INF_GHAZI',
                   'SEC_KETTANI','SEC_LAHLOU','PHA_MANSOURI','CPT_OUAZZANI',
                   'DIR_RAMI','DPO_SBAI','APP_CHU','DEV_CHU');
EXIT
