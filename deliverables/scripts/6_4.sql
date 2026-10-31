-- 6_4.sql : Exercice 6.4 (T4) -- Rôles et habilitations Banque Atlas
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- R_BQ_CONNEXION : CREATE SESSION (base pour tous)
PROMPT === Création du rôle R_BQ_CONNEXION ===
CREATE ROLE r_bq_connexion;
GRANT create session TO r_bq_connexion;

-- R_BQ_GUICHET hérite R_BQ_CONNEXION + droits guichet
PROMPT === Création du rôle R_BQ_GUICHET ===
CREATE ROLE r_bq_guichet;
GRANT r_bq_connexion TO r_bq_guichet;
GRANT select ON banque.v_clients_guichet TO r_bq_guichet;
GRANT select ON banque.comptes TO r_bq_guichet;
GRANT execute ON banque.p_operation TO r_bq_guichet;

-- R_BQ_CONSEILLER hérite R_BQ_GUICHET + droits conseiller
PROMPT === Création du rôle R_BQ_CONSEILLER ===
CREATE ROLE r_bq_conseiller;
GRANT r_bq_guichet TO r_bq_conseiller;
GRANT select ON banque.clients TO r_bq_conseiller;
GRANT select ON banque.operations TO r_bq_conseiller;
GRANT insert ON banque.clients TO r_bq_conseiller;
GRANT insert ON banque.comptes TO r_bq_conseiller;
GRANT update (telephone, revenu_mensuel, conseiller) ON banque.clients TO r_bq_conseiller;

-- R_BQ_DIRECTEUR hérite R_BQ_CONSEILLER
PROMPT === Création du rôle R_BQ_DIRECTEUR ===
CREATE ROLE r_bq_directeur;
GRANT r_bq_conseiller TO r_bq_directeur;

-- R_BQ_AUDIT hérite R_BQ_CONNEXION + SELECT 3 tables + AUDIT_VIEWER
PROMPT === Création du rôle R_BQ_AUDIT ===
CREATE ROLE r_bq_audit;
GRANT r_bq_connexion TO r_bq_audit;
GRANT select ON banque.clients TO r_bq_audit;
GRANT select ON banque.comptes TO r_bq_audit;
GRANT select ON banque.operations TO r_bq_audit;
GRANT audit_viewer TO r_bq_audit;

-- R_BQ_BATCH hérite R_BQ_CONNEXION + EXECUTE p_operation + SELECT comptes
PROMPT === Création du rôle R_BQ_BATCH ===
CREATE ROLE r_bq_batch;
GRANT r_bq_connexion TO r_bq_batch;
GRANT execute ON banque.p_operation TO r_bq_batch;
GRANT select ON banque.comptes TO r_bq_batch;

-- Attribution des rôles aux comptes métier
PROMPT === Attribution des rôles aux comptes ===
GRANT r_bq_guichet TO gui1;
GRANT r_bq_guichet TO gui2;
GRANT r_bq_conseiller TO cons1;
GRANT r_bq_directeur TO dir1;
GRANT r_bq_audit TO aud1;
GRANT r_bq_batch TO app_batch;
GRANT r_bq_connexion TO dev_bq;

-- Seul privilège avec retransmission : R_BQ_GUICHET à DIR1 avec ADMIN OPTION
PROMPT === Délégation : R_BQ_GUICHET à DIR1 avec ADMIN OPTION ===
GRANT r_bq_guichet TO dir1 WITH ADMIN OPTION;

-- GUI3 (créé par le DBA pour le test 10, sans privilège, profil P_BQ_AGENT)
PROMPT === Création de GUI3 (profil P_BQ_AGENT, sans privilège) ===
CREATE USER gui3 IDENTIFIED BY "Ag3#Banque2026" PROFILE p_bq_agent;

COLUMN grantee FORMAT A12
COLUMN granted_role FORMAT A20
COLUMN admin_option FORMAT A12
PROMPT === Rôles des utilisateurs métier ===
SELECT grantee, granted_role, admin_option
  FROM dba_role_privs
 WHERE grantee IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ','GUI3')
 ORDER BY grantee, granted_role;

COLUMN owner FORMAT A10
COLUMN table_name FORMAT A25
COLUMN privilege FORMAT A15
COLUMN grantee FORMAT A12
PROMPt === Privilèges objet accordés aux rôles (contrôle E1/E2) ===
SELECT r.grantee AS role, tp.table_name, tp.privilege
  FROM role_tab_privs tp
 JOIN dba_role_privs r ON tp.grantee = r.granted_role
 WHERE r.grantee IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ')
 ORDER BY r.grantee, tp.table_name, tp.privilege;
EXIT
