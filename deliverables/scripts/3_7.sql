-- 3_7.sql : Exercice 3.7 -- Analyse des privileges (DBMS_PRIVILEGE_CAPTURE)
SET LINESIZE 120 PAGESIZE 60
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. Creation et demarrage d'une capture limitee aux sessions d'OMAR
BEGIN
  DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE(
    name      => 'cap_omar',
    type      => DBMS_PRIVILEGE_CAPTURE.G_CONTEXT,
    condition => 'SYS_CONTEXT(''USERENV'',''SESSION_USER'') = ''OMAR''');
END;
/
EXEC DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE(name => 'cap_omar');

-- 2. Activite d'OMAR
CONNECT omar/"Omar#2026"@//localhost/FREEPDB1
SELECT COUNT(*) AS annuaire FROM rh.v_annuaire;
UPDATE rh.employes SET poste = 'Architecte' WHERE emp_id = 3;
ROLLBACK;

-- 3. Arret, generation et comparaison des resultats
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
EXEC DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE(name => 'cap_omar');
EXEC DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT(name => 'cap_omar');

COLUMN capture FORMAT A10
COLUMN username FORMAT A10
COLUMN used_role FORMAT A14
COLUMN rolename FORMAT A14
COLUMN obj_priv FORMAT A10
COLUMN object_owner FORMAT A10
COLUMN object_name FORMAT A16
COLUMN column_name FORMAT A12
PROMPT === DBA_USED_OBJPRIVS (privileges reellement utilises) ===
SELECT capture, username, used_role, obj_priv, object_owner, object_name, column_name
  FROM dba_used_objprivs WHERE capture = 'CAP_OMAR'
 ORDER BY object_name, column_name, obj_priv;
PROMPT === DBA_UNUSED_OBJPRIVS (privileges non utilises) ===
SELECT capture, username, rolename, obj_priv, object_owner, object_name, column_name
  FROM dba_unused_objprivs WHERE capture = 'CAP_OMAR'
 ORDER BY object_name, column_name, obj_priv;

EXEC DBMS_PRIVILEGE_CAPTURE.DROP_CAPTURE(name => 'cap_omar');
