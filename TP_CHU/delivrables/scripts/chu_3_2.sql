-- chu_3_2.sql : Chapitre 3.2 -- Douze comptes CHU, schema AUDIT_CHU, proxy DEV_CHU->CHU
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- CHU a besoin de CREATE SESSION pour etre cible du proxy (comme RH au TP precedent)
PROMPT === CHU : octroi de CREATE SESSION (cible du proxy) ===
GRANT CREATE SESSION TO chu;

-- Schema AUDIT_CHU : sans authentification, 200 Mo sur USERS (recevra les journaux)
PROMPT === Creation du schema AUDIT_CHU (NO AUTHENTICATION, 200 Mo) ===
CREATE USER audit_chu NO AUTHENTICATION DEFAULT TABLESPACE users QUOTA 200M ON users;

-- Les 12 comptes avec leur profil et mot de passe imposes
PROMPT === Creation des comptes soignants (P_SOIGNANT) ===
CREATE USER dr_alami IDENTIFIED BY "Urgences#2026a" PROFILE p_soignant DEFAULT TABLESPACE users;
CREATE USER dr_benali IDENTIFIED BY "Cardio#2026b" PROFILE p_soignant DEFAULT TABLESPACE users;
CREATE USER dr_fassi IDENTIFIED BY "Cardio#2026f" PROFILE p_soignant DEFAULT TABLESPACE users;
CREATE USER inf_ghazi IDENTIFIED BY "Soins#2026g" PROFILE p_soignant DEFAULT TABLESPACE users;

PROMPT === Creation des comptes administratifs (P_ADMINISTRATIF) ===
CREATE USER sec_kettani IDENTIFIED BY "Accueil#2026k" PROFILE p_administratif DEFAULT TABLESPACE users;
CREATE USER sec_lahlou IDENTIFIED BY "Accueil#2026l" PROFILE p_administratif DEFAULT TABLESPACE users;
CREATE USER pha_mansouri IDENTIFIED BY "Pharma#2026m" PROFILE p_administratif DEFAULT TABLESPACE users;
CREATE USER cpt_ouazzani IDENTIFIED BY "Compta#2026o" PROFILE p_administratif DEFAULT TABLESPACE users;

PROMPT === Creation des comptes sensibles (P_SENSIBLE) ===
CREATE USER dir_rami IDENTIFIED BY "Direction##CHU26" PROFILE p_sensible DEFAULT TABLESPACE users;
CREATE USER dpo_sbai IDENTIFIED BY "Protection##DPO26" PROFILE p_sensible DEFAULT TABLESPACE users;

PROMPT === Creation du compte applicatif (P_APPLI) ===
CREATE USER app_chu IDENTIFIED BY "ChuApp##Prod2026" PROFILE p_appli DEFAULT TABLESPACE users;

PROMPT === Creation du compte developpeur (P_ADMINISTRATIF) ===
CREATE USER dev_chu IDENTIFIED BY "Deploi#2026d" PROFILE p_administratif DEFAULT TABLESPACE users;

-- Chaque compte a besoin de CREATE SESSION pour se connecter
PROMPt === Octroi de CREATE SESSION aux 12 comptes ===
GRANT CREATE SESSION TO dr_alami, dr_benali, dr_fassi, inf_ghazi,
                           sec_kettani, sec_lahlou, pha_mansouri, cpt_ouazzani,
                           dir_rami, dpo_sbai, app_chu, dev_chu;

-- Proxy : DEV_CHU se connecte a travers CHU
PROMPT === Autorisation du proxy DEV_CHU -> CHU ===
ALTER USER chu GRANT CONNECT THROUGH dev_chu;

COLUMN username FORMAT A14
COLUMN profile FORMAT A20
COLUMN account_status FORMAT A14
COLUMN authentication_type FORMAT A18
PROMPT === Comptes creer (verification) ===
SELECT username, profile, account_status, authentication_type
  FROM dba_users
 WHERE username IN ('DR_ALAMI','DR_BENALI','DR_FASSI','INF_GHAZI',
                    'SEC_KETTANI','SEC_LAHLOU','PHA_MANSOURI','CPT_OUAZZANI',
                    'DIR_RAMI','DPO_SBAI','APP_CHU','DEV_CHU','CHU','AUDIT_CHU')
 ORDER BY username;

PROMPt === Quotas (aucun quota innecesaire, sauf AUDIT_CHU 200M) ===
COLUMN username FORMAT A14
COLUMN tablespace_name FORMAT A15
COLUMN max_bytes FORMAT 99999999999
SELECT username, tablespace_name, max_bytes
  FROM dba_ts_quotas
 WHERE username IN ('CHU','AUDIT_CHU','DR_ALAMI','DR_BENALI','DR_FASSI','INF_GHAZI',
                    'SEC_KETTANI','SEC_LAHLOU','PHA_MANSOURI','CPT_OUAZZANI',
                    'DIR_RAMI','DPO_SBAI','APP_CHU','DEV_CHU')
 ORDER BY username;

PROMPT === Autorisation proxy ===
COLUMN proxy FORMAT A12
COLUMN client FORMAT A12
SELECT proxy, client FROM proxy_users WHERE client = 'CHU';
EXIT
