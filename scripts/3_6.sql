-- 3_6.sql : Exercice 3.6 -- Que contiennent CONNECT et RESOURCE ?
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. Contenu des roles historiques
COLUMN role FORMAT A12
COLUMN privilege FORMAT A28
PROMPT === ROLE_SYS_PRIVS pour CONNECT et RESOURCE ===
SELECT role, privilege, admin_option
  FROM role_sys_privs
 WHERE role IN ('CONNECT','RESOURCE')
 ORDER BY role, privilege;

-- 2. TEST_RES avec CONNECT et RESOURCE
CREATE USER test_res IDENTIFIED BY "TestRes#2026";
GRANT CONNECT, RESOURCE TO test_res;

CONNECT test_res/"TestRes#2026"@//localhost/FREEPDB1
CREATE TABLE t_res (id NUMBER, libelle VARCHAR2(40));
INSERT INTO t_res VALUES (1, 'ligne');
