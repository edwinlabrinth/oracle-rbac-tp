-- 5_7.sql : Exercice 5.7 -- Séparation des tâches et purge de l'audit
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- AUDITEUR : CREATE SESSION + AUDIT_VIEWER
PROMPT === Création de l'utilisateur AUDITEUR ===
CREATE USER auditeur IDENTIFIED BY "Auditeur#2026";
GRANT CREATE SESSION TO auditeur;
GRANT AUDIT_VIEWER TO auditeur;

-- Rapport : COUNT GROUP BY dbusername, action_name sur 24 h
COLUMN dbusername FORMAT A15
COLUMN action_name FORMAT A25
COLUMN nb FORMAT 9999
PROMPT === Rapport d'audit 24h par utilisateur/action ===
SELECT dbusername, action_name, COUNT(*) AS nb
  FROM unified_audit_trail
 WHERE event_timestamp > SYSTIMESTAMP - INTERVAL '24' HOUR
 GROUP BY dbusername, action_name
 ORDER BY dbusername, action_name;

-- 5.7.3 : tentative de suppression de politique par AUDITEUR -> ORA-01031 attendu
PROMPT === AUDITEUR tente de supprimer pol_rh_salaires (attendu ORA-01031) ===
CONNECT auditeur/"Auditeur#2026"@//localhost/FREEPDB1
DROP AUDIT POLICY pol_rh_salaires;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Suppression des politiques de test (POL_RH_ADHOC si existe, POL_DBA)
PROMPT === Suppression des politiques POL_RH_ADHOC et POL_DBA ===
NOAUDIT POLICY pol_rh_adhoc;
DROP AUDIT POLICY pol_rh_adhoc;
NOAUDIT POLICY pol_dba;
DROP AUDIT POLICY pol_dba;

-- Suppression de pol_rh_salaires (encore active ?) : DROP sur active -> erreur, puis NOAUDIT puis DROP
PROMPT === Tentative DROP sur pol_rh_salaires encore active ===
DROP AUDIT POLICY pol_rh_salaires;
PROMPT === NOAUDIT pol_rh_salaires puis DROP ===
NOAUDIT POLICY pol_rh_salaires;
DROP AUDIT POLICY pol_rh_salaires;

-- Purge en toute dernière étape
PROMPT === Purge de la trace unifiee ===
BEGIN
  DBMS_AUDIT_MGMT.CLEAN_AUDIT_TRAIL(
    audit_trail_type => DBMS_AUDIT_MGMT.AUDIT_TRAIL_UNIFIED,
    use_last_arch_timestamp => FALSE);
END;
/

-- Relire la trace après purge (la purge elle-même est tracee)
COLUMN dbusername FORMAT A15
COLUMN action_name FORMAT A25
COLUMN unified_audit_policies FORMAT A25
PROMPt === Trace après purge (la purge est tracee) ===
SELECT event_timestamp, dbusername, action_name, unified_audit_policies
  FROM unified_audit_trail
 WHERE event_timestamp > SYSTIMESTAMP - INTERVAL '10' MINUTE
 ORDER BY event_timestamp DESC;
EXIT
