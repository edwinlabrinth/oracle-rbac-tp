-- 6_5.sql : Exercice 6.5 (T5) -- Audit Banque Atlas (E6 à E8)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- POL_BQ_CLIENTS : modifications de fiches clients (succès et échecs)
PROMPT === Création et activation de POL_BQ_CLIENTS ===
CREATE AUDIT POLICY pol_bq_clients ACTIONS INSERT, UPDATE, DELETE ON banque.clients;
AUDIT POLICY pol_bq_clients;

-- POL_BQ_SOLDES : ONLY échecs de modification directe sur COMPTES et OPERATIONS
PROMPT === Création et activation de POL_BQ_SOLDES (WHENEVER NOT SUCCESSFUL) ===
CREATE AUDIT POLICY pol_bq_soldes ACTIONS UPDATE, INSERT, DELETE ON banque.comptes;
CREATE AUDIT POLICY pol_bq_soldes_ops ACTIONS UPDATE, INSERT, DELETE ON banque.operations;
AUDIT POLICY pol_bq_soldes WHENEVER NOT SUCCESSFUL;
AUDIT POLICY pol_bq_soldes_ops WHENEVER NOT SUCCESSFUL;

-- FGA : gros montants sur les insertions dans OPERATIONS (montant >= 50000)
PROMPT === Création de la politique FGA FGA_BQ_GROS_MONTANTS ===
BEGIN
  DBMS_FGA.ADD_POLICY(
    object_schema   => 'BANQUE',
    object_name     => 'OPERATIONS',
    policy_name     => 'FGA_BQ_GROS_MONTANTS',
    audit_condition => 'MONTANT >= 50000',
    statement_types => 'INSERT',
    enable          => TRUE);
END;
/

-- ORA_ACCOUNT_MGMT (E8 : gestion des comptes et habilitations)
PROMPt === Activation de ORA_ACCOUNT_MGMT (E8) ===
AUDIT POLICY ora_account_mgmt;

COLUMN policy_name FORMAT A30
COLUMN audit_option FORMAT A20
PROMPT === Politiques créées ===
SELECT policy_name, audit_option
  FROM audit_unified_policies
 WHERE policy_name IN ('POL_BQ_CLIENTS','POL_BQ_SOLDES','POL_BQ_SOLDES_OPS','FGA_BQ_GROS_MONTANTS')
 ORDER BY policy_name, audit_option;

COLUMN entity_name FORMAT A30
COLUMN success FORMAT A10
COLUMN failure FORMAT A10
PROMPt === Politiques actives ===
SELECT entity_name, success, failure
  FROM audit_unified_enabled_policies
 WHERE entity_name IN ('POL_BQ_CLIENTS','POL_BQ_SOLDES','POL_BQ_SOLDES_OPS','ORA_ACCOUNT_MGMT')
 ORDER BY entity_name;
EXIT
