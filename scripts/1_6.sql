-- 1_6.sql : Exercice 1.6 -- Supprimer un utilisateur (1/2)
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. DROP USER sans CASCADE alors qu'ALI possede des objets
DROP USER ali;

-- Objets et quota qui empechent la suppression
COLUMN table_name FORMAT A20
SELECT table_name FROM dba_tables WHERE owner = 'ALI';
COLUMN tablespace_name FORMAT A16
SELECT username, tablespace_name, bytes, max_bytes
  FROM dba_ts_quotas WHERE username = 'ALI';
