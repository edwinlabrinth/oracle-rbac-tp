-- 1_2.sql : Exercice 1.2 -- Quotas et création différée
SET LINESIZE 120 PAGESIZE 50
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA

-- 1. Droit de créer des tables pour ALI
GRANT CREATE TABLE TO ali;

-- 2. Création de la table en ALI (réussit) puis insertion (doit échouer faute de quota)
CONNECT ali/"Ali#2026"@//localhost/FREEPDB1
CREATE TABLE notes (id NUMBER, texte VARCHAR2(4000));
INSERT INTO notes VALUES (1, 'premiere ligne');

-- 3. Attribution d'un quota de 1 Mo sur USERS, puis nouvelle insertion
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
ALTER USER ali QUOTA 1M ON users;
CONNECT ali/"Ali#2026"@//localhost/FREEPDB1
INSERT INTO notes VALUES (1, 'premiere ligne apres quota');
SELECT COUNT(*) AS nb_lignes FROM notes;

-- 4. Bloc PL/SQL : doit s'arreter sur un depassement de quota
BEGIN
  FOR i IN 1..2000 LOOP
    INSERT INTO notes VALUES (i, RPAD('x', 4000, 'x'));
  END LOOP;
  COMMIT;
END;
/

-- 5. Quota reel d'ALI
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
COLUMN username FORMAT A12
COLUMN tablespace_name FORMAT A16
SELECT username, tablespace_name, bytes, max_bytes
  FROM dba_ts_quotas
 WHERE username = 'ALI';
