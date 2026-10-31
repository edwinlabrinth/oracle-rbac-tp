-- 2_1.sql : Exercice 2.1 -- Le developpeur minimal
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. Exactement les privileges necessaires, aucun role, aucun privilege ANY
GRANT CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE TO dev1;
ALTER USER dev1 QUOTA 20M ON users;

-- 2. En DEV1 : privileges effectifs et creation d'objets dans son schema
CONNECT dev1/"Dev1#2026"@//localhost/FREEPDB1
COLUMN privilege FORMAT A24
SELECT privilege FROM session_privs ORDER BY privilege;

CREATE TABLE projets (
  projet_id NUMBER PRIMARY KEY,
  nom       VARCHAR2(60) NOT NULL,
  budget    NUMBER(12,2));

CREATE SEQUENCE seq_projets START WITH 1 INCREMENT BY 1;

CREATE VIEW v_projets AS
  SELECT projet_id, nom, budget FROM projets;

COLUMN object_name FORMAT A20
COLUMN object_type FORMAT A12
SELECT object_name, object_type FROM user_objects ORDER BY object_type, object_name;
