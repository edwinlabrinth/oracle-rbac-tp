-- 1_1.sql : Exercice 1.1 -- Premier compte
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. Création de ALI sans aucune autre clause
CREATE USER ali IDENTIFIED BY "Ali#2026"
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp;

-- 2. Tentative de connexion en ALI avant tout privilège
CONNECT ali/"Ali#2026"@//localhost/FREEPDB1

-- 3. Correction avec le privilège minimal : CREATE SESSION
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
GRANT CREATE SESSION TO ali;

-- Reconnexion en ALI
CONNECT ali/"Ali#2026"@//localhost/FREEPDB1
SELECT USER AS utilisateur_courant FROM dual;

-- 4. Détails du compte ALI
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
COLUMN username FORMAT A12
COLUMN default_tablespace FORMAT A18
COLUMN temporary_tablespace FORMAT A20
COLUMN profile FORMAT A12
COLUMN account_status FORMAT A16
COLUMN created FORMAT A20
SELECT username, default_tablespace, temporary_tablespace,
       profile, account_status, created
  FROM dba_users
 WHERE username = 'ALI';
