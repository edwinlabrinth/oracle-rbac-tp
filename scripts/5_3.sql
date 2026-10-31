-- 5_3.sql : Exercice 5.3 -- Tracer l'administration des comptes (ORA_ACCOUNT_MGMT)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Activation de la politique predefinie ORA_ACCOUNT_MGMT (gestion des comptes)
PROMPT === Activation de la politique ORA_ACCOUNT_MGMT ===
AUDIT POLICY ora_account_mgmt;

-- Creation de STAGIAIRE, octroi puis retrait de R_RH_LECTEUR, suppression
PROMPT === Creation de STAGIAIRE ===
CREATE USER stagiaire IDENTIFIED BY "Stagiaire#2026";
GRANT CREATE SESSION TO stagiaire;

PROMPT === Octroi de R_RH_LECTEUR à STAGIAIRE ===
GRANT r_rh_lecteur TO stagiaire;

PROMPT === Retrait de R_RH_LECTEUR à STAGIAIRE ===
REVOKE r_rh_lecteur FROM stagiaire;

PROMPT === Suppression de STAGIAIRE ===
DROP USER stagiaire;

-- Flush de la trace unifiee puis lecture
EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

COLUMN event_timestamp FORMAT A22
COLUMN dbusername FORMAT A15
COLUMN action_name FORMAT A25
COLUMN sql_text FORMAT A50
PROMPT === Trace de l'administration des comptes (dernier quart d'heure) ===
SELECT event_timestamp, dbusername, action_name, sql_text
  FROM unified_audit_trail
 WHERE unified_audit_policies = 'ORA_ACCOUNT_MGMT'
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '10' MINUTE
 ORDER BY event_timestamp;
EXIT
