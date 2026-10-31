-- chu_4_1.sql : Chapitre 4.2 -- Creation des 9 roles CHU et matrice RBAC
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Etape 1 : retirer les CREATE SESSION accordes directement au chapitre 3
PROMPT === Retrait des CREATE SESSION directes (chapitre 3) ===
REVOKE CREATE SESSION FROM dr_alami, dr_benali, dr_fassi, inf_ghazi,
                           sec_kettani, sec_lahlou, pha_mansouri, cpt_ouazzani,
                           dir_rami, dpo_sbai, app_chu, dev_chu;

-- R_CHU_CONNEXION : CREATE SESSION (base pour tous)
PROMPT === Creation du role R_CHU_CONNEXION ===
CREATE ROLE r_chu_connexion;
GRANT create session TO r_chu_connexion;

-- R_SECRETAIRE : herite R_CHU_CONNEXION + droits secretaire
PROMPT === Creation du role R_SECRETAIRE ===
CREATE ROLE r_secretaire;
GRANT r_chu_connexion TO r_secretaire;
GRANT select ON chu.v_accueil TO r_secretaire;
GRANT select ON chu.services TO r_secretaire;
GRANT select, insert ON chu.patients TO r_secretaire;
GRANT update (telephone, ville, mutuelle) ON chu.patients TO r_secretaire;
GRANT insert ON chu.sejours TO r_secretaire;

-- R_INFIRMIER : herite R_CHU_CONNEXION + droits infirmier
PROMPT === Creation du role R_INFIRMIER ===
CREATE ROLE r_infirmier;
GRANT r_chu_connexion TO r_infirmier;
GRANT select ON chu.v_soins TO r_infirmier;
GRANT select ON chu.prescriptions TO r_infirmier;

-- R_MEDECIN : herite R_INFIRMIER + droits medecin
PROMPT === Creation du role R_MEDECIN ===
CREATE ROLE r_medecin;
GRANT r_infirmier TO r_medecin;
GRANT select ON chu.v_accueil TO r_medecin;
GRANT select ON chu.sejours TO r_medecin;
GRANT select ON chu.patients TO r_medecin;
GRANT select, insert, update ON chu.dossiers_medicaux TO r_medecin;
GRANT select, insert, update ON chu.prescriptions TO r_medecin;

-- R_PHARMACIEN : herite R_CHU_CONNEXION + droits pharmacien
PROMPT === Creation du role R_PHARMACIEN ===
CREATE ROLE r_pharmacien;
GRANT r_chu_connexion TO r_pharmacien;
GRANT select ON chu.v_accueil TO r_pharmacien;
GRANT select ON chu.prescriptions TO r_pharmacien;
GRANT update (statut) ON chu.prescriptions TO r_pharmacien;

-- R_COMPTABLE : herite R_CHU_CONNEXION + droits comptable
PROMPT === Creation du role R_COMPTABLE ===
CREATE ROLE r_comptable;
GRANT r_chu_connexion TO r_comptable;
GRANT select ON chu.v_accueil TO r_comptable;
GRANT select, insert, update ON chu.factures TO r_comptable;

-- R_DIRECTION : herite R_CHU_CONNEXION + droits direction
PROMPT === Creation du role R_DIRECTION ===
CREATE ROLE r_direction;
GRANT r_chu_connexion TO r_direction;
GRANT select ON chu.v_stats_services TO r_direction;

-- R_AUDIT : herite R_CHU_CONNEXION + AUDIT_VIEWER + READ journaux AUDIT_CHU
PROMPT === Creation du role R_AUDIT ===
CREATE ROLE r_audit;
GRANT r_chu_connexion TO r_audit;
GRANT audit_viewer TO r_audit;

-- R_APPLI : herite R_CHU_CONNEXION + droits applicatifs sur 7 tables
PROMPT === Creation du role R_APPLI ===
CREATE ROLE r_appli;
GRANT r_chu_connexion TO r_appli;
GRANT select, insert, update, delete ON chu.services TO r_appli;
GRANT select, insert, update, delete ON chu.personnel TO r_appli;
GRANT select, insert, update, delete ON chu.patients TO r_appli;
GRANT select, insert, update, delete ON chu.sejours TO r_appli;
GRANT select, insert, update, delete ON chu.dossiers_medicaux TO r_appli;
GRANT select, insert, update, delete ON chu.prescriptions TO r_appli;
GRANT select, insert, update, delete ON chu.factures TO r_appli;

-- Attribution des roles aux comptes
PROMPT === Attribution des roles aux comptes ===
GRANT r_medecin TO dr_alami;
GRANT r_medecin TO dr_benali;
GRANT r_medecin TO dr_fassi;
GRANT r_infirmier TO inf_ghazi;
GRANT r_secretaire TO sec_kettani;
GRANT r_secretaire TO sec_lahlou;
GRANT r_pharmacien TO pha_mansouri;
GRANT r_comptable TO cpt_ouazzani;
GRANT r_direction TO dir_rami;
GRANT r_audit TO dpo_sbai;
GRANT r_appli TO app_chu;
GRANT r_chu_connexion TO dev_chu;

-- Delegation : DR_BENALI recoit R_INFIRMIER avec ADMIN OPTION
PROMPT === Delegation : R_INFIRMIER a DR_BENALI avec ADMIN OPTION ===
GRANT r_infirmier TO dr_benali WITH ADMIN OPTION;

COLUMN grantee FORMAT A14
COLUMN granted_role FORMAT A18
COLUMN admin_option FORMAT A14
PROMPT === Roles des comptes CHU ===
SELECT grantee, granted_role, admin_option
  FROM dba_role_privs
 WHERE grantee IN ('DR_ALAMI','DR_BENALI','DR_FASSI','INF_GHAZI',
                   'SEC_KETTANI','SEC_LAHLOU','PHA_MANSOURI','CPT_OUAZZANI',
                   'DIR_RAMI','DPO_SBAI','APP_CHU','DEV_CHU')
 ORDER BY grantee, granted_role;
EXIT
