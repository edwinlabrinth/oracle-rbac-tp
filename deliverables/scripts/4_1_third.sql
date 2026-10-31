-- 4_1_third.sql : Exercice 4.1 (partie 2) -- trois sessions puis inactivite
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- Session numero 3 de LINA (les deux autres sont ouvertes en parallele : 4_1_a, 4_1_b)
PROMPT === Troisieme tentative de connexion de LINA (doit echouer) ===
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1

-- On libere les deux sessions de fond de LINA pour pouvoir continuer
PROMPT === Liste et terminaison des sessions LINA ===
COLUMN sid FORMAT A8
COLUMN serial# FORMAT A8
SELECT sid, serial#, status FROM v$session WHERE username = 'LINA';
BEGIN
  FOR r IN (SELECT sid, serial# FROM v$session WHERE username = 'LINA') LOOP
    EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION ''' || r.sid || ',' || r.serial# || ''' IMMEDIATE';
  END LOOP;
END;
/

-- Test d'inactivite (IDLE_TIME = 1 minute)
PROMPT === Session LINA inactive puis requete (doit donner ORA-02396) ===
CONNECT lina/"Lina#2026"@//localhost/FREEPDB1
HOST sleep 70
SELECT 1 AS test_inactivite FROM dual;

PROMPT === Statut de la session LINA dans V$SESSION ===
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SELECT sid, serial#, status, last_call_et FROM v$session WHERE username = 'LINA';
