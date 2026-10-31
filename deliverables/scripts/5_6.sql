-- 5_6.sql : Exercice 5.6 -- Audit fin des gros salaires (FGA)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Politique FGA sur RH.EMPLOYES : audit quand SALAIRE > 30000, colonne SALAIRE
PROMPT === Creation de la politique FGA FGA_GROS_SALAIRES ===
BEGIN
  DBMS_FGA.ADD_POLICY(
    object_schema   => 'RH',
    object_name     => 'EMPLOYES',
    policy_name     => 'FGA_GROS_SALAIRES',
    audit_condition => 'SALAIRE > 30000',
    audit_column    => 'SALAIRE',
    statement_types => 'SELECT,UPDATE',
    enable          => TRUE);
END;
/
PROMPt === Politiques FGA sur RH.EMPLOYES ===
COLUMN policy_name FORMAT A30
COLUMN enable FORMAT A8
SELECT policy_name, enable
  FROM dba_audit_policies
 WHERE object_schema = 'RH' AND object_name = 'EMPLOYES';

-- SARA : active son rôle paie, trois requêtes
PROMPT === SARA : (a) noms seuls (pas de colonne SALAIRE) ===
CONNECT sara/"Sara#2026"@//localhost/FREEPDB1
SET ROLE r_rh_paie IDENTIFIED BY "Paie#2026";
SELECT emp_id, nom FROM rh.employes;

PROMPT === SARA : (b) salaires dept 40 (aucune ligne > 30000) ===
SELECT emp_id, nom, salaire FROM rh.employes WHERE dept_id = 40;

PROMPT === SARA : (c) salaires dept 10 (Alaoui 45000 > 30000 -> declenche FGA) ===
SELECT emp_id, nom, salaire FROM rh.employes WHERE dept_id = 10;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Lecture des traces FGA dans UNIFIED_AUDIT_TRAIL et DBA_FGA_AUDIT_TRAIL
EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

COLUMN event_timestamp FORMAT A22
COLUMN dbusername FORMAT A12
COLUMN fga_policy_name FORMAT A25
COLUMN sql_text FORMAT A45
PROMPT === Traces FGA dans UNIFIED_AUDIT_TRAIL (dernier quart d'heure) ===
SELECT event_timestamp, dbusername, fga_policy_name, sql_text
  FROM unified_audit_trail
 WHERE fga_policy_name = 'FGA_GROS_SALAIRES'
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '10' MINUTE
 ORDER BY event_timestamp;

PROMPt === Contenu de DBA_FGA_AUDIT_TRAIL ===
COLUMN db_user FORMAT A12
COLUMN lsql_text FORMAT A45
SELECT db_user, lsql_text
  FROM dba_fga_audit_trail;

-- Desactivation de la politique FGA
PROMPT === Desactivation de FGA_GROS_SALAIRES ===
EXEC DBMS_FGA.DISABLE_POLICY('RH','EMPLOYES','FGA_GROS_SALAIRES');
EXIT
