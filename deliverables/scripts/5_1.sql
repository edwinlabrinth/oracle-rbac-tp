-- 5_1.sql : Exercice 5.1 -- Etat de l'audit unifie
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Mode d'audit unifie
COLUMN parameter FORMAT A30
COLUMN value FORMAT A20
PROMPT === Mode d'audit unifie (V$OPTION) ===
SELECT parameter, value
  FROM v$option
 WHERE parameter = 'Unified Auditing';

PROMPT === Politiques d'audit unifie activees ===
COLUMN entity_name FORMAT A30
COLUMN success FORMAT A10
COLUMN failure FORMAT A10
SELECT entity_name, success, failure
  FROM audit_unified_enabled_policies
 ORDER BY entity_name;

PROMPT === Nombre de politiques distinctes definies ===
SELECT COUNT(DISTINCT policy_name) AS nb_politiques
  FROM audit_unified_policies;

PROMPT === Liste des politiques d'audit unifie (noms uniquement) ===
COLUMN policy_name FORMAT A30
SELECT DISTINCT policy_name
  FROM audit_unified_policies
 ORDER BY policy_name;
EXIT
