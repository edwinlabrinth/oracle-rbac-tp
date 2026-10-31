-- chu_8_3.sql : Chapitre 8.3 -- Trigger controle prescription (E7)
-- Seul le prescripteur modifie sa prescription
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Nettoyage
PROMPT === Nettoyage ===
DROP TRIGGER trg_ctrl_presc;

-- Trigger : avant UPDATE ou DELETE sur PRESCRIPTIONS
-- Si l'utilisateur est un medecin (login = SESSION_USER) et n'est pas le prescripteur,
-- journaliser REFUS_PRESC puis lever -20010
PROMPT === Creation de TRG_CTRL_PRESC ===
CREATE OR REPLACE TRIGGER trg_ctrl_presc
  BEFORE UPDATE OR DELETE ON chu.prescriptions
  FOR EACH ROW
DECLARE
  v_fonction   VARCHAR2(12);
  v_pers_id    NUMBER;
  v_is_medecin BOOLEAN := FALSE;
  v_is_prescripteur BOOLEAN := FALSE;
BEGIN
  -- Verifier si l'utilisateur courant est un medecin du personnel
  SELECT fonction, pers_id
    INTO v_fonction, v_pers_id
    FROM chu.personnel
   WHERE login = SYS_CONTEXT('USERENV','SESSION_USER');
  
  IF v_fonction = 'MEDECIN' THEN
    v_is_medecin := TRUE;
    -- Verifier si ce medecin est le prescripteur de la prescription
    IF :OLD.medecin_id = v_pers_id THEN
      v_is_prescripteur := TRUE;
    END IF;
  END IF;
  
  -- Si medecin mais pas le prescripteur : refuser
  IF v_is_medecin AND NOT v_is_prescripteur THEN
    audit_chu.log_evt('REFUS_PRESC', 'PRESCRIPTIONS',
      'Medecin ' || SYS_CONTEXT('USERENV','SESSION_USER') ||
      ' tente de modifier la prescription ' || :OLD.presc_id ||
      ' dont le prescripteur est ' || :OLD.medecin_id);
    RAISE_APPLICATION_ERROR(-20010, 'Seul le prescripteur peut modifier sa prescription');
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- L'utilisateur n'est pas dans le personnel (ex: APP_CHU), ne rien faire
    NULL;
END;
/

-- Test : DR_ALAMI modifie la dose de la prescription 8 (la sienne) puis ROLLBACK
CONNECT dr_alami/"Urgences#2026a"@//localhost/FREEPDB1
PROMPT === DR_ALAMI : UPDATE dose prescription 8 (sienne) puis ROLLBACK ===
UPDATE chu.prescriptions SET dose = '3 cp/j' WHERE presc_id = 8;
ROLLBACK;

-- Test : DR_FASSI tente la meme modification (pas le prescripteur) -> blocage
CONNECT dr_fassi/"Cardio#2026f"@//localhost/FREEPDB1
PROMPT === DR_FASSI : UPDATE dose prescription 8 (pas sienne) => -20010 ===
UPDATE chu.prescriptions SET dose = '3 cp/j' WHERE presc_id = 8;

-- Test : PHA_MANSOURI marque la prescription 8 délivree puis ROLLBACK
-- (pharmacien, pas medecin => declencheur ne s'applique pas)
CONNECT pha_mansouri/"Pharma#2026m"@//localhost/FREEPDB1
PROMPT === PHA_MANSOURI : UPDATE statut prescription 8 (delivree) puis ROLLBACK ===
UPDATE chu.prescriptions SET statut = 'DELIVREE' WHERE presc_id = 8;
ROLLBACK;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Verifier le journal des evenements
COLUMN type_evenement FORMAT A20
COLUMN utilisateur FORMAT A15
COLUMN objet FORMAT A20
COLUMN detail FORMAT A60
PROMPt === Contenu de JOURNAL_EVENEMENTS ===
SELECT evenement_date, type_evenement, utilisateur, objet, detail
  FROM audit_chu.journal_evenements
 ORDER BY evenement_date DESC;
EXIT
