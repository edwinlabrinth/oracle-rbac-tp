-- 5_2.sql : Exercice 5.2 -- Echecs de connexion
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Activation de la politique predefinie ORA_LOGON_FAILURES (necessaire en 26ai :
-- aucune politique n'est activee par defaut, voir 5.1)
PROMPT === Activation de la politique ORA_LOGON_FAILURES ===
AUDIT POLICY ora_logon_failures;

COLUMN entity_name FORMAT A30
COLUMN success FORMAT A10
COLUMN failure FORMAT A10
PROMPT === Politiques actives apres activation ===
SELECT entity_name, success, failure
  FROM audit_unified_enabled_policies
 WHERE entity_name = 'ORA_LOGON_FAILURES';

-- Echecs de connexion : OMAR x2 (mauvais mdp), puis PIRATE (inexistant)
PROMPT === Connexion OMAR avec mauvais mot de passe (1/2) ===
CONNECT omar/"faux"@//localhost/FREEPDB1
PROMPT === Connexion OMAR avec mauvais mot de passe (2/2) ===
CONNECT omar/"faux"@//localhost/FREEPDB1
PROMPT === Connexion avec utilisateur inexistant PIRATE ===
CONNECT pirate/"x"@//localhost/FREEPDB1

-- Flush de la trace unifiee puis lecture
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
EXEC DBMS_AUDIT_MGMT.FLUSH_UNIFIED_AUDIT_TRAIL;

COLUMN event_timestamp FORMAT A22
COLUMN dbusername FORMAT A12
COLUMN userhost FORMAT A20
COLUMN client_program_name FORMAT A30
COLUMN return_code FORMAT 999999
COLUMN unified_audit_policies FORMAT A25
PROMPT === Traces LOGON echec dans UNIFIED_AUDIT_TRAIL ===
SELECT event_timestamp, dbusername, userhost, client_program_name,
       return_code, unified_audit_policies
  FROM unified_audit_trail
 WHERE action_name = 'LOGON'
   AND return_code <> 0
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '10' MINUTE
 ORDER BY event_timestamp;
EXIT
