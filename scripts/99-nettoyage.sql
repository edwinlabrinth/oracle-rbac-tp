-- 99-nettoyage.sql : À EXÉCUTER UNIQUEMENT EN FIN DE TP (tout est supprimé, preuves comprises).
--   bash tools/sq.sh 99_nettoyage < scripts/99-nettoyage.sql
-- Les erreurs "n'existe pas" sont normales si un objet n'a pas été créé.
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Audit
NOAUDIT POLICY pol_rh_salaires; DROP AUDIT POLICY pol_rh_salaires;
NOAUDIT POLICY pol_bq_clients;  DROP AUDIT POLICY pol_bq_clients;
NOAUDIT POLICY pol_bq_soldes;   DROP AUDIT POLICY pol_bq_soldes;
NOAUDIT POLICY ora_account_mgmt;
EXEC DBMS_FGA.DROP_POLICY('RH','EMPLOYES','FGA_GROS_SALAIRES')
EXEC DBMS_FGA.DROP_POLICY('BANQUE','OPERATIONS','FGA_BQ_GROS_MONTANTS')

-- Utilisateurs (y compris les schémas applicatifs)
-- (ajout par rapport au TP : ALI, TEST_RES, STAGIAIRE si encore présents)
BEGIN
  FOR u IN (SELECT username FROM dba_users WHERE username IN
            ('DEV1','LECTEUR1','OMAR','A1','A2','LINA','SARA','AUDITEUR','ALI','TEST_RES','STAGIAIRE',
             'GUI1','GUI2','GUI3','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ','RH','BANQUE'))
  LOOP
    EXECUTE IMMEDIATE 'DROP USER ' || u.username || ' CASCADE';
  END LOOP;
END;
/

-- Rôles et profils
BEGIN
  FOR r IN (SELECT role FROM dba_roles WHERE role LIKE 'R\_RH\_%' ESCAPE '\'
            OR role LIKE 'R\_BQ\_%' ESCAPE '\' OR role IN ('R_CONNEXION','R_TEST'))
  LOOP
    EXECUTE IMMEDIATE 'DROP ROLE ' || r.role;
  END LOOP;
END;
/
DROP PROFILE p_rh_standard CASCADE;
DROP PROFILE p_rh_test CASCADE;
DROP PROFILE p_bq_agent CASCADE;
DROP PROFILE p_bq_conseil CASCADE;
DROP PROFILE p_bq_sensible CASCADE;
DROP PROFILE p_bq_service CASCADE;

-- L'utilisateur commun C##SUPERVISEUR se supprime depuis la RACINE :
CONNECT / AS SYSDBA
SHOW CON_NAME
DROP USER c##superviseur CASCADE;
