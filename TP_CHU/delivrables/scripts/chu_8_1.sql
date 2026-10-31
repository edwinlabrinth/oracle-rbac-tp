-- chu_8_1.sql : Chapitre 8.1 -- Tables de journal et procedure LOG_EVT dans AUDIT_CHU
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- AUDIT_CHU a besoin de lire CHU.PERSONNEL (directement, pas via un rôle, car les
-- triggers s'exécutent avec les privilèges du définisseur et les rôles sont désactivés)
PROMPT === AUDIT_CHU : lecture CHU.PERSONNEL ===
GRANT SELECT ON chu.personnel TO audit_chu;

-- Table JOURNAL_DOSSIERS
PROMPT === Creation de JOURNAL_DOSSIERS ===
CREATE TABLE audit_chu.journal_dossiers (
  journal_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  journal_date  DATE DEFAULT SYSDATE,
  utilisateur   VARCHAR2(30),
  utilisateur_proxy VARCHAR2(30),
  poste         VARCHAR2(60),
  programme     VARCHAR2(60),
  dossier_id    NUMBER,
  ancien_diagnostic  VARCHAR2(80),
  nouveau_diagnostic VARCHAR2(80),
  ancien_traitement  VARCHAR2(80),
  nouveau_traitement VARCHAR2(80),
  ancien_confidentiel CHAR(1),
  nouveau_confidentiel CHAR(1)
);

-- Table JOURNAL_EVENEMENTS
PROMPT === Creation de JOURNAL_EVENEMENTS ===
CREATE TABLE audit_chu.journal_evenements (
  evenement_id  NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  evenement_date DATE DEFAULT SYSDATE,
  type_evenement VARCHAR2(30),
  utilisateur   VARCHAR2(30),
  utilisateur_proxy VARCHAR2(30),
  poste         VARCHAR2(60),
  programme     VARCHAR2(60),
  objet         VARCHAR2(30),
  detail        VARCHAR2(4000)
);

-- Procedure LOG_EVT (transaction autonome)
PROMPT === Creation de LOG_EVT ===
CREATE OR REPLACE PROCEDURE audit_chu.log_evt (
  p_type       VARCHAR2,
  p_objet      VARCHAR2,
  p_detail     VARCHAR2
) AS
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_utilisateur VARCHAR2(30);
  v_proxy       VARCHAR2(30);
  v_poste       VARCHAR2(60);
  v_programme   VARCHAR2(60);
BEGIN
  SELECT SYS_CONTEXT('USERENV','SESSION_USER'),
         SYS_CONTEXT('USERENV','PROXY_USER'),
         SYS_CONTEXT('USERENV','HOST'),
         SYS_CONTEXT('USERENV','CLIENT_PROGRAM_NAME')
    INTO v_utilisateur, v_proxy, v_poste, v_programme
    FROM dual;
  INSERT INTO audit_chu.journal_evenements
    (type_evenement, utilisateur, utilisateur_proxy, poste, programme, objet, detail)
  VALUES (p_type, v_utilisateur, v_proxy, v_poste, v_programme, p_objet, p_detail);
  COMMIT;
END;
/

-- Donner a R_AUDIT la lecture des deux journaux
PROMPT === R_AUDIT : lecture des journaux ===
GRANT SELECT ON audit_chu.journal_dossiers TO r_audit;
GRANT SELECT ON audit_chu.journal_evenements TO r_audit;

COLUMN table_name FORMAT A30
COLUMN object_type FORMAT A15
PROMPt === Objets crees dans AUDIT_CHU ===
SELECT object_name, object_type
  FROM dba_objects
 WHERE owner = 'AUDIT_CHU'
 ORDER BY object_name;
EXIT
