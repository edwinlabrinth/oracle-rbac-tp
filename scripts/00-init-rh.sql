-- 00-init-rh.sql : schéma RH (parties 1 à 5). À exécuter avec :
--   bash tools/sq.sh 0_init < scripts/00-init-rh.sql
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SHOW CON_NAME

-- Schéma applicatif sans mot de passe (schema-only account)
CREATE USER rh NO AUTHENTICATION
  DEFAULT TABLESPACE users QUOTA UNLIMITED ON users;

CREATE TABLE rh.departements (
  dept_id NUMBER PRIMARY KEY,
  nom     VARCHAR2(40) NOT NULL,
  ville   VARCHAR2(40));

CREATE TABLE rh.employes (
  emp_id        NUMBER PRIMARY KEY,
  nom           VARCHAR2(40) NOT NULL,
  prenom        VARCHAR2(40),
  poste         VARCHAR2(40),
  salaire       NUMBER(9,2),
  dept_id       NUMBER REFERENCES rh.departements,
  date_embauche DATE DEFAULT SYSDATE);

INSERT INTO rh.departements VALUES (10, 'Direction', 'Rabat');
INSERT INTO rh.departements VALUES (20, 'Informatique', 'Tanger');
INSERT INTO rh.departements VALUES (30, 'Finance', 'Casablanca');
INSERT INTO rh.departements VALUES (40, 'Logistique', 'Tanger');

INSERT INTO rh.employes VALUES (1, 'Alaoui', 'Karim', 'Directeur', 45000, 10, DATE '2015-03-01');
INSERT INTO rh.employes VALUES (2, 'Bennani', 'Salma', 'Cheffe de projet', 28000, 20, DATE '2018-09-15');
INSERT INTO rh.employes VALUES (3, 'Chraibi', 'Youssef', 'Développeur', 16000, 20, DATE '2021-01-04');
INSERT INTO rh.employes VALUES (4, 'Drissi', 'Imane', 'DBA', 22000, 20, DATE '2019-06-10');
INSERT INTO rh.employes VALUES (5, 'El Fassi', 'Nadia', 'Comptable', 14000, 30, DATE '2020-02-17');
INSERT INTO rh.employes VALUES (6, 'Filali', 'Omar', 'Contrôleur', 31000, 30, DATE '2016-11-21');
INSERT INTO rh.employes VALUES (7, 'Ghazi', 'Hamza', 'Magasinier', 7500, 40, DATE '2022-05-02');
INSERT INTO rh.employes VALUES (8, 'Haddad', 'Rim', 'Responsable log.', 19000, 40, DATE '2017-08-28');
COMMIT;

-- Vue « annuaire » : tout sauf les salaires
CREATE VIEW rh.v_annuaire AS
  SELECT emp_id, nom, prenom, poste, dept_id FROM rh.employes;
