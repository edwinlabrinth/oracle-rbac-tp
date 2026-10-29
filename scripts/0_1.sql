-- 0_1.sql : Exercice 0.1 -- Vérifier l'environnement
CONNECT sys/"Admin#2026"@//localhost/FREEPDB1 AS SYSDBA
SHOW CON_NAME

-- 1. Nombre de lignes de chaque table du schéma RH
COLUMN table_name FORMAT A20
SELECT 'DEPARTEMENTS' AS table_name, COUNT(*) AS nb_lignes FROM rh.departements
UNION ALL
SELECT 'EMPLOYES', COUNT(*) FROM rh.employes;

-- 2. Compte RH dans DBA_USERS
COLUMN username FORMAT A12
COLUMN authentication_type FORMAT A20
COLUMN account_status FORMAT A16
COLUMN oracle_maintained FORMAT A4
SELECT username, authentication_type, account_status, oracle_maintained
  FROM dba_users
 WHERE username = 'RH';

-- 3. Répartition des utilisateurs de la PDB selon ORACLE_MAINTAINED
COLUMN categorie FORMAT A22
SELECT CASE oracle_maintained WHEN 'Y' THEN 'Maintenu par Oracle'
                              ELSE 'Créé par vous' END AS categorie,
       COUNT(*) AS nb
  FROM dba_users
 GROUP BY oracle_maintained
 ORDER BY 1;
