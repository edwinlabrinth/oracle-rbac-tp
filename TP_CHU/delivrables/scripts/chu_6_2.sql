-- chu_6_2.sql : Chapitre 6.2 -- Creation et activation des politiques d'audit unifie CHU
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Nettoyage eventuel
PROMPT === Nettoyage politiques eventuelles ===
NOAUDIT POLICY pol_chu_dossiers;
DROP AUDIT POLICY pol_chu_dossiers;
NOAUDIT POLICY pol_chu_adhoc;
DROP AUDIT POLICY pol_chu_adhoc;
NOAUDIT POLICY pol_chu_gouvernance;
DROP AUDIT POLICY pol_chu_gouvernance;

-- 1. POL_CHU_DOSSIERS : SELECT, INSERT, UPDATE, DELETE sur dossiers_medicaux + SELECT sur v_soins
--                         pour tous les comptes SAUF APP_CHU
PROMPT === Creation POL_CHU_DOSSIERS ===
CREATE AUDIT POLICY pol_chu_dossiers
  ACTIONS SELECT, INSERT, UPDATE, DELETE ON chu.dossiers_medicaux,
          SELECT ON chu.v_soins;
PROMPT === Activation POL_CHU_DOSSIERS (EXCEPT app_chu) ===
AUDIT POLICY pol_chu_dossiers EXCEPT app_chu;

-- 2. POL_CHU_ADHOC : INSERT, UPDATE, DELETE sur PATIENTS, PRESCRIPTIONS, FACTURES
--                    uniquement quand le programme client est SQL*Plus ou SQL Developer
--                    (evaluation par session)
PROMPT === Creation POL_CHU_ADHOC (clause WHEN sur CLIENT_PROGRAM_NAME) ===
CREATE AUDIT POLICY pol_chu_adhoc
  ACTIONS INSERT, UPDATE, DELETE ON chu.patients,
          INSERT, UPDATE, DELETE ON chu.prescriptions,
          INSERT, UPDATE, DELETE ON chu.factures
  WHEN 'SYS_CONTEXT(''USERENV'',''CLIENT_PROGRAM_NAME'') LIKE ''%sqlplus%'' OR SYS_CONTEXT(''USERENV'',''CLIENT_PROGRAM_NAME'') LIKE ''%sqldeveloper%''' EVALUATE PER SESSION;
PROMPT === Activation POL_CHU_ADHOC ===
AUDIT POLICY pol_chu_adhoc;

-- 3. POL_CHU_GOUVERNANCE : CREATE/ALTER/DROP TRIGGER, DROP TABLE, TRUNCATE TABLE,
--                          SELECT ANY TABLE, ALTER ANY TRIGGER
PROMPT === Creation POL_CHU_GOUVERNANCE ===
CREATE AUDIT POLICY pol_chu_gouvernance
  PRIVILEGES CREATE TRIGGER, ALTER TRIGGER, DROP TRIGGER,
             DROP ANY TABLE, TRUNCATE ANY TABLE,
             SELECT ANY TABLE, ALTER ANY TRIGGER;
PROMPT === Activation POL_CHU_GOUVERNANCE ===
AUDIT POLICY pol_chu_gouvernance;

-- 4. ORA_ACCOUNT_MGMT (predefinie) : gestion des comptes et habilitations
PROMPt === Activation ORA_ACCOUNT_MGMT ===
AUDIT POLICY ora_account_mgmt;

COLUMN policy_name FORMAT A30
COLUMN audit_option FORMAT A25
PROMPt === Politiques CREEES ===
SELECT policy_name, audit_option
  FROM audit_unified_policies
 WHERE policy_name IN ('POL_CHU_DOSSIERS','POL_CHU_ADHOC','POL_CHU_GOUVERNANCE')
 ORDER BY policy_name, audit_option;

COLUMN entity_name FORMAT A30
COLUMN success FORMAT A10
COLUMN failure FORMAT A10
PROMPt === Politiques ACTIVEES ===
SELECT entity_name, success, failure
  FROM audit_unified_enabled_policies
 WHERE entity_name IN ('POL_CHU_DOSSIERS','POL_CHU_ADHOC','POL_CHU_GOUVERNANCE','ORA_ACCOUNT_MGMT')
 ORDER BY entity_name;
EXIT
