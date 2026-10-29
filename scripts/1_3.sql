-- 1_3.sql : Exercice 1.3 -- Cycle de vie d'un compte (expiration du mot de passe)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

COLUMN username FORMAT A12
COLUMN account_status FORMAT A16
COLUMN lock_date FORMAT A20
COLUMN expiry_date FORMAT A20

PROMPT === Etat initial du compte ALI ===
SELECT username, account_status, lock_date, expiry_date
  FROM dba_users WHERE username = 'ALI';

-- 1. Expiration du mot de passe
ALTER USER ali PASSWORD EXPIRE;

PROMPT === Etat apres ALTER USER ali PASSWORD EXPIRE ===
SELECT username, account_status, lock_date, expiry_date
  FROM dba_users WHERE username = 'ALI';

-- 2. Tentative de connexion avec le mot de passe expire : SQL*Plus propose le changement
CONNECT ali/"Ali#2026"@//localhost/FREEPDB1

-- Etat apres la tentative (le mot de passe n'a pas encore ete change)
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
PROMPT === Etat apres tentative de connexion ===
SELECT username, account_status, lock_date, expiry_date
  FROM dba_users WHERE username = 'ALI';
