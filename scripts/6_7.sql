-- 6_7.sql : Exercice 6.7 (T7) -- Revue des habilitations (3 requêtes pour l'auditeur)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

COLUMN username FORMAT A14
COLUMN profile FORMAT A16
COLUMN account_status FORMAT A14
COLUMN expiry_date FORMAT A16
COLUMN roles FORMAT A60
PROMPT === Requete 1 : utilisateurs metier - profil, etat, expiration, roles (LISTAGG) ===
SELECT u.username,
       u.profile,
       u.account_status,
       TO_CHAR(u.expiry_date, 'DD-MON-YYYY') AS expiry_date,
       LISTAGG(rp.granted_role, ', ') WITHIN GROUP (ORDER BY rp.granted_role) AS roles
  FROM dba_users u
  LEFT JOIN dba_role_privs rp ON u.username = rp.grantee
 WHERE u.username IN ('GUI1','GUI2','CONS1','DIR1','AUD1','APP_BATCH','DEV_BQ','GUI3')
 GROUP BY u.username, u.profile, u.account_status, u.expiry_date
 ORDER BY u.username;

COLUMN owner FORMAT A10
COLUMN object_name FORMAT A25
COLUMN grantee FORMAT A18
COLUMN privilege FORMAT A18
PROMPT === Requete 2 : objets BANQUE - qui dispose de quel privilège ===
SELECT object_name, grantee, privilege
  FROM dba_tab_privs
 WHERE owner = 'BANQUE'
 ORDER BY object_name, grantee, privilege;

COLUMN unified_audit_policies FORMAT A30
COLUMN dbusername FORMAT A15
COLUMN nb FORMAT 9999
PROMPt === Requete 3 : evenements d'audit par politique et utilisateur (7 jours) ===
SELECT unified_audit_policies, dbusername, COUNT(*) AS nb
  FROM unified_audit_trail
 WHERE event_timestamp > SYSTIMESTAMP - INTERVAL '7' DAY
 GROUP BY unified_audit_policies, dbusername
 ORDER BY unified_audit_policies, dbusername;
EXIT
