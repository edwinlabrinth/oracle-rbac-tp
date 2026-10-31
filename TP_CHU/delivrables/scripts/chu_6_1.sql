-- chu_6_1.sql : Chapitre 6.1 -- Mode d'audit et politiques actives
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

COLUMN parameter FORMAT A30
COLUMN value FORMAT A20
PROMPT === Mode d'audit unifie (V$OPTION) ===
SELECT parameter, value
  FROM v$option
 WHERE parameter = 'Unified Auditing';

COLUMN entity_name FORMAT A30
COLUMN success FORMAT A10
COLUMN failure FORMAT A10
PROMPt === Politiques d'audit unifie activees ===
SELECT entity_name, success, failure
  FROM audit_unified_enabled_policies
 ORDER BY entity_name;

PROMPt === Nombre de politiques definies ===
SELECT COUNT(DISTINCT policy_name) AS nb_politiques
  FROM audit_unified_policies;
EXIT
