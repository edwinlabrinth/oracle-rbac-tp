-- chu_8_2.sql : Chapitre 8.2 -- Trigger de valeurs sur DOSSIERS_MEDICAUX (E6)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Nettoyage eventuel
PROMPt === Nettoyage ===
DROP TRIGGER trg_aud_dossiers;

-- Trigger : apres UPDATE sur diagnostic, traitement ou confidentialite, pour chaque ligne
PROMPT === Creation de TRG_AUD_DOSSIERS ===
CREATE OR REPLACE TRIGGER trg_aud_dossiers
  AFTER UPDATE OF diagnostic, traitement, confidentiel ON chu.dossiers_medicaux
  FOR EACH ROW
  WHEN (OLD.diagnostic <> NEW.diagnostic OR OLD.traitement <> NEW.traitement OR OLD.confidentiel <> NEW.confidentiel)
BEGIN
  INSERT INTO audit_chu.journal_dossiers
    (utilisateur, utilisateur_proxy, poste, programme,
     dossier_id,
     ancien_diagnostic, nouveau_diagnostic,
     ancien_traitement, nouveau_traitement,
     ancien_confidentiel, nouveau_confidentiel)
  VALUES
    (SYS_CONTEXT('USERENV','SESSION_USER'),
     SYS_CONTEXT('USERENV','PROXY_USER'),
     SYS_CONTEXT('USERENV','HOST'),
     SYS_CONTEXT('USERENV','CLIENT_PROGRAM_NAME'),
     :NEW.dossier_id,
     :OLD.diagnostic, :NEW.diagnostic,
     :OLD.traitement, :NEW.traitement,
     :OLD.confidentiel, :NEW.confidentiel);
END;
/

-- Test : DR_FASSI modifie le traitement du dossier 5 (son patient) puis ROLLBACK
-- DR_ALAMI est le medecin du sejour 5 (patient 26, sejour 5, medecin_id 6 = DR_ALAMI)
-- Donc DR_FASSI n'est pas le medecin du sejour, mais le trigger 8.2 ne bloque pas,
-- il journalise seulement (le blocage est au trigger 8.3 pour prescriptions)
CONNECT dr_fassi/"Cardio#2026f"@//localhost/FREEPDB1
PROMPT === DR_FASSI : UPDATE traitement dossier 5 puis ROLLBACK ===
UPDATE chu.dossiers_medicaux SET traitement = 'IEC + bêtabloquant' WHERE dossier_id = 5;
ROLLBACK;

PROMPT === DR_FASSI : UPDATE traitement dossier 5 puis COMMIT ===
UPDATE chu.dossiers_medicaux SET traitement = 'IEC + bêtabloquant' WHERE dossier_id = 5;
COMMIT;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Verifier le journal
COLUMN utilisateur FORMAT A15
COLUMN ancien_diagnostic FORMAT A20
COLUMN nouveau_diagnostic FORMAT A20
COLUMN ancien_traitement FORMAT A20
COLUMN nouveau_traitement FORMAT A20
PROMPt === Contenu de JOURNAL_DOSSIERS ===
SELECT journal_date, utilisateur, dossier_id,
       ancien_traitement, nouveau_traitement
  FROM audit_chu.journal_dossiers
 ORDER BY journal_date DESC;
EXIT
