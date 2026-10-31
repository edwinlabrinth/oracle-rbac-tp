-- 3_5.sql : Exercice 3.5 -- Le piege des roles dans le code
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. CREATE PROCEDURE / CREATE VIEW via le role, quota 5 Mo pour OMAR
GRANT CREATE PROCEDURE, CREATE VIEW TO r_rh_gestion;
ALTER USER omar QUOTA 5M ON users;

-- 2. En OMAR : fonction a droits du definisseur puis vue
CONNECT omar/"Omar#2026"@//localhost/FREEPDB1
CREATE OR REPLACE FUNCTION nb_employes RETURN NUMBER AS
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM rh.employes;
  RETURN n;
END;
/
SHOW ERRORS

CREATE VIEW v_effectif AS
  SELECT dept_id, COUNT(*) n FROM rh.employes GROUP BY dept_id;

-- Variante AUTHID CURRENT_USER : verification des privileges a l'execution
CREATE OR REPLACE FUNCTION nb_employes_cu RETURN NUMBER
  AUTHID CURRENT_USER AS
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM rh.employes;
  RETURN n;
END;
/
SHOW ERRORS
SELECT nb_employes_cu AS nb_via_current_user FROM dual;

-- 3. Correction la plus restreinte : grant direct d'un seul objet
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
GRANT SELECT ON rh.employes TO omar;

CONNECT omar/"Omar#2026"@//localhost/FREEPDB1
CREATE OR REPLACE FUNCTION nb_employes RETURN NUMBER AS
  n NUMBER;
BEGIN
  SELECT COUNT(*) INTO n FROM rh.employes;
  RETURN n;
END;
/
SHOW ERRORS
SELECT nb_employes AS nb_employes FROM dual;

CREATE VIEW v_effectif AS
  SELECT dept_id, COUNT(*) n FROM rh.employes GROUP BY dept_id;
SELECT * FROM v_effectif ORDER BY dept_id;
