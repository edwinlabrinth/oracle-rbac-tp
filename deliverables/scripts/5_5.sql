-- 5_5.sql : Exercice 5.5 -- Politique conditionnelle et rôle (POL_RH_ADHOC, POL_DBA)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Nettoyage des politiques eventuellement deja presentes (etat propre)
PROMPT === Nettoyage des politiques de test ===
NOAUDIT POLICY pol_rh_adhoc;
DROP AUDIT POLICY pol_rh_adhoc;
NOAUDIT POLICY pol_dba;
DROP AUDIT POLICY pol_dba;

-- Valeur exacte de CLIENT_PROGRAM_NAME pour construire la clause WHEN
COLUMN client_program_name FORMAT A40
PROMPT === Valeur exacte de CLIENT_PROGRAM_NAME ===
SELECT SYS_CONTEXT('USERENV','CLIENT_PROGRAM_NAME') AS client_program_name FROM dual;

-- POL_RH_ADHOC : tentative avec clause WHEN (echoue ORA-01756 en 26ai -> ecart documente)
PROMPT === POL_RH_ADHOC : tentative avec clause WHEN SYS_CONTEXT (attendu ORA-01756) ===
CREATE AUDIT POLICY pol_rh_adhoc
  ACTIONS SELECT, UPDATE, DELETE ON rh.employes
  WHEN 'SYS_CONTEXT(''USERENV'',''CLIENT_PROGRAM_NAME'') = ''sqlplus@325ea919716d (TNS V1-V3)'' EVALUATE PER SESSION;

-- POL_DBA : auditer le rôle DBA (couvre tous ses privilèges)
PROMPT === POL_DBA : creation et activation ===
CREATE AUDIT POLICY pol_dba ROLES dba;
AUDIT POLICY pol_dba;

-- Accorder DBA à A1
PROMPT === GRANT dba TO a1 ===
GRANT dba TO a1;

-- A1 se reconnecte, active le rôle DBA, crée un utilisateur temporaire
PROMPT === A1 : SET ROLE dba + CREATE USER test_dba ===
CONNECT a1/"A1#2026"@//localhost/FREEPDB1
SET ROLE dba;
CREATE USER test_dba IDENTIFIED BY "Test#2026";

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Retirer DBA à A1 et supprimer l'utilisateur temporaire
PROMPT === REVOKE dba FROM a1 puis DROP USER test_dba ===
REVOKE dba FROM a1;
DROP USER test_dba;

-- Lecture de la trace (2 dernières minutes, politique POL_DBA + actions admin)
COLUMN event_timestamp FORMAT A22
COLUMN dbusername FORMAT A12
COLUMN action_name FORMAT A20
COLUMN object_name FORMAT A20
COLUMN unified_audit_policies FORMAT A22
COLUMN sql_text FORMAT A45
PROMPt === Traces POL_DBA (role DBA) + actions admin - 2 min ===
SELECT event_timestamp, dbusername, action_name, object_name,
       unified_audit_policies, sql_text
  FROM unified_audit_trail
 WHERE (unified_audit_policies LIKE '%POL_DBA%'
        OR action_name IN ('CREATE USER','DROP USER','GRANT','REVOKE'))
   AND event_timestamp > SYSTIMESTAMP - INTERVAL '2' MINUTE
 ORDER BY event_timestamp;

COLUMN entity_name FORMAT A30
COLUMN success FORMAT A10
COLUMN failure FORMAT A10
PROMPt === Etat des politiques dans AUDIT_UNIFIED_ENABLED_POLICIES ===
SELECT entity_name, success, failure
  FROM audit_unified_enabled_policies
 WHERE entity_name IN ('POL_RH_ADHOC','POL_DBA')
 ORDER BY entity_name;
EXIT
