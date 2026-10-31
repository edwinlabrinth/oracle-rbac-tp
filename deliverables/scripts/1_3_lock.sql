-- 1_3_lock.sql : Exercice 1.3 (suite) -- verrouillage et deverrouillage du compte
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

COLUMN username FORMAT A12
COLUMN account_status FORMAT A16
COLUMN lock_date FORMAT A20
COLUMN expiry_date FORMAT A20

PROMPT === Etat apres changement du mot de passe (Ali#2027) ===
SELECT username, account_status, lock_date, expiry_date
  FROM dba_users WHERE username = 'ALI';

-- 2. Verrouillage du compte
ALTER USER ali ACCOUNT LOCK;
PROMPT === Etat apres ALTER USER ali ACCOUNT LOCK ===
SELECT username, account_status, lock_date, expiry_date
  FROM dba_users WHERE username = 'ALI';

-- 3. Tentative de connexion sur un compte verrouille
CONNECT ali/"Ali#2027"@//localhost/FREEPDB1

-- Etat apres la tentative de connexion
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
PROMPT === Etat apres tentative de connexion (compte verrouille) ===
SELECT username, account_status, lock_date, expiry_date
  FROM dba_users WHERE username = 'ALI';

-- 4. Deverrouillage
ALTER USER ali ACCOUNT UNLOCK;
PROMPT === Etat apres ALTER USER ali ACCOUNT UNLOCK ===
SELECT username, account_status, lock_date, expiry_date
  FROM dba_users WHERE username = 'ALI';
