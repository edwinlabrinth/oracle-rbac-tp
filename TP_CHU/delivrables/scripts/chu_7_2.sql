-- chu_7_2.sql : Chapitre 7.2 -- Tests FGA (declenchement alerte ou non)
SET LINESIZE 120 PAGESIZE 50

-- Flush pour etre sur que tout est ecrit
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
BEGIN DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL; EXCEPTION WHEN OTHERS THEN NULL; END;

PROMPT === DR_FASSI : (a) SELECT diagnostic dossier 5 (confidentiel=N, pas d'alarme) ===
CONNECT dr_fassi/"Cardio#2026f"@//localhost/FREEPDB1
SELECT diagnostic FROM chu.dossiers_medicaux WHERE dossier_id = 5;

PROMPT === DR_FASSI : (b) SELECT diagnostic dossier 22 (confidentiel=O, alarme) ===
SELECT diagnostic FROM chu.dossiers_medicaux WHERE dossier_id = 22;

PROMPT === DR_FASSI : (c) SELECT COUNT(*) confidentiel='O' (lecture colonne confidentiel, pas audit_column) ===
SELECT COUNT(*) FROM chu.dossiers_medicaux WHERE confidentiel = 'O';

PROMPT === DR_FASSI : (d) SELECT dossier_id, maj_le (pas audit_column) ===
SELECT dossier_id, maj_le FROM chu.dossiers_medicaux;

PROMPT === DR_FASSI : (e) SELECT * (lecture audit_column sur ligne confidentiel, alarme) ===
SELECT * FROM chu.dossiers_medicaux;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Voir les alertes FGA
COLUMN utilisateur FORMAT A15
COLUMN poste FORMAT A20
COLUMN programme FORMAT A25
COLUMN objet FORMAT A20
COLUMN politique FORMAT A20
PROMPt === Alertes FGA dans AUDIT_CHU.ALERTES ===
SELECT alerte_date, utilisateur, poste, programme, objet, politique
  FROM audit_chu.alertes
 ORDER BY alerte_date DESC;

-- Voir les enregistrements FGA dans UNIFIED_AUDIT_TRAIL
COLUMN fga_policy_name FORMAT A25
COLUMN sql_text FORMAT A45
PROMPt === Enregistrements FGA dans UNIFIED_AUDIT_TRAIL ===
SELECT event_timestamp, dbusername, fga_policy_name, sql_text
  FROM unified_audit_trail
 WHERE fga_policy_name = 'FGA_CHU_CONFIDENTIEL'
 ORDER BY event_timestamp DESC;
EXIT
