-- 1_6_drop.sql : Exercice 1.6 (2/2) -- session ouverte, kill puis DROP CASCADE
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 2. DROP CASCADE alors qu'une session ALI est ouverte (lancee en parallele : 1_6_a)
DROP USER ali CASCADE;

-- 3. Identification puis terminaison de la session
COLUMN username FORMAT A12
SELECT sid, serial#, status FROM v$session WHERE username = 'ALI';

BEGIN
  FOR r IN (SELECT sid, serial# FROM v$session WHERE username = 'ALI') LOOP
    EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || r.sid || ',' || r.serial# || ''' IMMEDIATE';
  END LOOP;
END;
/
EXEC DBMS_SESSION.SLEEP(3);
SELECT sid, serial#, status FROM v$session WHERE username = 'ALI';

-- Suppression definitive apres liberation de la session
DROP USER ali CASCADE;

PROMPT === Verifications apres DROP USER ali CASCADE ===
SELECT COUNT(*) AS tables_ali FROM dba_tables WHERE owner = 'ALI';
SELECT COUNT(*) AS quotas_ali FROM dba_ts_quotas WHERE username = 'ALI';
