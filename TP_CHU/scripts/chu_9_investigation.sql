-- chu_9_investigation.sql : Chapitre 9 -- Enquete sur les 8 incidents
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

PROMPT ============================================
PROMPT === ENQUETE SUR LES 8 INCIDENTS DE LA NUIT ===
PROMPT ============================================

COLUMN event_timestamp FORMAT A25
COLUMN dbusername FORMAT A15
COLUMN dbproxy_username FORMAT A15
COLUMN action_name FORMAT A20
COLUMN object_name FORMAT A25
COLUMN return_code FORMAT 999999
COLUMN unified_audit_policies FORMAT A30
COLUMN fga_policy_name FORMAT A25
COLUMN sql_text FORMAT A50

-- 9.1 Les connexions
PROMPT === 9.1.1 : Echecs de connexion dans UNIFIED_AUDIT_TRAIL (ORA_LOGON_FAILURES) ===
SELECT event_timestamp, dbusername, return_code, client_program_name, unified_audit_policies
  FROM unified_audit_trail
 WHERE action_name = 'LOGON'
   AND return_code <> 0
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '2' HOUR
 ORDER BY event_timestamp;

PROMPT === 9.1.2 : Etat des comptes dans DBA_USERS ===
COLUMN username FORMAT A15
COLUMN account_status FORMAT A20
COLUMN lock_date FORMAT A20
SELECT username, account_status, lock_date
  FROM dba_users
 WHERE username IN ('SEC_KETTANI','SEC_LAHLOU','APP_CHU')
 ORDER BY username;

PROMPT === 9.1.3 : Le compte applicatif APP_CHU a-t-il ete utilise ? ===
SELECT event_timestamp, dbusername, action_name, return_code, client_program_name
  FROM unified_audit_trail
 WHERE dbusername = 'APP_CHU'
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '2' HOUR
 ORDER BY event_timestamp;

-- 9.2 Les acces aux donnees medicales
PROMPT === 9.2.1 : Acces non-medecin aux dossiers (INF_GHAZI) ===
SELECT event_timestamp, dbusername, action_name, object_name, return_code,
       unified_audit_policies, fga_policy_name
  FROM unified_audit_trail
 WHERE dbusername = 'INF_GHAZI'
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '2' HOUR
 ORDER BY event_timestamp;

PROMPT === 9.2.2 : Alertes de confidentialite FGA (AUDIT_CHU.ALERTES) ===
COLUMN alerte_date FORMAT A25
COLUMN utilisateur FORMAT A15
COLUMN poste FORMAT A20
COLUMN programme FORMAT A25
COLUMN objet FORMAT A20
COLUMN politique FORMAT A20
SELECT alerte_date, utilisateur, poste, programme, objet, politique
  FROM audit_chu.alertes
 ORDER BY alerte_date DESC;

PROMPT === 9.2.3 : Traces FGA dans UNIFIED_AUDIT_TRAIL ===
SELECT event_timestamp, dbusername, fga_policy_name, sql_text
  FROM unified_audit_trail
 WHERE fga_policy_name = 'FGA_CHU_CONFIDENTIEL'
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '2' HOUR
 ORDER BY event_timestamp;

-- 9.3 Les modifications
PROMPT === 9.3.1 : Dossier modifie (DR_ALAMI, dossier 5) - Journal des dossiers ===
COLUMN journal_date FORMAT A25
COLUMN ancien_traitement FORMAT A25
COLUMN nouveau_traitement FORMAT A25
COLUMN ancien_confidentiel FORMAT A15
COLUMN nouveau_confidentiel FORMAT A15
SELECT journal_date, utilisateur, dossier_id,
       ancien_diagnostic, nouveau_diagnostic,
       ancien_traitement, nouveau_traitement,
       ancien_confidentiel, nouveau_confidentiel
  FROM audit_chu.journal_dossiers
 ORDER BY journal_date DESC;

PROMPT === 9.3.2 : Verification : DR_ALAMI est-il le medecin du sejour 5 ? ===
COLUMN nom FORMAT A20
COLUMN prenom FORMAT A15
COLUMN fonction FORMAT A15
SELECT p.nom, p.prenom, per.fonction, s.sejour_id, s.medecin_id
  FROM chu.dossiers_medicaux d
  JOIN chu.sejours s ON s.sejour_id = d.sejour_id
  JOIN chu.personnel per ON per.pers_id = s.medecin_id
 WHERE d.dossier_id = 5;

PROMPT === 9.3.3 : Prescription : tentative de modification refusee (DR_BENALI) ===
SELECT event_timestamp, dbusername, action_name, object_name, return_code,
       unified_audit_policies, sql_text
  FROM unified_audit_trail
 WHERE dbusername = 'DR_BENALI'
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '2' HOUR
 ORDER BY event_timestamp;

PROMPT === 9.3.4 : Journal des evenements (REFUS_PRESC de DR_BENALI) ===
SELECT evenement_date, type_evenement, utilisateur, objet, detail
  FROM audit_chu.journal_evenements
 WHERE type_evenement = 'REFUS_PRESC'
 ORDER BY evenement_date DESC;

PROMPT === 9.3.5 : Operation de structure tentee (DEV_CHU TRUNCATE) ===
SELECT event_timestamp, dbusername, action_name, return_code, sql_text
  FROM unified_audit_trail
 WHERE (dbusername = 'DEV_CHU' OR dbusername = 'CHU')
   AND action_name IN ('TRUNCATE','DROP')
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '2' HOUR
 ORDER BY event_timestamp;

PROMPT === 9.3.6 : Journal REFUS_DDL ===
SELECT evenement_date, type_evenement, utilisateur, objet, detail
  FROM audit_chu.journal_evenements
 WHERE type_evenement = 'REFUS_DDL'
 ORDER BY evenement_date DESC;

-- 9.3.7 : Connexion APP_CHU directe
PROMPT === 9.3.7 : Connexion APP_CHU directe ===
SELECT event_timestamp, dbusername, action_name, return_code, client_program_name
  FROM unified_audit_trail
 WHERE dbusername = 'APP_CHU'
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '2' HOUR
 ORDER BY event_timestamp;

EXIT
