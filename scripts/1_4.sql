-- 1_4.sql : Exercice 1.4 -- Compte schema seul et proxy
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. Tentative de connexion directe au compte schema seul RH
CONNECT rh/"nimportequoi"@//localhost/FREEPDB1

-- 2. Creation de DEV1 et autorisation de connexion a travers RH
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
CREATE USER dev1 IDENTIFIED BY "Dev1#2026";
GRANT CREATE SESSION TO dev1;
ALTER USER rh GRANT CONNECT THROUGH dev1;

-- Premiere tentative proxy : RH n'a pas encore CREATE SESSION
CONNECT dev1[rh]/"Dev1#2026"@//localhost/FREEPDB1

-- On accorde CREATE SESSION a RH, puis on reessaie
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
GRANT CREATE SESSION TO rh;

-- 3. Connexion effective en proxy dev1[rh]
CONNECT dev1[rh]/"Dev1#2026"@//localhost/FREEPDB1
SELECT USER AS utilisateur_courant FROM dual;
COLUMN proxy_user FORMAT A20
SELECT SYS_CONTEXT('USERENV','PROXY_USER') AS proxy_user FROM dual;
COLUMN table_name FORMAT A24
SELECT table_name FROM user_tables ORDER BY table_name;
