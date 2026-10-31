-- 6_7b.sql : Exercice 6.7 (T7) -- Requete 2 corrigée (objets BANQUE)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

COLUMN table_name FORMAT A25
COLUMN grantee FORMAT A18
COLUMN privilege FORMAT A18
PROMPT === Requete 2 : objets BANQUE - qui dispose de quel privilège ===
SELECT table_name, grantee, privilege
  FROM dba_tab_privs
 WHERE owner = 'BANQUE'
 ORDER BY table_name, grantee, privilege;
EXIT
