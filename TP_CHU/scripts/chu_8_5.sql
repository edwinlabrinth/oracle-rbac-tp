-- chu_8_5.sql : Chapitre 8.5 -- Trigger protection structure (E9)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Nettoyage
PROMPT === Nettoyage ===
DROP TRIGGER trg_ddl_chu;

-- Trigger BEFORE DROP OR TRUNCATE ON chu.SCHEMA
PROMPT === Creation de TRG_DDL_CHU ===
CREATE OR REPLACE TRIGGER trg_ddl_chu
  BEFORE DROP OR TRUNCATE ON chu.SCHEMA
BEGIN
  audit_chu.log_evt('REFUS_DDL', 'OBJET_DDL',
    'Tentative DDL sur schma CHU par ' || SYS_CONTEXT('USERENV','SESSION_USER'));
  RAISE_APPLICATION_ERROR(-20030, 'Structure protegee : modification DDL interdite sur le schma CHU');
END;
/

-- Test : DEV_CHU via proxy cree un index (OK) puis tente TRUNCATE (bloque -20030)
CONNECT dev_chu[chu]/"Deploi#2026d"@//localhost/FREEPDB1
PROMPT === DEV_CHU : CREATE INDEX sur prescriptions ===
CREATE INDEX idx_prescriptions_sejour ON chu.prescriptions(sejour_id);

PROMPT === DEV_CHU : TRUNCATE TABLE prescriptions (attendu -20030) ===
TRUNCATE TABLE chu.prescriptions;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Verifier le journal
COLUMN type_evenement FORMAT A20
COLUMN utilisateur FORMAT A15
COLUMN objet FORMAT A20
COLUMN detail FORMAT A80
PROMPt === Journal evenements (REFUS_DDL) ===
SELECT evenement_date, type_evenement, utilisateur, objet, detail
  FROM audit_chu.journal_evenements
 WHERE type_evenement = 'REFUS_DDL'
 ORDER BY evenement_date DESC;

-- Verifier que la table prescriptions existe encore
COLUMN table_name FORMAT A30
SELECT table_name FROM dba_tables WHERE table_name = 'PRESCRIPTIONS' AND owner = 'CHU';
EXIT
