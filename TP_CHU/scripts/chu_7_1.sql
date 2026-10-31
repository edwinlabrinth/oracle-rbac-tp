-- chu_7_1.sql : Chapitre 7.1 -- Politique FGA avec gestionnaire d'alerte
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Nettoyage eventuel
PROMPT === Nettoyage ===
BEGIN
  DBMS_FGA.DISABLE_POLICY('CHU','DOSSIERS_MEDICAUX','FGA_CHU_CONFIDENTIEL');
  DBMS_FGA.DROP_POLICY('CHU','DOSSIERS_MEDICAUX','FGA_CHU_CONFIDENTIEL');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
DROP TABLE audit_chu.alertes;
DROP PROCEDURE audit_chu.alerte_fga;

-- Table des alertes FGA
PROMPT === Creation de AUDIT_CHU.ALERTES ===
CREATE TABLE audit_chu.alertes (
  alerte_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  alerte_date  DATE DEFAULT SYSDATE,
  utilisateur  VARCHAR2(30),
  poste        VARCHAR2(60),
  programme    VARCHAR2(60),
  objet        VARCHAR2(30),
  politique    VARCHAR2(30)
);

-- Procedure d'alerte (transaction autonome pour survivre a un ROLLBACK)
PROMPT === Creation de AUDIT_CHU.ALERTE_FGA ===
CREATE OR REPLACE PROCEDURE audit_chu.alerte_fga (
  p_schema  VARCHAR2,
  p_objet   VARCHAR2,
  p_politique VARCHAR2
) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_utilisateur VARCHAR2(30);
  v_poste       VARCHAR2(60);
  v_programme   VARCHAR2(60);
BEGIN
  SELECT SYS_CONTEXT('USERENV','SESSION_USER'),
         SYS_CONTEXT('USERENV','HOST'),
         SYS_CONTEXT('USERENV','CLIENT_PROGRAM_NAME')
    INTO v_utilisateur, v_poste, v_programme
    FROM dual;
  INSERT INTO audit_chu.alertes (utilisateur, poste, programme, objet, politique)
  VALUES (v_utilisateur, v_poste, v_programme, p_objet, p_politique);
  COMMIT;
END;
/

-- Donner a SYS le droit d'executer la procedure (pour qu'elle puisse etre handler FGA)
PROMPT === Grant EXECUTE sur ALERTE_FGA ===
GRANT EXECUTE ON audit_chu.alerte_fga TO sys;

-- Politique FGA sur CHU.DOSSIERS_MEDICAUX
PROMPT === Creation FGA_CHU_CONFIDENTIEL ===
BEGIN
  DBMS_FGA.ADD_POLICY(
    object_schema   => 'CHU',
    object_name     => 'DOSSIERS_MEDICAUX',
    policy_name     => 'FGA_CHU_CONFIDENTIEL',
    audit_condition => 'confidentiel = ''O''',
    audit_column    => 'DIAGNOSTIC,ANTECEDENTS,TRAITEMENT',
    statement_types => 'SELECT,UPDATE',
    handler_module  => 'audit_chu.alerte_fga',
    enable          => TRUE);
END;
/

-- R_AUDIT lit la table des alertes
PROMPT === R_AUDIT : lecture AUDIT_CHU.ALERTES ===
GRANT SELECT ON audit_chu.alertes TO r_audit;

COLUMN policy_name FORMAT A30
COLUMN enable FORMAT A8
PROMPt === Politiques FGA sur CHU.DOSSIERS_MEDICAUX ===
SELECT policy_name, enable
  FROM dba_audit_policies
 WHERE object_schema = 'CHU' AND object_name = 'DOSSIERS_MEDICAUX';

COLUMN object_name FORMAT A25
COLUMN handler_module FORMAT A35
PROMPt === Definition de la politique FGA ===
SELECT policy_name, object_schema, object_name, statement_types, handler_module, enabled
  FROM audit_unified_policies
 WHERE policy_name = 'FGA_CHU_CONFIDENTIEL';
EXIT
