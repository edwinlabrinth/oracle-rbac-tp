-- 2_4.sql : Exercice 2.4 -- GRANT OPTION : la cascade
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. A1 et A2, puis SELECT avec droit de retransmission pour A1
CREATE USER a1 IDENTIFIED BY "A1#2026";
CREATE USER a2 IDENTIFIED BY "A2#2026";
GRANT CREATE SESSION TO a1, a2;
GRANT SELECT ON rh.departements TO a1 WITH GRANT OPTION;

-- 2. A1 retransmet la lecture a A2
CONNECT a1/"A1#2026"@//localhost/FREEPDB1
GRANT SELECT ON rh.departements TO a2;

CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
COLUMN grantee FORMAT A10
COLUMN grantor FORMAT A10
COLUMN table_name FORMAT A16
COLUMN privilege FORMAT A10
COLUMN grantable FORMAT A4
PROMPT === DBA_TAB_PRIVS sur RH.DEPARTEMENTS ===
SELECT grantee, grantor, table_name, privilege, grantable
  FROM dba_tab_privs
 WHERE owner = 'RH' AND table_name = 'DEPARTEMENTS'
 ORDER BY grantee;

-- 3. Revocation a A1 : effet sur A2
REVOKE SELECT ON rh.departements FROM a1;

CONNECT a2/"A2#2026"@//localhost/FREEPDB1
SELECT COUNT(*) AS nb_departements FROM rh.departements;
