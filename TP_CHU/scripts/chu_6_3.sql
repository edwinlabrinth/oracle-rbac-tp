-- chu_6_3.sql : Chapitre 6.3 -- DPO, separation des tâches
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Donner a R_AUDIT la lecture de DBA_AUDIT_TRAIL et DBA_FGA_AUDIT_TRAIL
PROMPT === R_AUDIT : lecture DBA_AUDIT_TRAIL et DBA_FGA_AUDIT_TRAIL ===
GRANT SELECT ON dba_audit_trail TO r_audit;
GRANT SELECT ON dba_fga_audit_trail TO r_audit;

-- Lire les 10 derniers enregistrements de UNIFIED_AUDIT_TRAIL
COLUMN event_timestamp FORMAT A25
COLUMN dbusername FORMAT A15
COLUMN action_name FORMAT A25
COLUMN object_name FORMAT A25
COLUMN return_code FORMAT 999999
PROMPt === 10 derniers enregistrements UNIFIED_AUDIT_TRAIL ===
SELECT event_timestamp, dbusername, action_name, object_name, return_code
  FROM unified_audit_trail
 ORDER BY event_timestamp DESC
 FETCH FIRST 10 ROWS ONLY;

-- Test separation des tâches : DPO tente NOAUDIT POLICY pol_chu_dossiers (doit echouer)
CONNECT dpo_sbai/"Protection##DPO26"@//localhost/FREEPDB1
PROMPt === DPO tente NOAUDIT POLICY pol_chu_dossiers (attendu echec) ===
NOAUDIT POLICY pol_chu_dossiers;

PROMPt === DPO tente SELECT sur chu.dossiers_medicaux (attendu echec) ===
SELECT * FROM chu.dossiers_medicaux;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
EXIT
