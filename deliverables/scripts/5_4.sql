-- 5_4.sql : Exercice 5.4 -- Politique sur les donnees sensibles (pol_rh_salaires)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Creation et activation de la politique sur rh.employes
PROMPT === Creation de la politique pol_rh_salaires ===
CREATE AUDIT POLICY pol_rh_salaires ACTIONS SELECT, UPDATE, DELETE ON rh.employes;
PROMPT === Activation de la politique ===
AUDIT POLICY pol_rh_salaires;

-- SARA : active son rôle de paie, lit les employés, met à jour un salaire
PROMPT === SARA : SET ROLE r_rh_paie + SELECT + UPDATE salaire ===
CONNECT sara/"Sara#2026"@//localhost/FREEPDB1
SET ROLE r_rh_paie IDENTIFIED BY "Paie#2026";
SELECT emp_id, nom, salaire FROM rh.employes WHERE emp_id = 7;
UPDATE rh.employes SET salaire = salaire * 1.02 WHERE emp_id = 7;
COMMIT;

-- LINA lit la vue annuaire (pas sur rh.employes directement)
PROMPT === LINA lit rh.v_annuaire ===
CONNECT lina/"Lina#2032"@//localhost/FREEPDB1
SELECT * FROM rh.v_annuaire;

-- OMAR lit rh.employes
PROMPT === OMAR lit rh.employes ===
CONNECT omar/"Omar#2026"@//localhost/FREEPDB1
SELECT emp_id, nom, salaire FROM rh.employes;

-- Retour SYS : lecture de la trace
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

COLUMN event_timestamp FORMAT A22
COLUMN dbusername FORMAT A12
COLUMN action_name FORMAT A15
COLUMN object_name FORMAT A25
COLUMN unified_audit_policies FORMAT A25
COLUMN sql_text FORMAT A45
PROMPT === Traces pol_rh_salaires (dernier quart d'heure) ===
SELECT event_timestamp, dbusername, action_name, object_name,
       unified_audit_policies, sql_text
  FROM unified_audit_trail
 WHERE unified_audit_policies = 'POL_RH_SALAIRES'
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '10' MINUTE
 ORDER BY event_timestamp;

-- Desactivation partielle : echecs uniquement, puis verification
PROMPT === NOAUDIT puis AUDIT WHENEVER NOT SUCCESSFUL ===
NOAUDIT POLICY pol_rh_salaires;
AUDIT POLICY pol_rh_salaires WHENEVER NOT SUCCESSFUL;

COLUMN entity_name FORMAT A30
COLUMN success FORMAT A10
COLUMN failure FORMAT A10
PROMPt === Etat de pol_rh_salaires dans AUDIT_UNIFIED_ENABLED_POLICIES ===
SELECT entity_name, success, failure
  FROM audit_unified_enabled_policies
 WHERE entity_name = 'POL_RH_SALAIRES';
EXIT
